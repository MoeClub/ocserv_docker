#!/bin/sh
set -e

GroupName="${1:-NoRoute}"
PASSWORD="${2:-}"
Days="3650"

command -v openssl >/dev/null 2>&1
basePath=`readlink -f "$0"`
baseDir=`dirname "$basePath"`

serial=`printf '%04d' $(( $(od -An -N2 -tu2 /dev/urandom | tr -d ' ') % 10000 ))`
Name=`printenv NAME`
[ -n "$Name" ] || Name="$serial"

[ `printenv CA` = "1" ] && {
  openssl req -x509 -sha256 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days "${Days}" -subj "/C=/ST=/L=/OU=/O=/CN=${Name} CA" -addext "keyUsage=critical, keyCertSign, cRLSign" -rand /dev/urandom -outform PEM -keyout "${baseDir}/ca.key.pem" -out "${baseDir}/ca.crt.pem"
  printf '\nCA Crt: %s\nCA Key: %s\n\n' "${baseDir}/ca.crt.pem" "${baseDir}/ca.key.pem"
}

[ -f "${baseDir}/ca.crt.pem" ] && [ -f "${baseDir}/ca.key.pem" ] || exit 1

csr=`mktemp -u /tmp/XXXXXXXX`
key=`mktemp -u /tmp/XXXXXXXX`
crt=`mktemp -u /tmp/XXXXXXXX`
ext=`mktemp -u /tmp/XXXXXXXX`
trap "rm -rf ${csr} ${key} ${crt} ${ext}" EXIT

openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -subj "/C=/ST=/L=/OU=${GroupName}/O=/CN=${Name}" -rand /dev/urandom -outform PEM -keyout "${key}" -out "${csr}"
printf '%s\n' 'basicConstraints=CA:FALSE' 'keyUsage=digitalSignature' 'extendedKeyUsage=clientAuth' 'subjectKeyIdentifier=hash' 'authorityKeyIdentifier=keyid' >"${ext}"
openssl x509 -set_serial "${serial}" -CAform PEM -CA "${baseDir}/ca.crt.pem" -CAkey "${baseDir}/ca.key.pem" -req -sha256 -days "${Days}" -in "${csr}" -outform PEM -out "${crt}" -extfile "${ext}"
openssl pkcs12 --help 2>&1 |grep -q 'legacy' && legacy="-legacy" || legacy=""
openssl pkcs12 $legacy -export -inkey "${key}" -in "${crt}" -name "${GroupName}" -certfile "${baseDir}/ca.crt.pem" -caname "${GroupName} CA" -out "${baseDir}/${GroupName}.p12" -passout "pass:$PASSWORD"

printf '\nFile: %s\n' "${baseDir}/${GroupName}.p12"
[ -n "$PASSWORD" ] && printf 'Password: %s\n' "$PASSWORD"
printf '\n'
