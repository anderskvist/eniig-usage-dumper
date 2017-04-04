#!/bin/bash

ACCOUNTNUM=${1}
INTERNETCODE=${2}

TEMPFILEPREFIX=/tmp/$(date +%s%N|sha256sum|awk '{print $1}')

{
    curl 'https://mit.eniig.dk/Core/Login/Authenticate' \
	 -H 'Origin: https://mit.eniig.dk' \
	 -H 'Accept-Encoding: gzip, deflate, br' \
	 -H 'Accept-Language: en-US,en;q=0.8,da;q=0.6' \
	 -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.74 Safari/537.36' \
	 -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
	 -H 'Accept: */*' \
	 -H 'Referer: https://mit.eniig.dk/' \
	 -H 'X-Requested-With: XMLHttpRequest' \
	 -H 'Connection: keep-alive' \
	 --data "accountNum=${ACCOUNTNUM}&internetCode=${INTERNETCODE}&loginType=accountNum" \
	 --compressed \
	 --silent
} > ${TEMPFILEPREFIX}.auth

AUTH=$(cat ${TEMPFILEPREFIX}.auth | python -mjson.tool | grep "\"auth\": " | cut -d"\"" -f4)
rm -f ${TEMPFILEPREFIX}.auth

echo ${AUTH}
