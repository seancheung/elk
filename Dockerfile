FROM ubuntu:16.04
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG CN_MIRROR
ARG ELK_VERSION=6.1.1

RUN if [ -n "$CN_MIRROR" ]; then mv /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list; \
    fi

RUN mkdir -p /tmp \
    && cd /tmp \
    && set -x \
    && apt-get update \
    && export DEBIAN_FRONTEND="noninteractive" \
    && echo "Install Dependencies..." \
    && apt-get install -y --no-install-recommends wget ca-certificates openjdk-8-jre bash git openssl supervisor make g++ \
    && echo "Download [Elasticsearch]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELK_VERSION.deb.sha512 \
    && shasum -a 512 -c elasticsearch-$ELK_VERSION.deb.sha512 \
    && dpkg -i elasticsearch-$ELK_VERSION.deb \
    && echo "Download [Logstash]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-$ELK_VERSION.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-$ELK_VERSION.deb.sha512 \
    && shasum -a 512 -c logstash-$ELK_VERSION.deb.sha512 \
    && dpkg -i logstash-$ELK_VERSION.deb \
    && echo "Download [Kibana]..." \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/kibana/kibana-$ELK_VERSION-amd64.deb \
    && wget --progress=bar:force https://artifacts.elastic.co/downloads/kibana/kibana-$ELK_VERSION-amd64.deb.sha512 \
    && shasum -a 512 -c kibana-$ELK_VERSION-amd64.deb.sha512 \
    && dpkg -i kibana-$ELK_VERSION-amd64.deb \
    && echo "Clone and compile [su-exec]..." \
    && git clone --depth=1 https://github.com/ncopa/su-exec.git /tmp/su-exec \
    && make -C /tmp/su-exec \
    && mv /tmp/su-exec/su-exec /sbin/su-exec \
    && chmod +x /sbin/su-exec \
    && echo "Clean Up..." \
    && apt-get remove --purge -y make g++ git wget \
    && apt autoremove -y \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV PATH /usr/share/logstash/bin:$PATH
ENV PATH /usr/share/kibana/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64

COPY supervisord.conf /etc/
COPY entrypoint.sh /entrypoint.sh
COPY logstash-log4js.conf /var/opt/logstash/

VOLUME ["/var/opt/elasticsearch", "/var/opt/logstash"]
EXPOSE 9200 9300 5601 5000 5000/udp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]