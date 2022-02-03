#!/usr/bin/env bash

# Author: Alex Baranowski
# License: MIT
# Desc: This script uses repoquery to ask about packages available in repos then
# print how many of them were built in last 14 days -> see MAX_DAYS variable
# By default only BaseOS and AppStream are used

# sudo -> RHEL subscription-manager require root access to refresh repos

# be strict
set -euo pipefail

MAX_DAYS="14 days ago"
TMP_FILE=$(mktemp)

trap clean_tmp_file EXIT

prepare_env(){
    sudo yum install -y yum-utils
}

clean_tmp_file(){
    echo "Cleaning -> $TMP_FILE"
    rm -f "$TMP_FILE"
}

get_packages_with_build_date(){
    sudo yum clean all
    sudo repoquery  --queryformat '%{name} %{buildtime}' > $TMP_FILE
}

number_of_fresh_packages(){
    # Ohh date parsing in Bash lovely
    FRESH_PKG_COUNTER=0
    MAX_DATE_EPOCH=$(date --date "$MAX_DAYS" '+%s')
    while IFS= read -r line; do
        # FIX for RHEL "Updating Subscription Management repositories and other strings" 
        if [ $( echo "$line" | wc -w ) -ne 3 ]; then
            echo "Skipping line -> '$line'"
            continue
        fi
        BUILD_DATE_DATE=$(echo "$line" | awk '{print $2, $3}')
	BUILD_DATE_EPOCH=$(date --date "$BUILD_DATE_DATE" '+%s')
	
	if [[ "$BUILD_DATE_EPOCH" -gt "$MAX_DATE_EPOCH" ]]; then
             echo "PKG: $line built not longer than $MAX_DAYS"
	     FRESH_PKG_COUNTER=$((FRESH_PKG_COUNTER+1))
	fi
    done < "$TMP_FILE"
    echo "-> Packages that are younger than $MAX_DAYS: $FRESH_PKG_COUNTER"
}

main(){
    prepare_env
    get_packages_with_build_date 
    number_of_fresh_packages
}

main
