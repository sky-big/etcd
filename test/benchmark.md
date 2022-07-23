# command

```
./benchmark --endpoints=http://127.0.0.1:12379,http://127.0.0.1:22379,http://127.0.0.1:32379 --conns=100 --clients=10 put --key-size=8 --sequential-keys --total=1000 --val-size=256
```

```
./benchmark --endpoints=http://172.17.0.2:12379,http://172.17.0.3:22379,http://172.17.0.4:32379 --conns=100 --clients=10 put --key-size=8 --sequential-keys --total=1000000 --val-size=256
```
