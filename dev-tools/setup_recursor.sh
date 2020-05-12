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

# Since this systemd-resolved kill script also killed Travis we most change
# the default port of the recursor.... fuck!!!!!

grep -vE "^(#|$)" /etc/powerdns/recursor.conf

journalctl -xeu pdns_recursor -n 20

#sed -i "/local-address/d" "/etc/powerdns/recursor.conf"

#printf "local-address=0.0.0.0\nport=5300\n" >> "/etc/powerdns/recursor.conf"

systemctl restart pdns-recursor.service

# Why did recursor fail to load?
journalctl -xeu pdns_recursor -n 20

systemctl status pdns-recursor.service #| grep -iF "active (running)" >/dev/null || exit 1

# Let the recursor load the RPZ zone before testing it
sleep 5

# Check if the recursor is listening to port on port 5300
if lsof -i :5300 | grep -q '^pdns_'
then
	printf "\n\tThe recursor is running on port 5300
			\tWe carry on with our test procedure"
	exit 0
else
	printf "\n\tRecursor not running, We stops here\n"
	exit 1
fi

if drill 21x.org @127.0.0.1 -p 5300 | grep -qE "^21x\.org\."
then
	printf "\t\nResponse policy zone not loaded, we are done for this time"
	exit 1
else
	printf "\n\tPirated domains Response policy zone from https://www.mypdns.org/ is loaded... :smiley:"
	exit 0
fi


exit ${?}
