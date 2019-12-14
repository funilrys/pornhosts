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
input=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt
testfile=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt
pyfuncebleConfigurationFileLocation=${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble.yaml
pyfuncebleProductionConfigurationFileLocation=${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble_production.yaml

RunFunceble () {

    yeartag=$(date +%Y)
    monthtag=$(date +%m)
    ulimit -u
    cd ${TRAVIS_BUILD_DIR}/dev-tools

    hash PyFunceble

    if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    then
        rm "${pyfuncebleConfigurationFileLocation}"
        rm "${pyfuncebleProductionConfigurationFileLocation}"
    fi

    PyFunceble --travis -h -m -p 4 -db --database-type mariadb -ex --plain \
		--dns 127.0.0.1 --autosave-minutes 20 \
		--travis-branch pyfunceble-processing \
		--travis-distribution-branch master \
		--commit-autosave-message "V1.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
		--commit-results-message "V1.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER} [ci skip]" \
		--cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
		-f ${testfile}

}

RunFunceble

exit ${?}
