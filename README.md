# RUN
```
docker run --name ocserv --privileged --restart always -e "NoRoute=abc:123" -d -p 443:443 ocserv/ocserv
docker run --name ocserv --privileged --restart always -v /mnt/ocserv:/mnt -d -p 443:443 ocserv/ocserv
docker run --privileged --rm -it -p 443:443/tcp -p 443:443/udp ocserv/ocserv

```

# Build
```
# apt install libarchive-tools
wget -qO- https://github.com/MoeClub/ocserv_docker/archive/refs/heads/main.zip | bsdtar -xvf - --strip-components=1 -C /mnt
bash /mnt/build.sh 1.4.1 2.92

```
