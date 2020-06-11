#!/usr/bin/env bash

# https://www.mypdns.org/
# Copyright: Content: https://gitlab.com/spirillen
# Source:Content:
#
# Original attributes and credit
# The credit for the original bash scripts goes to Mitchell Krogza
# Source:Code: https://github.com/mitchellkrogza/Badd-Boyz-Hosts
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.

# Please forward any additions, corrections or comments by logging an issue at
# https://gitlab.com/my-privacy-dns/support/issues

set -e -x

# **********************************
# Setup input bots and referer lists
# **********************************

# Type the url of source here
testFile="${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt"

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************
getNewList () {
	dig +noidnout axfr @35.156.219.71 -p 53 porn.host.srv \
	  | grep -vE "^(;|$|\*)" | sed -e 's/porn\.host\.srv\.//g' \
	  | awk '{ printf ("%s\n",tolower($1))}' \
	  | sed -e 's/\.$//g' > "${testFile}"
}

head "${testFile}"

# ***********************************
# Deletion of all whitelisted domains
# ***********************************
# This following should be replaced by a local whitelist

WhiteList="${TRAVIS_BUILD_DIR}/whitelist"

getWhiteList () {
    wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list' \
    | awk '{ printf("%s\n",tolower($1)) }' >> "${WhiteList}"
    wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' \
    | awk '{ printf("ALL %s\n",tolower($1)) }' >> "${WhiteList}"
    sort -u -f "${WhiteList}" -o "${WhiteList}"
}

WhiteListing () {
	hash uhb_whitelist
	mv "${testFile}" "${testFile}.tmp.txt"
	uhb_whitelist -wc -m -p $(nproc --ignore=1) -w "${WhiteList}" -f "${testfile}.tmp.txt" -o "${testFile}"
}

if [[ "$(git log -1 | tail -1 | xargs)" ! =~ "auto" ]]
	then
	getNewList && \
	  getWhiteList && \
	  WhiteListing
fi

exit ${?}
