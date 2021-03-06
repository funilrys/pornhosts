#!/usr/bin/env bash
# https://www.mypdns.org/
# Copyright: Content: https://gitlab.com/spirillen
# Source:Content:
#
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an 
# issue at https://gitlab.com/my-privacy-dns/support/issues

# Based on https://stackoverflow.com/a/12643187

file=$1

# helper function to create a directory from an array
mkDirs(){
    IFS=/ dir="$*"
    echo "mkdir -p $dir"
}

declare -a stack=()
while read line
do
    dirName="${line##*| }"
    pipes="${line//[^|]/}"
    num_pipes="${#pipes}"
    diff=$(( ${#stack[@]} - $num_pipes ))
    if [[ "$diff" -ne 0 ]]
    then
        # create the directory
        mkDirs "${stack[@]}"
        while (( "$diff" != 0 ))
        do
            unset stack[${#stack[@]}-1] # pop off stack
            diff=$(( ${#stack[@]} - $num_pipes ))
        done
    fi
    stack=("${stack[@]}" "$dirName") # push on stack
done < "$file"
mkDirs "${stack[@]}"

exit ${?}
