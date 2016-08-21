FROM alpine:3.4
MAINTAINER Nicholas Pace "https://github.com/segfly"

RUN apk add --update ca-certificates openssh git &&\
    update-ca-certificates &&\
    rm -rf /var/cache/apk/* &&\
\
    adduser -S -s /bin/sh -h /home/git git &&\
    mkdir -p /home/git/.ssh &&\
    touch /home/git/.ssh/authorized_keys &&\
    chmod 700 /home/git/.ssh &&\
    chmod 600 /home/git/.ssh/authorized_keys &&\
    ln -s /home/git /repos &&\
\
    mkdir /home/git/sample.git &&\
    git -C /home/git/sample.git init --bare &&\
\
    mkdir /var/run/sshd &&\
    chown git -R /home/git /var/run/sshd /etc/ssh

COPY etc /etc
EXPOSE 2022
USER git
ENTRYPOINT ["/etc/entrypoint/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

PUSH segfly/ssh-gitway:sample-git-server