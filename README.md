# RUN
```
docker run --name ocserv --privileged --restart always -e "NoRoute=abc:123" -d -p 443:443 ocserv/ocserv
docker run --name ocserv --privileged --restart always -v /mnt/ocserv:/mnt -d -p 443:443 ocserv/ocserv
docker run --privileged --rm -it -p 443:443/tcp -p 443:443/udp ocserv/ocserv

```

# Build
```
wget -qO /tmp/main.zip https://github.com/MoeClub/ocserv_docker/archive/refs/heads/main.zip
bsdtar -xf /tmp/main.zip --strip-components=1 -C /mnt
bash /mnt/build.sh 1.4.1 2.92

```
