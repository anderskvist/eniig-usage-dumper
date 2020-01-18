#!/bin/bash

ACCOUNTNUM=${1}
INTERNETCODE=${2}
METERINGPOINT=${3}
DATE=${4}

BASICAUTH=$(echo -n ${ACCOUNTNUM}:${INTERNETCODE}|base64)

TEMPFILEPREFIX=/tmp/$(date +%s%N|sha256sum|awk '{print $1}')

function get_variable () {
    cat - | sed 's/,/\n/g' | grep ${1} | cut -d":" -f2 | sed 's/\"//g'
}

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

AUTH=$(cat ${TEMPFILEPREFIX}.auth | get_variable auth)
rm -f ${TEMPFILEPREFIX}.auth

{
    curl "https://mit.eniig.dk/Core/Customer/GetCustomers/?username=${ACCOUNTNUM}@eniig.dk" \
	 -H 'Accept-Encoding: gzip, deflate, sdch, br' \
	 -H 'Accept-Language: en-US,en;q=0.8,da;q=0.6' \
	 -H "Authorization: ${AUTH}" \
	 -H 'Accept: application/json, text/plain, */*' \
	 -H 'Referer: https://mit.eniig.dk/' \
	 -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.74 Safari/537.36' \
	 -H 'Connection: keep-alive' \
	 -H "Authentication: Basic ${BASICAUTH}" \
	 --compressed \
	 --silent
} > ${TEMPFILEPREFIX}.customer

PERM=$(cat ${TEMPFILEPREFIX}.customer | get_variable permissionId)
rm -f ${TEMPFILEPREFIX}.customer



{
    curl "https://mit.eniig.dk/Core/Consumption/GetMeteringPoints/?permissionId=${PERM}" \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'Accept-Language: en-US,en;q=0.9,da-DK;q=0.8,da;q=0.7' \
	-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36' \
	-H 'Accept: application/json, text/plain, */*' \
	-H "Authorization: ${AUTH}" \
	-H 'Connection: keep-alive' \
	--compressed
} > ${TEMPFILEPREFIX}.meteringpoints

{
    curl "https://mit.eniig.dk/Core/Consumption/GetConsumptionByMeteringPoint/?consumerNumber=6&meteringPoint=${METERINGPOINT}&permissionId=${PERM}&selectedPeriod=${DATE}&timeResolution=1" \
	 -H 'Accept-Encoding: gzip, deflate, sdch, br' \
	 -H 'Accept-Language: en-US,en;q=0.8,da;q=0.6' \
	 -H "Authorization: ${AUTH}" \
	 -H 'Accept: application/json, text/plain, */*' \
	 -H 'Referer: https://mit.eniig.dk/' \
	 -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.74 Safari/537.36' \
	 -H 'Connection: keep-alive' \
	 --compressed \
	 --silent
}
