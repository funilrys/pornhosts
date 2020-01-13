#!/usr/bin/env bash
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

# ***********************************************************
# echo Remove our inactive and invalid domains from PULL_REQUESTS
# ***********************************************************

printf "\n\tRunning FinalCommit.sh\n"

#cat ${TRAVIS_BUILD_DIR}/dev-tools/output/domains/ACTIVE/list | grep -v "^$" | grep -v "^#" > tempdomains.txt
#mv tempdomains.txt ${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt

if [ -f "${TRAVIS_BUILD_DIR}/dev-tools/output/domains/INACTIVE/list" ]
then
  grep -Ev "^($|#)" "${TRAVIS_BUILD_DIR}/dev-tools/output/domains/INACTIVE/list" > "${TRAVIS_BUILD_DIR}/submit_here/apparently_inactive.txt"
fi

#exit 0

# ***************************************************************************
echo Generate our host file
# ***************************************************************************

exit 0

#bash ${TRAVIS_BUILD_DIR}/dev-tools/UpdateReadme.sh
bash "${TRAVIS_BUILD_DIR}/dev-tools/GenerateHostsFile.sh"

# *************************************************************
# Travis now moves to the before_deploy: section of .travis.yml
# *************************************************************

exit ${?}
