#!/usr/bin/env bash

# work dir
export WORK_DIR=$(cd `dirname $0`; pwd)

# start prometheus
docker run -d \
    --name prometheus \
    -v "${WORK_DIR}/prometheus/prometheus.yml":/etc/prometheus/prometheus.yml \
    prom/prometheus:v2.17.2

# start grafana
docker run -d \
    --name grafana \
    -v "${WORK_DIR}/grafana/grafana.ini":/etc/grafana/grafana.ini \
    -v "${WORK_DIR}/grafana/plugins":/var/lib/grafana/plugins \
    grafana/grafana:latest