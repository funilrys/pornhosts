#!/bin/bash
# **********************
# Run PyFunceble Testing
# **********************
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza

# ****************************************************************
# This uses the awesome PyFunceble script created by Nissar Chababy
# Find funceble at: https://github.com/funilrys/PyFunceble
# ****************************************************************

# **********************
# Setting date variables
# **********************

yeartag=$(date +%Y)
monthtag=$(date +%m)

# ******************
# Set our Input File
# ******************
#input=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt
testfile="${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt"
#testfile="${TRAVIS_BUILD_DIR}/dev-tools/debug.list"
pyfuncebleConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble.yaml"
pyfuncebleProductionConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble_production.yaml"

RunFunceble () {

    #yeartag="$(date +%Y)"
    #monthtag="$(date +%m)"
    TAG="$(V1.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER})"
    ulimit -u
    cd "${TRAVIS_BUILD_DIR}/dev-tools"

    hash PyFunceble

    if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    then
        rm "${pyfuncebleConfigurationFileLocation}"
        rm "${pyfuncebleProductionConfigurationFileLocation}"
    fi

        PyFunceble --ci -h -m -p 4 -db --database-type mariadb -ex --plain --dns 127.0.0.1 \
            --autosave-minutes 20 --share-logs --http --idna --ci-branch master \
            --ci-distribution-branch master \
            --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
            --commit-autosave-message "V1.${TAG} [Auto Saved]" \
            --commit-results-message "V1.${TAG}" \
            -f "${testfile}"

}

RunFunceble

exit ${?}
