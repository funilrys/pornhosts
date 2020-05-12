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
  grep -e "^+" | tail -1 | awk -F "+" '{ printf("%s ",$2) }' )

# These shouldnt be nessesary do to "PYFUNCEBLE_AUTO_CONFIGURATION: yes" in -travis
#pyfuncebleConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble.yaml"
#pyfuncebleProductionConfigurationFileLocation="${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble_production.yaml"

RunFunceble () {

    #yeartag="$(date +%Y)"
    #monthtag="$(date +%m)"

    ulimit -u
    cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with default Pyfunceble\n\n"

    #if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    #then
        #rm "${pyfuncebleConfigurationFileLocation}"
        #rm "${pyfuncebleProductionConfigurationFileLocation}"
    #fi

        PyFunceble --ci -q -h -m -p "$(nproc --ignore=1)" \
			-ex --plain --dns 127.0.0.1:5300 \
            --autosave-minutes 38 --share-logs --http --idna --dots \
            --hierarchical --ci-branch processing \
            --ci-distribution-branch master  \
            --commit-autosave-message "V1.${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
            --commit-results-message "V1.${version}.${TRAVIS_BUILD_NUMBER}" \
            --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
            -f "${testfile}"

}

SyntaxTest () {

    cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with Syntax test\n\n"

	if [ -z "${testDomains}" ]
	then
		data="-f ${testfile}"
	else
		data="-d ${testDomains}"
	fi

	PyFunceble --ci -s -m -p "$(nproc --ignore=1)" \
		--autosave-minutes 38 --syntax \
		--hierarchical --ci-branch "${TRAVIS_PULL_REQUEST_BRANCH}" \
		--ci-distribution-branch "${TRAVIS_PULL_REQUEST_BRANCH}"  \
		--commit-autosave-message "${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
		--commit-results-message "${version}.${TRAVIS_BUILD_NUMBER}" \
		${data}
}

debugPyfunceble () {
	cd "${TRAVIS_BUILD_DIR}/dev-tools" || exit 1

    hash PyFunceble

	printf "\n\tYou are running with Debug Pyfunceble\n\n"

    PyFunceble -a -m -p "$(nproc --ignore=1)" --share-logs \
		--autosave-minutes 38 --idna --hierarchical \
		--dns 127.0.0.1:5300 -f "${debugfile}"
}


if [ "$TRAVIS_PULL_REQUEST" != "false" ] # run on pull requests
then
	SyntaxTest | grep -qF "INVALID" | \
	  awk '{ printf("Failed domain:\n%s\n",$1) }' && exit 1 \
	  || printf "Build succeeded, your submission is good" && exit 0

else
	if [ "$TRAVIS_PULL_REQUEST" = "false" ] && [ -z "${testDomains}" ] || [[ "$(git log -1 | tail -1 | xargs)" =~ (debug|test) ]]
	then
		debugPyfunceble

	else
		RunFunceble
	fi
fi

#if [ "$TRAVIS_PULL_REQUEST" = "false" ] # run on non pull requests
	#then
	#RunFunceble

	#else
	#if [[ "$(DEBUG_PYFUNCEBLE|DEBUG_PYFUNCEBLE_ON_SCREEN)" = "true" ]]
	#then
		#debugPyfunceble

	#else
		#if [ "$TRAVIS_PULL_REQUEST" != "false" ] # run on pull requests
		#then
		#SyntaxTest | grep --quiet -F "INVALID" | awk '{ printf("Failed domain:\n%s\n",tolower($1)) }' && exit 10 \
		  #|| printf "Build succeeded, your submission is good" && exit 0
		#fi
	#fi
#fi

exit ${?}
