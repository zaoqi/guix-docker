# Originally forked from git@github.com:bmpvieira/Dockerfiles.git

FROM alpine

MAINTAINER Rudolf Olah <omouse@gmail.com>

LABEL Description="This is a minimal Linux (Alpine) with GNU Guix package manager" Version="2.0.0"

ENV GUIX_PROFILE="/root/.config/guix/current"
RUN apk add --no-cache shadow && \
  groupadd --system guixbuild && \
  for i in `seq -w 1 10`; do useradd -g guixbuild -G guixbuild -d /var/empty -s `which nologin` -c "Guix build user $i" --system guixbuilder$i; done && \
  apk del shadow && \
  wget -O - https://ftp.gnu.org/gnu/guix/guix-binary-1.0.1.x86_64-linux.tar.xz | tar -xJv -C / && \
  mkdir -p ~root/.config/guix && \
  ln -sf /var/guix/profiles/per-user/root/current-guix ~root/.config/guix/current && \
  source $GUIX_PROFILE/etc/profile && \
  mkdir -p /usr/local/bin && \
  ln -s /var/guix/profiles/per-user/root/current-guix/bin/guix /usr/local/bin/ && \
  mkdir -p /usr/local/share/info && \
  for i in /var/guix/profiles/per-user/root/current-guix/share/info/*; do ln -s $i /usr/local/share/info/; done && \
  guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub
RUN echo '#!/bin/sh' > /entrypoint && \
  echo 'source $GUIX_PROFILE/etc/profile' >> /entrypoint && \
  echo '~root/.config/guix/current/bin/guix-daemon --build-users-group=guixbuild &' >> /entrypoint && \
  echo 'exec "$@"' >> /entrypoint && \
  chmod +x /entrypoint
ENTRYPOINT ["/entrypoint"]
CMD ["sh"]
