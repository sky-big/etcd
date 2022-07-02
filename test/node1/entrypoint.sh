#!/usr/bin/env bash

/home/etcd/etcd --name etcd1 \
      --listen-client-urls http://127.0.0.1:12379 \
      --advertise-client-urls http://127.0.0.1:12379 \
      --listen-peer-urls http://127.0.0.1:12380 \
      --initial-advertise-peer-urls http://127.0.0.1:12380 \
      --initial-cluster-token etcd-cluster \
      --initial-cluster 'etcd1=http://127.0.0.1:12380,etcd2=http://127.0.0.1:22380,etcd3=http://127.0.0.1:32380' \
      --initial-cluster-state new \
      --enable-pprof \
      --logger=zap \
      --log-outputs=stderr