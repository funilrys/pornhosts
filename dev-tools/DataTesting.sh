#!/usr/bin/env bash

# **********************
# Run PyFunceble Testing
# **********************
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza

# ****************************************************************
# This uses the awesome PyFunceble script created by Nissar Chababy
# Find PyFunceble at: https://github.com/funilrys/PyFunceble
# ****************************************************************

# **********************
# Setting date variables
# **********************

version=$(date +%Y.%m)

# ******************
# Set our Input File
# ******************
testFile="${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt"
#testFile="${TRAVIS_BUILD_DIR}/dev-tools/debug.list"

RunFunceble () {

    #yeartag="$(date +%Y)"
    #monthtag="$(date +%m)"

    #ulimit -u
    cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with RunFunceble\n\n"

        PyFunceble --ci -q -h -m -p "$(nproc --ignore=1)" \
	    -ex --plain --dns 95.216.209.53 127.0.0.1:5300 8.8.8.8 8.8.4.4 -db --database-type mariadb \
            --autosave-minutes 38 --share-logs --http --idna --dots \
            --hierarchical --ci-branch "${TRAVIS_BRANCH}" \
            --ci-distribution-branch "${TRAVIS_BRANCH}" \
            --commit-autosave-message "V1.${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
            --commit-results-message "V1.${version}.${TRAVIS_BUILD_NUMBER}" \
            --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
            -f "${testFile}"

}
RunFunceble

exit ${?}
