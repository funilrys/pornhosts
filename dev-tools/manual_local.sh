#!/usr/bin/env bash

# Copyright: https://www.mypdns.org/
# Content: https://gitlab.com/spirillen
# Source: https://github.com/Import-External-Sources/pornhosts
# License: https://www.mypdns.org/wiki/License
# License Comment: GNU AGPLv3, MODIFIED FOR NON COMMERCIAL USE
#
# License in short:
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an 
# issue at https://github.com/mypdns/matrix/issues

pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do cd `dirname "$SCRIPT_PATH"`; SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
cd `dirname ${SCRIPT_PATH}.` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

ROOT_DIR="$(dirname "$SCRIPT_PATH")"

cd "${SCRIPT_PATH}"

PythonVersion () {
if grep --quiet -F 'python3.8' $(which python3.8)

	then
		python3=$(which python3.8)

elif 

	grep --quiet -F 'python3.7' $(which python3.7)

	then
		python3=$(which python3.7)

elif

	grep --quiet -F 'python3.6' $(which python3.6)

	then
		printf "\nPyFunceble requires python >=3.7"
		exit 99
else
	printf "\n\tPyFunceble requires Python >=3.7"
	exit 99
fi
}
PythonVersion

# ***********************************
# Setup input bots and referrer lists
# ***********************************

input="${ROOT_DIR}/submit_here/hosts.txt"
snuff="${ROOT_DIR}/submit_here/snuff.txt"
testfile="${ROOT_DIR}/PULL_REQUESTS/domains.txt"

# This should be replaced by a local whitelist

#whitelist="$(wget -qO ${ROOT_DIR}/whitelist 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list' > ${ROOT_DIR}/whitelist && wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' >> ${ROOT_DIR}/whitelist )"

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************

PrepareLists () {

    mkdir -p "${ROOT_DIR}/PULL_REQUESTS/"

    cat "${snuff}" >> "${testfile}"
    cat "${input}" >> "${testfile}"

    sort -u -f "${input}" -o "${input}"
    sort -u -f "${snuff}" -o "${snuff}"
    sort -u -f "${testfile}" -o "${testfile}"

    dos2unix "${testfile}"
 }
PrepareLists

# ***********************************
# Deletion of all whitelisted domains
# ***********************************

#WhiteListing () {
    #if [[ "$(git log -1 | tail -1 | xargs)" =~ "ci skip" ]]
        #then
            #hash uhb_whitelist
            #uhb_whitelist -wc -w "${whitelist}" -f "${testfile}" -o "${testfile}"
    #fi
#}
#WhiteListing

pyfuncebleConfigurationFileLocation="${SCRIPT_PATH}/.PyFunceble.yaml"
pyfuncebleProductionConfigurationFileLocation="${SCRIPT_PATH}/.PyFunceble_production.yaml"

RunFunceble () {
  PyFunceble=$(which PyFunceble)
  
  cd "${SCRIPT_PATH}"
  
  hash PyFunceble

    if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    then
        rm "${pyfuncebleConfigurationFileLocation}"
        rm "${pyfuncebleProductionConfigurationFileLocation}"
    fi

  "${python3}" "$PyFunceble" -h -m -p $(nproc --ignore=1) -db --database-type mariadb \
    -ex --plain --dns 192.168.1.100 --share-logs --http --idna \
    --hierarchical -f "${testfile}"
}
RunFunceble

if [ -f "${SCRIPT_PATH}/output/domains/INACTIVE/list" ]
then
  grep -Ev "^($|#)" "${SCRIPT_PATH}/output/domains/INACTIVE/list" > "${ROOT_DIR}/submit_here/apparently_inactive.txt"
fi

if [ -f "${SCRIPT_PATH}/output/domains/ACTIVE/list" ]
then
  mkdir -p "${ROOT_DIR}/0.0.0.0/"
  awk '/^(#|$)/{ next }; { printf("0.0.0.0\t%s\n",tolower($1)) }' "${SCRIPT_PATH}/output/domains/ACTIVE/list" > "${ROOT_DIR}/0.0.0.0/hosts"
fi

printf "${ROOT_DIR}\n"

#head "${input}"
