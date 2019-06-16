FROM chaznet/armhf-ubuntu:18.04
MAINTAINER sameer@damagehead.com, chaz

ENV APT_CACHER_NG_VERSION=3.1 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget apt-cacher-ng=${APT_CACHER_NG_VERSION}* gnupg dirmngr \
 && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
 && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
 && rm -rf /var/lib/apt/lists/*

ENV TINI_VERSION v0.18.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /usr/local/bin/tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf.asc /tmp/tini.asc

RUN cd /tmp \
 && wget 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9A84159D7001A4E5' -O /tmp/key.key \
 && gpg --import /tmp/key.key \
 && gpg --batch --verify /tmp/tini.asc /usr/local/bin/tini \
 && chmod +x /usr/local/bin/tini \
 && rm /tmp/tini.asc

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/apt-cacher-ng"]
