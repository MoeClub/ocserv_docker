#!/bin/sh
set -e

ocVer="${1:-1.4.1}"
dnsVer="${2:-2.92}"
dockerName="ocserv_build"

docker rm -f "${dockerName}" >/dev/null 2>&1;
docker run --name "${dockerName}" -id -v /mnt:/mnt alpine:3.20
docker exec "${dockerName}" /bin/sh /mnt/commit.sh "${ocVer}" "${dnsVer}"
docker commit --change 'CMD ["/bin/sh", "/run.sh"]' "${dockerName}" "ocserv:${ocVer}"
docker tag "ocserv:${ocVer}" ocserv:latest
docker rm -f "${dockerName}" >/dev/null 2>&1;

userName="$(docker info 2>/dev/null |grep 'Username:' |cut -d':' -f2 |sed 's/[[:space:]]//g')"
[ -n "$userName" ] || exit 0
docker tag ocserv:latest "${userName}/ocserv:latest"
docker push "${userName}/ocserv:latest"
docker tag ocserv:latest "${userName}/ocserv:${ocVer}"
docker push "${userName}/ocserv:${ocVer}"

# docker run --privileged --rm -it -p 443:443 ocserv/ocserv
# docker ps -aq |xargs docker rm -f
# docker images -aq |xargs docker rmi -f
