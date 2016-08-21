# Rockerfile https://github.com/grammarly/rocker
# BUILD forceuser
FROM alpine:3.4

RUN apk add --update gcc musl-dev

COPY src/forceuser /src
WORKDIR /src
RUN gcc -shared -fPIC forceuser.c -o forceuser.so -ldl

EXPORT forceuser.so

# BUILD openssh w/ pam
FROM alpine:3.4

RUN apk add --update gcc musl-dev
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories &&\
    apk add --update gosu@testing alpine-sdk linux-headers openssl-dev linux-pam-dev zlib-dev

WORKDIR /abuild
RUN adduser -G abuild -s /bin/ash -h /abuild -D abuild &&\
    gosu abuild wget http://git.alpinelinux.org/cgit/aports/snapshot/aports-3.4.0.tar.bz2 2>&1 &&\
    gosu abuild tar -xvf aports-3.4.0.tar.bz2 aports-3.4.0/main/openssh

COPY src/patches /patches
RUN gosu abuild patch -p0 < /patches/APKBUILD.patch

WORKDIR /abuild/aports-3.4.0/main/openssh
RUN gosu abuild abuild-keygen -an 2>&1 &&\
    gosu abuild abuild checksum 2>&1 &&\
    gosu abuild abuild -r 2>&1

RUN mkdir /abuild/keys &&\
    cp /abuild/.abuild/*.pub /abuild/keys
EXPORT /abuild/keys/ /keys/
EXPORT /abuild/packages/ /packages

## RUNTIME
FROM alpine:3.4
MAINTAINER Nicholas Pace "https://github.com/segfly"

IMPORT /packages /
IMPORT /keys/ /etc/apk/keys/

RUN echo "@local /packages/main" >> /etc/apk/repositories &&\
    apk add --update openssh@local &&\
    passwd -l root &&\
    adduser -S -s /bin/sh -h /home/ssh-gitway ssh-gitway &&\
    mkdir -p /home/ssh-gitway/.ssh &&\
    chmod 700 /home/ssh-gitway/.ssh &&\
    chown ssh-gitway -R /home/ssh-gitway &&\
    chown root:root -R /etc/apk/keys/ &&\
    rm -rf /var/cache/apk/* &&\
    rm -rf /packages &&\
    mkdir /etc/ssh.d &&\
    mv /etc/ssh/* /etc/ssh.d &&\
    ln -s /etc/ssh.d/sshd_config /etc/ssh/sshd_config &&\
    ln -s /etc/ssh.d/ssh_config /etc/ssh/ssh_config &&\
    ln -s /etc/ssh.d/moduli /etc/ssh/moduli &&\
\
    awk '$5 > 2000' /etc/ssh.d/moduli > "${HOME}/moduli" &&\
    mv "${HOME}/moduli" /etc/ssh.d/moduli &&\
    sh -c 'find / -xdev -user root \( -perm -2000 \) | xargs -r chmod g-s' &&\
    sh -c 'find / -xdev -user root \( -perm -4000 \) | xargs -r chmod u-s'

IMPORT forceuser.so /usr/lib

COPY etc /etc
ENV LD_PRELOAD /usr/lib/forceuser.so
ENV FORCE_USER ssh-gitway

EXPOSE 22
ENTRYPOINT ["/etc/entrypoint/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

PUSH segfly/ssh-gitway:latest
