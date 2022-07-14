#!/usr/bin/env bash

# work dir
export WORK_DIR=$(cd `dirname $0`; pwd)

# stop etcd node docker
docker rm -f etcd1 || true
docker rm -f etcd2 || true
docker rm -f etcd3 || true

# clean etcd etcdctl
rm -rf ${WORK_DIR}/node1/etcd1.etcd
rm -rf ${WORK_DIR}/node1/etcd
rm -rf ${WORK_DIR}/node1/etcdctl
rm -rf ${WORK_DIR}/node1/benchmark

rm -rf ${WORK_DIR}/node2/etcd2.etcd
rm -rf ${WORK_DIR}/node2/etcd
rm -rf ${WORK_DIR}/node2/etcdctl
rm -rf ${WORK_DIR}/node2/benchmark

rm -rf ${WORK_DIR}/node3/etcd3.etcd
rm -rf ${WORK_DIR}/node3/etcd
rm -rf ${WORK_DIR}/node3/etcdctl
rm -rf ${WORK_DIR}/node3/benchmark
