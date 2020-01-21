#!/bin/bash
###
# c't-Raspion, a Raspberry Pi based all in one sniffer
# for judging on IoT and smart home devices activity
# (c) 2019-2020 c't magazin, Germany, Hannover
# see: https://ct.de/-123456 for more information
# 
# file          : scripts/functions.sh
# description   : Some helper for the main RSD.sh-Script
# version       : 0.1
#       
# changes         
# author		: Benny Stark - github.com/Diggen85
# date          : 20200113
# notes         : Initial - untested
# date          : 20200115-19
# notes         : RSD-BuildRepository
#								:	buildChecksum
#               : change logger-function
###



##
## logger $MSG [$TYPE:ERR,WAR,NOR,...]
## reads the var $PKG_NAME or take scriptname (rsd.sh) if not set
## - Print pretty Text 
logger() {
    local BNAME=$(basename -- $0)
    SH_NAME="\033[97m${LOG_NAME:=$BNAME}\033[0m:"
    case $2 in
        ERR|ERROR)
            TYPE="\033[31merror:\033[0m " 
            ;;
        WAR|WARN|WARNING)
            TYPE="\033[33mwarning:\033[0m " 
            ;;
        NOR|NORM|NORMAL|INFO)
            TYPE="\033[32minfo:\033[0m " 
            ;;
        *) TYPE="\033[96m "
            ;;
    esac
    MSG=${1:-"Forgot what to say..."}
    echo -e "$SH_NAME $TYPE$MSG\033[0m"
}

##
## runPriv
## - check if we are root or we should sudo
runPriv() {
    if [[ $RSD_USER == 0 ]]; then 
        $@
    else
        sudo $@
    fi
}

## 
## buildChecksum sha256|md5 file
## - prints checksum for file in Repository-Format
buildChecksum() {
	if [[ -n $1 && -f $2 ]]; then
		case $1 in
			sha256)
				F_SUM=$(sha256sum $2) 
				F_SUM=${F_SUM:0:64}
				;;
			md5)
				F_SUM=$(md5sum $2)
				F_SUM=${F_SUM:0:32}
				 ;;
			*)
				logger "Checksum type $1 not supported" "ERR"
				exit 1 
				;;
		esac
	F_SIZE=$(wc --bytes < $2)
	F_BASENAME=$(basename $2)
	echo -e "$F_SUM\t$F_SIZE $F_BASENAME"
	else
		logger "Checksum: No File - $2" "ERR"
		exit 1
	fi
}


##
## RSD-Prepare
## - Prepare the environment.
## - needs to be root or sudo
RSD-Prepare() {
	logger "install packages needed for building raspion"
    runPriv sudo apt-get install ${RSD_APTARGS} ${RSD_REQPACKAGES}
}

##
## RSD-Build [PKG Name]
## - build all packages or specified
## - e.g. RSD-Build 50-raspion
RSD-Build() {
    mkdir -p development/repository

    PKG_PATH=$RSD_CWD/pkgs/$1/
    PKG_SCRIPT=build.sh	
    if [[ -n $1 ]] ; then
        if [[ -f $RSD_CWD/pkgs/$1/build.sh ]]; then
            logger "Start building of specified package: $1"
            LOG_NAME=$1
            source $RSD_CWD/pkgs/$1/build.sh
            unset LOG_NAME
        else
            logger "No Package build.sh in $1" "ERR"
            exit 1
        fi
    else
        logger "Start building all packages"
        for PKG_PATH in $RSD_CWD/pkgs/*/ ; do
			PKG_NAME=$(basename $PKG_PATH)
            PKG_SCRIPT=build.sh
            if [[ -f ${PKG_PATH}${PKG_SCRIPT} ]] ; then
                logger "found $PKG_SCRIPT in $PKG_NAME" "NOR"
                logger "start $PKG_SCRIPT"
                LOG_NAME=$PKG_NAME
                source ${PKG_PATH}${PKG_SCRIPT}
                unset LOG_NAME
            else
                logger "No $PKG_SCRIPT for $PKG_NAME" "ERR"
                exit 1
            fi
        done
				
    fi
    
}

##
## RSD-Install
## - Calls install.sh with dev dependend args
RSD-Install() {
    logger "Start the Raspion installation"
    cd $RSD_CWD/release/
    ./install.sh
}


##
## AddToRepo deb-File
## - adds the given File to local-repo
addToRepo() {
	#PKG_ARCH=$(sed "s/^.*_\(.*\)\.deb$/\1/" <<< $PKG_FILE)
	#PKG_NAMEVER=$(sed "s/\(^.*\)_.*$/\1/" <<< $PKG_FILE)
	#${PKG_NAME}*.dsc ${PKG_NAME}*.tar.xz ${PKG_NAME}*.changes ${PKG_NAME}*.buildinfo 
	#PKG_WOEXT=$(sed "s/^\(.*\)\.deb/\1/") <<< $1
	#TODO allow add to source repo
	if [[ -f $1 ]]; then
		logger "add $1 to repository" "NOR"
		mkdir -p ${RSD_CWD}/${RSD_REPO}	
		cp $1 ${RSD_CWD}/${RSD_REPO}
	else
		logger "$1 not found" "ERR"
		exit 1
	fi
}


##
## RSD-BuildRepo
## - builds updated Packages file
RSD-BuildRepository() {
    logger "start building repository"

    cd ${RSD_CWD}/${RSD_REPO}
    logger "Building Release-File" "NOR"
    #TODO use Templatefile
    #Rewrite Release-File - modified from offical c't repository
    cat > "Release" << EOF
Origin: ct
Label: raspion
Suite: unstable
Description: dev-repo for c''t-Raspion-Project
Date: $(LANG=C date -R -u)
MD5Sum:
SHA256:
EOF
    #NotAutomatic: yes

    #Build Packages.gz and checksums
    logger "Building Packages-File" "NOR"
    dpkg-scanpackages -m "./"  > Packages
    gzip -9c Packages > Packages.gz

    logger "Building checksums for Release-File" "NOR"
    sed -i "/^MD5Sum\:/a\ $(buildChecksum md5 Packages)" Release
    sed -i "/^SHA256\:/a\ $(buildChecksum sha256 Packages)" Release
    sed -i "/^MD5Sum\:/a\ $(buildChecksum md5 Packages.gz)" Release
    sed -i "/^SHA256\:/a\ $(buildChecksum sha256 Packages.gz)" Release

    cd ${RSD_CWD}

    #TODO Use own sub-cmd
    #TODO Use Template
    #if not exists add repository and preference to apt 
    if [[ ! -f /etc/apt/sources.list.d/rsd.list ]]; then
    logger "Add repository to apt"
    echo "deb [trusted=yes allow-downgrade-to-insecure=yes allow-insecure=yes] file://${RSD_CWD}/${RSD_REPO} ./" | runPriv tee /etc/apt/sources.list.d/rsd.list
    fi
    #TODO Use Template
    if [[ ! -f /etc/apt/preferences.d/50rsd ]]; then
    logger "Add preferences to apt"
    echo -e "Package: *\nPin: release o=ct,a=unstable,l=raspion\nPin-Priority: 610\n" | runPriv tee /etc/apt/preferences.d/50rsd
    fi

    logger "Update apt"
    runPriv apt-get update
}

