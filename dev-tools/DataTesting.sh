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
		--dns 127.0.0.1 --autosave-minutes 20 --share-logs\
		--ci-branch pyfunceble-processing \
		--ci-distribution-branch master \
		--commit-autosave-message "${TAG}  [Auto Saved]" \
		--commit-results-message "${TAG} [ci skip]" \
		--cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
		-f ${testfile}

}

RunFunceble

UpLoadDb () {
mkdir -p ${TRAVIS_BUILD_DIR}/db/
mysqldump --user=pyfunceble --password=pyfunceble --opt pyfunceble > ${TRAVIS_BUILD_DIR}/db/pyfunceble.sql
mysqldump --user=pyfunceble --password=pyfunceble --opt pyfunceble > ${TRAVIS_BUILD_DIR}/dev-tools/pyfunceble.sql


git remote add origin https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_NAME}"
git config --global push.default simple
git checkout "${GIT_BRANCH}"
git add ${TRAVIS_BUILD_DIR}/dev-tools/pyfunceble.sql
git commit -m "update sql"
git push origin HEAD:${TRAVIS_BRANCH}
}
UpLoadDb

ls -lh ${TRAVIS_BUILD_DIR}/db/

exit ${?}
