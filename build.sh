#!/bin/sh
set -e

ocVer="${1:-1.4.1}"
dnsVer="${2:-2.92}"
dockerBase="alpine:3.20"
dockerName="ocserv_build"

case `uname -m` in aarch64|arm64) arch="arm64";; x86_64|amd64) arch="amd64";; *) arch="";; esac
[ -n "$arch" ] || exit 1

docker rm -f "${dockerName}" >/dev/null 2>&1;
docker run --name "${dockerName}" -id -v /mnt:/mnt "${dockerBase}"
docker exec "${dockerName}" /bin/sh /mnt/commit.sh "${ocVer}" "${dnsVer}"
docker commit --change 'CMD ["/bin/sh", "/run.sh"]' "${dockerName}" "ocserv:${ocVer}"
docker tag "ocserv:${ocVer}" "${arch}:latest"
docker rm -f "${dockerName}" >/dev/null 2>&1;

userName="$(docker info 2>/dev/null |grep 'Username:' |cut -d':' -f2 |sed 's/[[:space:]]//g')"
[ -n "$userName" ] || exit 0
docker tag "${arch}:latest" "${userName}/${arch}:latest"
docker push "${userName}/${arch}:latest"
docker tag "${arch}:latest" "${userName}/${arch}:${ocVer}"
docker push "${userName}/${arch}:${ocVer}"


# ver="latest" && docker manifest create "ocserv/ocserv:${ver}" --amend "ocserv/amd64:${ver}" --amend "ocserv/arm64:${ver}" && docker manifest push -p "ocserv/ocserv:${ver}"

# docker pull ocserv/ocserv:latest
# docker run --privileged --rm -it -p 443:443 ocserv/ocserv
# docker exec -it `docker ps -aq |head -n1` /bin/sh
# docker ps -aq |xargs docker rm -f
# docker images -aq |xargs docker rmi -f

