# SSH GitWay
[![License](http://img.shields.io/badge/license-APACHE-blue.svg?style=flat)](http://choosealicense.com/licenses/apache-2.0/)
[![License](http://img.shields.io/badge/semver-2.0.0-blue.svg?style=flat)](http://semver.org/spec/v2.0.0)

A routing SSH-Git gateway!

## Features
* Deploys in a Docker container
* Routes to secondary server based on login name
* Supports dynamic DNS-based container linking
* Hardened SSHD configuration
* Blocks SSH simple shell login attempts
* Supports clustering and high-availability
* Only **12MB** in size built with Alpine Linux 

## Quick Start Demo

The supplied [docker-compose.yml](docker-compose.yml) file is a deployment example of SSH GitWay. In the real-world all you need is the `ssh-gitway` container and to link your own SSH git containers such as: GitHub Enterprise, Bitbucket, Gerrit, Gitlab, you name it!

For the demo, a sample git server container is supplied. To configure the servers in the `docker-compose.yml`, simply provide one or more SSH public keys as the `AUTHORIZED_KEYS:` value of both the `team1` and `team2` git server containers. The intention is to mock a scenario where a user with an account on both git instances will be using the same public key.

After you add your public key, you may run the demo with `docker-compose up` and then clone the repos into a new directory using the following commands:

Team 1: `git clone "ext::ssh -A team1@localhost %S /repos/sample.git"`

Team 2: `git clone "ext::ssh -A team2@localhost %S /repos/sample.git"`

Note: The supplied `docker-compose.yml` assumes you have nothing running on port 22. If you do, simply change the published port and include the port number in the ssh command above with the ssh option `-p <port>`.

### What happened here?

You just interacted with two different git SSH servers hosted on the same IP and port!

SSH-GitWay acts as an automated jump-host. Once you login it automatically creates an SSH connection to the target server and forwards the session.

It resolves the target server based on the incoming user name. Most (if not all) SSH Git servers rely on your public keys and the username is fixed as `git`. Instead of logging into SSH-GitWay using `git@gitway-server` SSH-GitWay uses the username to indicate the name of the target instance you are trying to reach such as: `myinstance@gitway-server`. It then logs into that server on your behalf using ssh-agent key forwarding using the typical git user `git@myinstance`.

This approach allows the target SSH Git server to reside on a container-private IP without publishing any ports. It only needs to be linked to the SSH-GitWay container. When used with DNS-based container discovery, new git instances can be added dynamically since SSH-GitWay is resolving target servers based onD NS name.

## The Problem SSH GitWay Solves
The HTTP protocol supports virtual hosts via the `HOST` header. The client will tell the server which domain name it is trying to reach. This allows for multiple hosts to be served from a single IP on the same port. Yay!

SSH however, does not have this concept. SSH clients do not tell the server which host it is trying to reach. This means, multiple SSH hosts (by domain name) can not be served by a single IP on the same port. Nay!

### So What?
This limitation with SSH is a considerable headache in a containerized environment.
Considering IPv4 exhaustion, IPv6 roll-out issues, and the trouble managing hundreds or thousands of containers on non-standard ports with end-users, it's usually much simpler to give containers a private-IP and use NAT behind the hosts's IP.

SSH-Gitway allows you to scale much easier.

## The Solution
There is more than one way to address this problem: SSH tunneling over HTTP[1], multiple port mappings, and making Git users use only HTTP all come with trade-offs. 
 
 However, an automated jump-host with SSH-agent key forwarding seems to be the simplest from an end-user perspective. It requires no special tunneling binaries, port-mapping madness, and thank's to Git's `ext::`[2] is simple to setup - but for more advanced users the `-A` flag to enable key-forwarding can be set elsewhere allowing for the typical git clone syntax.

## How it Works
At a high-level, the SSH-GitWay container has the following:
* A recompiled version of openssh that includes support for PAM
* A carefully hardened[3] SSHD configuration to improve overall security
  * (Possibly more secure than your target server's configuration)
* Additional hardening against setuid vulnerabilities[4]
* A PAM configuration that allows unknown users to connect to SSHD
  * (We're relying on the target server to do the actual authentication)
* A special LD_PRELOAD library to hook calls to glibc/musl `getpwnam` and force all users to a special non-root local user
  * (This is the user that makes the second SSH connection to the target)
* An example `docker-compose.yml` with unneeded capabilities removed
  * (there are usually more by default)

**Some of the Icing:**
* Regular terminal access is prohibited
* A volume mounted at `/etc/ssh` will enable persistent host-keys for the SSH GitWay server
* Setting `TARGET_SSH_PORT` will control the target destination port of SSH GitWay allowing non-root target containers
* SSHD is started as root, because it is more secure than allowing a non-privileged user in the container possible access to the host keys

# How to Build
This project uses Rocker[5] because it's pretty awesome. If you use the Segfly containerized version of Rocker[6], the build command is simply:

```bash
rocker build -f ssh-gitway/Dockerfile
```

# Known Issues
* Client without the ability to perform ssh-agent key forwarding are probably not going to work

# References

* [1] http://dag.wiee.rs/howto/ssh-http-tunneling/
* [2] https://git-scm.com/docs/git-remote-ext
* [3] https://stribika.github.io/2015/01/04/secure-secure-shell.html
* [4] https://linux-audit.com/finding-setuid-binaries-on-linux-and-bsd/
* [5] https://github.com/grammarly/rocker
* [6] https://github.com/segfly-oss/rocker
