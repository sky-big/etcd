#!/usr/bin/env bash

# work dir
export WORK_DIR=$(cd `dirname $0`; pwd)

# prepare etcd etcdctl benchmark
cp ./etcd ${WORK_DIR}/node1/
cp ./etcdctl ${WORK_DIR}/node1/
cp ./benchmark ${WORK_DIR}/node1/

cp ./etcd ${WORK_DIR}/node2/
cp ./etcdctl ${WORK_DIR}/node2/
cp ./benchmark ${WORK_DIR}/node2/

cp ./etcd ${WORK_DIR}/node3/
cp ./etcdctl ${WORK_DIR}/node3/
cp ./benchmark ${WORK_DIR}/node3/

# start etcd node1
docker run -d \
    --name etcd1 \
    -w /home/etcd \
    -v "${WORK_DIR}/node1":/home/etcd \
    centos:7 \
    /home/etcd/entrypoint.sh

# start etcd node2
docker run -d \
    --name etcd2 \
    -w /home/etcd \
    -v "${WORK_DIR}/node2":/home/etcd \
    centos:7 \
    /home/etcd/entrypoint.sh

# start etcd node3
docker run -d \
    --name etcd3 \
    -w /home/etcd \
    -v "${WORK_DIR}/node3":/home/etcd \
    centos:7 \
    /home/etcd/entrypoint.sh