#!/usr/bin/env bash

RHEL_LIST=/tmp/RHEL_LIST
CENTOS_LIST=/tmp/C9S_LIST
FINAL_LIST=/tmp/RHEL_AND_C9S

# make it scrict

set -euo pipefail

prepare_env(){
    # clean here -> it makes life easier later
    sudo yum clean all
#    sudo dnf install -y \
#    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
#    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
#    sudo yum install -y libabigail
#    well no luck -> use koji URL xD
    sudo yum install -y https://kojihub.stream.centos.org/kojifiles/packages/libabigail/1.8.2/3.el9/x86_64/libabigail-1.8.2-3.el9.x86_64.rpm
}

get_packages_rhel(){
    sudo repoquery --queryformat '%{name}.%{arch}' > $RHEL_LIST
}

get_packages_centos(){
    sudo repoquery -c centos-yum.conf --queryformat '%{name}.%{arch}' > $CENTOS_LIST
}

create_single_list(){
    # remove noarch as we check binary compatibility
    sort /tmp/RHEL_LIST /tmp/C9S_LIST | uniq --repeated | grep -v noarch > $FINAL_LIST
}

run_tests_on_list(){
    [ -d tmp ] && rm -rf tmp/
    mkdir -p tmp/{c9s,rhel}
    [ -e libabigail.log ] && rm libabigail.log
    [ -e result.log ] && rm result.log
    [ -e dl_error.log ] && rm dl_error.log
    TODO_COUNT=$(wc -l $FINAL_LIST | awk '{print $1}')
    DONE_COUNT=1
    while IFS= read -r line; do
        # allow errors
        set +e
        # remove old packags
        rm -f ./tmp/rhel/*
        rm -f ./tmp/c9s/*
        # download packages 
        yumdownloader "$line" --downloaddir=./tmp/rhel/ || { 
            echo "DL fail for $line" >> dl_error.log
            continue
            }
        yumdownloader -c centos-yum.conf "$line" --downloaddir=./tmp/c9s/
       
        # well eval sucks - there must be better way

        rpm1=$(eval echo ./tmp/rhel/*.rpm)
        rpm2=$(eval echo ./tmp/c9s/*.rpm)
        
        # libabigail
        echo "[$DONE_COUNT/$TODO_COUNT] running abipkgdiff on $rpm1 $rpm2"
        abipkgdiff $rpm1 $rpm2 | tee -a libabigail.log
        status=$?
        if [ $status -eq 0 ]; then
            echo "OK $line" >>  result.log
        else
            echo "FAIL $line" >>  result.log
        fi
        DONE_COUNT=$((DONE_COUNT+1))
    done < "$FINAL_LIST"
    set -e

}

print_results(){
    echo "OK packages: $(grep -c OK result.log)"
    echo "FAIL packages: $(grep -c FAIL result.log)"
    echo "Problem with download: $(grep -c fail dl_error.log)"
}

main(){
    prepare_env
    get_packages_rhel
    get_packages_centos
    create_single_list
    run_tests_on_list
    print_results
}

main
