FROM ubuntu:jammy

MAINTAINER Avery Davis <avery.davis@mongodb.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" >> /etc/apt/sources.list.d/mongodb-org-6.0.list;

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		dirmngr \
		gnupg \
		jq \
		numactl \
        curl \
        libcurl4 \
		procps; \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
       gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
       --dearmor



RUN apt-get install -y  libldap-common  \
     libgssapi-krb5-2 liblzma5 libsasl2-2 libsasl2-modules \
     libsasl2-modules-gssapi-mit libwrap0 openssl snmp ;

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -eux; \
	groupadd --gid 999 --system mongodb; \
	useradd --uid 999 --system --gid mongodb --home-dir /data/db mongodb; \
	mkdir -p /data/db /data/configdb /data/logs /data/pkgs /data/journal \
         /var/run/mongodb /etc/mongodb-mms; \
    touch /var/run/mongodb/mongod.pid; \
	chown -R mongodb:mongodb /data; \
    chown -R mongodb:mongodb /var/run/mongodb; \
    chown -R mongodb:mongodb /etc/mongodb-mms

COPY pkg/mongodb-mms-automation-agent-12.0.26.7740-1.amzn2_aarch64.tar.gz /opt/mongodb-mms-automation-agent-12.0.26.7740-1.amzn2_aarch64.tar.gz

RUN cd /opt \
    && tar -xvf mongodb-mms-automation-agent-12.0.26.7740-1.amzn2_aarch64.tar.gz \
    && rm mongodb-mms-automation-agent-12.0.26.7740-1.amzn2_aarch64.tar.gz

COPY startup.sh /tmp/startup.sh
RUN chmod +x /tmp/startup.sh

EXPOSE 27017

ENTRYPOINT [ "/tmp/startup.sh" ]

