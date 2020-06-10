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

# **********************************
# Setup input bots and referer lists
# **********************************

# Type the url of source here
#SOURCE=""
hostsFile="${TRAVIS_BUILD_DIR}/submit_here/hosts.txt"
snuff="${TRAVIS_BUILD_DIR}/submit_here/snuff.txt"
testFile="${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt"

# This following should be replaced by a local whitelist

WhiteList="${TRAVIS_BUILD_DIR}/whitelist"

getWhiteList () {
    wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list' \
    | awk '{ printf("%s\n",tolower($1)) }' >> "${WhiteList}"
    wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' \
    | awk '{ printf("ALL %s\n",tolower($1)) }' >> "${WhiteList}"
    sort -u -f "${WhiteList}" -o "${WhiteList}"
}
getWhiteList

# *********************************************
# Get Travis CI Prepared for Committing to Repo
# with the new --travis-commmit &
#
# *********************************************


#PrepareTravis () {
    # NOTE: Commented out because PyFunceble already handle that :-)
    #git remote rm origin
    #git remote add origin https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git
    #git config --global user.email "${GIT_EMAIL}"
    #git config --global user.name "${GIT_NAME}"
    #git config --global push.default simple
    #git checkout "${GIT_BRANCH}"
    #mysql --user=pyfunceble --password=pyfunceble pyfunceble < ${HOME}/db/pyfunceble.sql
    #git checkout -B pyfunceble-processing
    #ulimit -u
#}
#PrepareTravis

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************

PrepareLists () {

    mkdir -p "${TRAVIS_BUILD_DIR}/PULL_REQUESTS/"

    cat "${snuff}" >> "${testFile}"
    cat "${hostsFile}" >> "${testFile}"

    sort -u -f "${hostsFile}" -o "${hostsFile}"
    sort -u -f "${snuff}" -o "${snuff}"
    sort -u -f "${testFile}" -o "${testFile}"

    dos2unix "${testFile}"

 }
PrepareLists

head "${testFile}"

# ***********************************
# Deletion of all whitelisted domains
# ***********************************

WhiteListing () {
if [[ "$(git log -1 | tail -1 | xargs)" =~ "ci skip" ]]
	then
		hash uhb_whitelist
		mv "${testFile}" "${testFile}.tmp.txt"
		uhb_whitelist -wc -m -p $(nproc --ignore=1) -w "${WhiteList}" -f "${testfile}.tmp.txt" -o "${testFile}"
fi
}
WhiteListing

exit ${?}
