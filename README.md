# RUN
```
docker run --name ocserv --privileged --restart always -d -p 443:443 ocserv:latest
docker run --privileged --rm -it -p 443:443/tcp -p 443:443/udp ocserv:latest

```

# Build
```
bash /mnt/build.sh 1.4.1 2.92

```
