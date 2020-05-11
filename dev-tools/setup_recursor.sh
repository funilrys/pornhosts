#!/usr/bin/env bash

# Copyright: https://www.mypdns.org/
# Content: https://www.mypdns.org/p/Spirillen/
# Source: https://github.com/Import-External-Sources/pornhosts
# License: https://www.mypdns.org/w/license
# License Comment: GNU AGPLv3, MODIFIED FOR NON COMMERCIAL USE
#
# License in short:
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an
# issue at https://www.mypdns.org/maniphest/

set -e

printf "deb [arch=amd64] http://repo.powerdns.com/ubuntu %s-rec-master main\n" \
  "$(lsb_release -c | cut -f2)" > "/etc/apt/sources.list.d/pdns.list"

printf "Package: pdns-*\nPin: origin repo.powerdns.com\nPin-Priority: 600" > \
  "/etc/apt/preferences.d/pdns"

curl "https://repo.powerdns.com/CBC8B383-pub.asc" | sudo apt-key add - && \
  sudo apt-get update && \
  sudo apt-get install pdns-recursor ldnsutils

# Lets get rit of known deadbeats by loading the Response policy zone
# for known pirated domains

cp "${TRAVIS_BUILD_DIR}/dev-tools/recursor.lua" "/etc/powerdns/recursor.lua"

systemctl restart pdns-recursor.service

systemctl status pdns-recursor.service | grep -iF "active (running)" >/dev/null || exit 1



exit ${?}
