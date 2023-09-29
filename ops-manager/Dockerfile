FROM amd64/debian:unstable-slim

MAINTAINER Avery Davis <avery.davis@mongodb.com>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get install -y curl supervisor netcat-traditional procps net-tools

VOLUME /etc/mongodb-mms
VOLUME /opt/mongodb

RUN cd /tmp \
	&& curl -OL https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms-6.0.18.100.20230905T1424Z.amd64.deb \
	&& dpkg -i mongodb-mms-6.0.18.100.20230905T1424Z.amd64.deb \
    && rm mongodb-mms-6.0.18.100.20230905T1424Z.amd64.deb

COPY config/mms.conf /opt/mongodb/mms/conf/mms.conf
COPY config/conf-mms.properties /opt/mongodb/mms/conf/conf-mms.properties
COPY config/supervisord.conf /etc/supervisor/conf.d/ops-manager.conf

COPY startup.sh /tmp/startup.sh
RUN chmod +x /tmp/startup.sh

ENTRYPOINT [ "/tmp/startup.sh" ]
