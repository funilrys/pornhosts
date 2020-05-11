#!/usr/bin/env bash

set -e

RELEASE=$(lsb_release -c | cut -f2)

printf "deb [arch=amd64] http://repo.powerdns.com/ubuntu $RELEASE-rec-master main" > "/etc/apt/sources.list.d/pdns.list"

printf "Package: pdns-*\nPin: origin repo.powerdns.com\nPin-Priority: 600" > "/etc/apt/preferences.d/pdns"

curl "https://repo.powerdns.com/CBC8B383-pub.asc" | sudo apt-key add - && \
  sudo apt-get update && \
  sudo apt-get install pdns-recursor

cp "${TRAVIS_BUILD_DIR}/dev-tools/recursor.lua" "/etc/powerdns/recursor.lua"

systemctl restart pdns-recursor.service

systemctl status pdns-recursor.service | grep -iF "active (running)" >/dev/null && exit 0 || exit 1

exit ${?}
