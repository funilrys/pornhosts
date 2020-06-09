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
testfile="${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt"
debugfile="${TRAVIS_BUILD_DIR}/dev-tools/debug.list"
testDomains=$(git log --word-diff=porcelain -1 -p  -- submit_here/hosts.txt | \
  grep -e "^+" | tail -1 | cut -d "+" -f2 )

# These shouldnt be nessesary do to "PYFUNCEBLE_AUTO_CONFIGURATION: yes" in -travis
#pyfuncebleConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble.yaml"
#pyfuncebleProductionConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble_production.yaml"

RunFunceble () {

    #yeartag="$(date +%Y)"
    #monthtag="$(date +%m)"

    ulimit -u
    cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with RunFunceble\n\n"

    #if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    #then
        #rm "${pyfuncebleConfigurationFileLocation}"
        #rm "${pyfuncebleProductionConfigurationFileLocation}"
    #fi

        PyFunceble --ci -q -h -m -p "$(nproc --ignore=1)" \
	    -ex --plain --dns 95.216.209.53 -db --database-type mariadb \
            --autosave-minutes 38 --share-logs --http --idna --dots \
            --hierarchical --ci-branch master \
            --ci-distribution-branch master  \
            --commit-autosave-message "V1.${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
            --commit-results-message "V1.${version}.${TRAVIS_BUILD_NUMBER}" \
            --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
            -f "${testfile}"

}

SyntaxTest () {

	cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

	printf "\n\tYou are running with SyntaxTest\n\n"

	# If this MR is a removal, we check the remaining records for accidental
	# Errors where e.g. two lines have become one etc.
	# Therefor if no new domains $testDomains = empty, then test $testfile
	if [ -z "${testDomains}" ]
	then
		data="-f ${testfile}"
	else
		data="-d ${testDomains}"
	fi

    hash PyFunceble

	PyFunceble --ci -s -m -p "$(nproc --ignore=1)" \
		--autosave-minutes 38 --syntax \
		--hierarchical --ci-branch "${TRAVIS_PULL_REQUEST_BRANCH}" \
		--ci-distribution-branch "${TRAVIS_PULL_REQUEST_BRANCH}"  \
		--commit-autosave-message "${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
		--commit-results-message "${version}.${TRAVIS_BUILD_NUMBER}" \
		"${data}"
}

printf "\n%s\n" "${data}"

debugPyfunceble () {
	cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with debugPyfunceble\n\n"

    PyFunceble -a -m -p "$(nproc --ignore=1)" --share-logs \
		--autosave-minutes 38 --idna --hierarchical \
		--dns 127.0.0.1:5300 -f "${debugfile}"
}


if [ "$TRAVIS_PULL_REQUEST" != "false" ] && [[ ! "$(git log -1 | tail -1 | xargs)" =~ (debug|test) ]] # run on pull requests
then
	SyntaxTest | grep -qF "INVALID" | \
	  awk '{ printf("Failed domain:\n%s\n",$1) }' && exit 1 \
	  || printf "Build succeeded, your submission is good"

else
	if [[ "$(git log -1 | tail -1 | xargs)" =~ (debug|test) ]]
	then
		debugPyfunceble

	else
		RunFunceble
	fi
fi

exit ${?}
