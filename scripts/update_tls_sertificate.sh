#!/bin/bash

CERT_DATE=$(yc cm certificate get --id fpq5olab1sicrird32vp | awk '/not_after:/ {gsub(/"/, "", $2);  print $2}')
CERT_DATE_EPOCH=$(date --date=$CERT_DATE +"%s")
NOW_DATE_EPOCH=$(date  +"%s")

DIFF=$(( $CERT_DATE_EPOCH - $NOW_DATE_EPOCH ))
HOURS_TO_EXPIRE=$(( ( $DIFF / 60 ) / 60 ))

if [ $HOURS_TO_EXPIRE -ge 36 ]
then
  exit 0
fi

echo "HOURS_TO_EXPIRE=$HOURS_TO_EXPIRE"
echo "NEED TO SET NEW SERT"

mkdir /tmp/new_certs
CERT_CHAIN=/tmp/new_certs/certificate_full_chain.pem
CERT_KEY=/tmp/new_certs/private_key.pem
yc certificate-manager certificate content --name repotest --chain $CERT_CHAIN --key $CERT_KEY

SECRET_KEY=repotest_ru_private_key
SECRET_CHAIN=repotest_ru_certificate_full_chain

docker service rm i-am-production
docker secret rm $SECRET_KEY
docker secret rm $SECRET_CHAIN
docker secret create $SECRET_KEY $CERT_KEY
docker secret create $SECRET_CHAIN $CERT_CHAIN
docker service create --name i-am-production --secret source=$SECRET_CHAIN,target=/etc/ssl/certs/$SECRET_CHAIN.pem,mode=0400 --secret source=$SECRET_KEY,target=/etc/ssl/certs/$SECRET_KEY.pem,mode=0400 -p 443:8080 i-am-production

rm -rf /tmp/new_certs
