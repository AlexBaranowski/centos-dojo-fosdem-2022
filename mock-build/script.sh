#!/usr/bin/env bash

# Author: Alex Baranowski <alex@euro-linux.com>
# License: MIT
# DESC: Install mock on EL 9 then rebuild two packages


setup_env(){
    if  rpm -qi mock &> /dev/null ; then
        echo "mock already installed"
    else
        sudo dnf install -y \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
        https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
        sudo yum install -y mock
    fi
    sudo usermod -a -G mock "$USER"
}

download_src_rpm(){
    # use continue as it won't clobber
     wget --continue https://download-ib01.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/a/atop-2.7.1-2.fc36.src.rpm
     wget --continue https://download-ib01.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/t/terminator-2.1.1-5.fc36.src.rpm  
}

run_mocks(){
    [ -d local_repo ] && rm -rf local_repo
    mkdir local_repo
    if id -nG "$USER" | grep -qw "mock"; then
        echo "User  $USER in the mock group - OK"
    else
        echo "User $USER not in the mock group use \`newgrp mock\` command then rerun this script"
    fi
    mock --resultdir ./local_repo -r /etc/mock/centos-stream-9-x86_64.cfg atop*.src.rpm
    mock --resultdir ./local_repo -r /etc/mock/centos-stream-9-x86_64.cfg terminator*.src.rpm
}

main(){
    setup_env
    download_src_rpm
    run_mocks
}
main

