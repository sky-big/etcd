#!/usr/bin/env bash

# work dir
export WORK_DIR=$(cd `dirname $0`; pwd)

# stop prometheus
docker rm -f prometheus

# stop grafana
docker rm -f grafana