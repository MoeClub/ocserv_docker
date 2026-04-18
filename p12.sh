#!/bin/sh
set -e

GroupName="${1:-NoRoute}"
PASSWORD="${2:-}"

command -v openssl >/dev/null 2>&1
basePath=`readlink -f "$0"`
baseDir=`dirname "$basePath"`
[ -f "${baseDir}/ca.crt.pem" ] && [ -f "${baseDir}/ca.key.pem" ] || exit 1


csr=`mktemp -u /tmp/XXXXXXXX`
key=`mktemp -u /tmp/XXXXXXXX`
crt=`mktemp -u /tmp/XXXXXXXX`
ext=`mktemp -u /tmp/XXXXXXXX`
trap "rm -rf ${csr} ${key} ${crt} ${ext}" EXIT

openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -subj "/C=/ST=/L=/OU=${GroupName}/O=/CN=${GroupName}" -rand /dev/urandom -outform PEM -keyout "${key}" -out "${csr}"
printf '%s\n' 'basicConstraints=CA:FALSE' 'keyUsage=digitalSignature' 'extendedKeyUsage=clientAuth' 'subjectKeyIdentifier=hash' 'authorityKeyIdentifier=keyid' >"${ext}"
openssl x509 -set_serial `printf '%04d' $(( $(od -An -N2 -tu2 /dev/urandom | tr -d ' ') % 10000 ))` -CAform PEM -CA "${baseDir}/ca.crt.pem" -CAkey "${baseDir}/ca.key.pem" -req -sha256 -days 3650 -in "${csr}" -outform PEM -out "${crt}" -extfile "${ext}"
openssl pkcs12 --help 2>&1 |grep -q 'legacy' && legacy="-legacy" || legacy=""
openssl pkcs12 $legacy -export -inkey "${key}" -in "${crt}" -name "${GroupName}" -certfile "${baseDir}/ca.crt.pem" -caname "${OrgName} CA" -out "${baseDir}/${GroupName}.p12" -passout "pass:$PASSWORD"

printf '\nFile: %s\n' "${baseDir}/${GroupName}.p12"
[ -n "$PASSWORD" ] && printf 'Password: %s\n' "$PASSWORD"
printf '\n'
