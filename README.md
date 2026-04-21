# Run
```
docker run --name ocserv --privileged --restart always -e "NoRoute=abc:123" -d -p 443:443 ocserv/ocserv
docker run --name ocserv --privileged --restart always -v /mnt/ocserv:/mnt -d -p 443:443 ocserv/ocserv
docker run --privileged --rm -it -p 443:443/tcp -p 443:443/udp ocserv/ocserv

```

# Crt.p12
```
docker cp ocserv:/etc/ocserv/ca.crt.pem /mnt/ca.crt.pem
docker cp ocserv:/etc/ocserv/ca.key.pem /mnt/ca.key.pem

sh /mnt/p12.sh NoRoute passwd

```

# Build
```
# apt install libarchive-tools
wget -qO- https://github.com/MoeClub/ocserv_docker/archive/refs/heads/main.zip | bsdtar -xvf - --strip-components=1 -C /mnt
bash /mnt/buildx.sh 1.4.1 2.92

```


