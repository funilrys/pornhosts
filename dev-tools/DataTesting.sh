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
TAG=$(V1.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER})
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

    PyFunceble --ci -h -m -p 4 -db --database-type mariadb -ex --plain \
		--dns 127.0.0.1 --autosave-minutes 40 \
		--ci-branch pyfunceble-processing \
		--ci-distribution-branch master \
		--ci-distribution-branch "${TAG}  [Auto Saved]" \
		--ci_autosave_final_commit "${TAG} [ci skip]" \
		--cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
		-f ${testfile}

}

RunFunceble

mkdir -p ${TRAVIS_BUILD_DIR}/db/
mysqldump --user=pyfunceble --password=pyfunceble --opt pyfunceble > ${TRAVIS_BUILD_DIR}/db/pyfunceble.sql

exit ${?}
