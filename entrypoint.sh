#!/bin/bash
set -e

function ensure_dir()
{
    for dir in "/var/run/elasticsearch" "/var/log/elasticsearch" "/var/opt/elasticsearch"; do
        mkdir -p $dir
        chown elasticsearch:elasticsearch $dir
    done
    for dir in "/var/run/logstash" "/var/log/logstash" "/var/opt/logstash"; do
        mkdir -p $dir
        chown logstash:logstash $dir
    done
    for dir in "/var/run/kibana" "/var/log/kibana" "/var/opt/kibana"; do
        mkdir -p $dir
        chown kibana:kibana $dir
    done
}

ensure_dir

exec "$@"