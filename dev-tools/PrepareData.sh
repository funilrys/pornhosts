#!/bin/bash
# This hosts file for DD-WRT Routers with DNSMasq is brought to you by
# https://www.mypdns.org/
# Copyright: Content: https://gitlab.com/spirillen
# Source:Content:
#
# Original attributes and credit
# This hosts file for DD-WRT Routers with DNSMasq is brought to you by Mitchell Krog
# Copyright:Code: https://github.com/mitchellkrogza
# Source:Code: https://github.com/mitchellkrogza/Badd-Boyz-Hosts
# The credit for the original bash scripts goes to Mitchell Krogza

# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.

# Please forward any additions, corrections or comments by logging an issue at
# https://gitlab.com/my-privacy-dns/support/issues

# **********************************
# Setup input bots and referer lists
# **********************************

# Type the url of source here
SOURCE=""
input1=${TRAVIS_BUILD_DIR}/source/hosts.txt
snuff=${TRAVIS_BUILD_DIR}/source/snuff.txt
testfile=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt

whitelist="$(wget -qO ${TRAVIS_BUILD_DIR}/whitelist 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list' && wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' >> ${TRAVIS_BUILD_DIR}/whitelist )"
# *********************************************
# Get Travis CI Prepared for Committing to Repo
# *********************************************

PrepareTravis () {
    git remote rm origin
    git remote add origin https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git
    git config --global user.email "${GIT_EMAIL}"
    git config --global user.name "${GIT_NAME}"
    git config --global push.default simple
    git checkout "${GIT_BRANCH}"
    ulimit -u
}
PrepareTravis

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************

PrepareLists () {

    mkdir ${TRAVIS_BUILD_DIR}/PULL_REQUESTS/

    cat ${snuff} >> ${testfile}
    cat ${input1} >> ${testfile}

    sort -u -f ${testfile} -o ${testfile}
    sort -u -f ${snuff} -o ${snuff}
    sort -u -f ${input1} -o ${input1}

    dos2unix ${input1}
 }
PrepareLists

# ***********************************
# Deletion of all whitelisted domains
# ***********************************

WhiteListing () {
    if [[ "$(git log -1 | tail -1 | xargs)" =~ "ci skip" ]]
        then
            hash uhb_whitelist
            uhb_whitelist -wc -w "${whitelist}" -f "${testfile}" -o "${testfile}"
    fi
}
WhiteListing

exit ${?}
