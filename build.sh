#!/bin/sh
set -e

ocVer="${1:-1.4.1}"
dnsVer="${2:-2.92}"
dockerBase="alpine:3.20"
dockerName="ocserv_build"

docker rm -f "${dockerName}" >/dev/null 2>&1;
docker run --name "${dockerName}" -id -v /mnt:/mnt "${dockerBase}"
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

# docker pull ocserv/ocserv:latest
# docker run --privileged --rm -it -p 443:443 ocserv/ocserv
# docker exec -it `docker ps -aq |head -n1` /bin/sh
# docker ps -aq |xargs docker rm -f
# docker images -aq |xargs docker rmi -f

