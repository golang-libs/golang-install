#!/bin/bash

# Golang-Install
# Project Home Page:
# https://github.com/golang-libs/golang-install
#
# forked from https://github.com/flydo/golang-install

LOG_FILE=/tmp/golang-install.log
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

RGB_DANGER='\033[31;1m'
RGB_WAIT='\033[37;2m'
RGB_SUCCESS='\033[32m'
RGB_WARNING='\033[33;1m'
RGB_INFO='\033[36;1m'
RGB_END='\033[0m'
TIMEOUT=30

# warning_message
warning_message() {
    echo -e "${RGB_WARNING}$1${RGB_END}"
}

info_message() {
    echo -e "${RGB_INFO}$1${RGB_END}"
}

tool_info() {
    clear

    echo -e "====================================================="
    echo -e "                 Init Golang Script                  "
    echo -e "          For more information please visit          "
    echo -e "    https://github.com/golang-libs/golang-install    "
    echo -e "====================================================="
}

# check current shell
check_shell() {
    shell=$SHELL
    case ${shell} in
        */bash)
            PROFILE_SHELL=bash
            ;;
        */zsh)
            PROFILE_SHELL=zsh
            ;;
        */sh)  
            PROFILE_SHELL=sh
            ;; 
        *)
            warning_message "Please use bash, zsh or sh as your shell"
            exit 1
            ;;
    esac
    printf "Current Shell is $(warning_message %s)\n" $PROFILE_SHELL
}

# load var
load_vars() {
    # Script file name
    SCRIPT_NAME=$0

    # Release link
    RELEASE_URL="https://golang.org/dl/"

    # Downlaod link
    DOWNLOAD_URL="https://dl.google.com/go/"

    # GOPROXY
    GOPROXY_TEXT="https://goproxy.cn"

    # Set environmental for golang
    PROFILE="${HOME}/.${PROFILE_SHELL}rc"

    # Set GOPATH PATH
    GO_PATH="\$HOME/.go/path"

    # Set GOROOT PATH
    GO_ROOT="\$HOME/.go/go"

    # Is GWF
    IN_CHINA=0

    PROJECT_URL="https://github.com/golang-libs/golang-install"
}

# check in china
check_in_china() {
    urlstatus=$(curl -s -m 3 -IL https://google.com | grep 200)
    if [ "$urlstatus" == "" ]; then
        IN_CHINA=1
        RELEASE_URL="https://golang.google.cn/dl/"
        GOPROXY_TEXT="https://goproxy.cn"
        printf "\e${RGB_WARNING}You can't access google.\e${RGB_END}\n"
    else
        printf "\e${RGB_WARNING}You can access google.\e${RGB_END}\n"
    fi
    sleep 1s
}

# create GOPATH folder
create_gopath() {
    if [ ! -d $GO_PATH ]; then
        mkdir -p $GO_PATH
    fi
}

# Get OS bit
init_arch() {
    ARCH=$(uname -m)
    BIT=$ARCH
    case $ARCH in
        amd64) ARCH="amd64";;
        x86_64) ARCH="amd64";;
        i386) ARCH="386";;
        armv6l) ARCH="armv6l";; 
        armv7l) ARCH="armv6l";; 
        *) printf "\e${RGB_WARNING}Architecture %s is not supported by this installation script\e${RGB_END}\n" $ARCH; exit 1;;
    esac
}

# Get OS version
init_os() {
    OS=$(uname | tr '[:upper:]' '[:lower:]')
    case $OS in
        darwin) OS='darwin';;
        linux) OS='linux';;
        freebsd) OS='freebsd';;
#        mingw*) OS='windows';;
#        msys*) OS='windows';;
        *) printf "\e${RGB_WARNING}OS %s is not supported by this installation script\e${RGB_END}\n" $OS; exit 1;;
    esac
}

# if RELEASE_TAG was not provided, assume latest
latest_version() {
    if [ -z "${RELEASE_TAG}" ]; then
        RELEASE_TAG="$(curl -sL ${RELEASE_URL} | sed -n '/toggleVisible/p' | head -n 1 | cut -d '"' -f 4)"
        echo "Latest Version = ${RELEASE_TAG}"
    fi
}

# list the latest 10 versions of golang
list_versions() {
    STABLE_VERSIONS="$(curl -sL ${RELEASE_URL} | sed -n '/toggleVisible/p' | head -n 10 | cut -d '"' -f 4)"
    ARCHIVED_VERSIONS="$(curl -sL ${RELEASE_URL} | sed -n '/"toggle"/p' | head -n 10 | tail -n 9 | cut -d '"' -f 4)"

    for version in ${STABLE_VERSIONS} ${ARCHIVED_VERSIONS} ; do
        version_array+=($version)
    done

    for version in ${STABLE_VERSIONS} ; do
        stable_array+=($version)
    done

    LATEST_VERSION=${stable_array[0]}

    for version in ${ARCHIVED_VERSIONS} ; do
        archived_array+=($version)
    done

    echo "stable versions:"
    for i in "${!stable_array[@]}"; do   
        printf "%s) %s\t" "$i" "${stable_array[$i]}" 
    done  

    echo ""
    echo "archived versions:"
    for i in "${!archived_array[@]}"; do   
        num=$(($i+${#stable_array[@]}))
        printf "%s) %s\t" "$num" "${archived_array[$i]}"  
        if (( ($i + 1) % 3 == 0))  ; then
            printf "\n"
        fi
    done  
    
    while true ; do
        printf "Please select install golang version, default(\e${RGB_WARNING} ${version_array[0]} \e${RGB_END}): "
        if read -t ${TIMEOUT} idx
        then
            if [[ -n "${version_array[${idx}]}" ]] ; then
                # select it in array
                var=${version_array[${idx}]}
                break
            else 
                echo "input invalid, please select it again."
            fi
        else
            echo
            # timeout
            var=${version_array[0]}
            break
        fi
    done

    echo "You have selected $(warning_message $var)"
    RELEASE_TAG=$var
}

# compare version
compare_version() {
    OLD_VERSION="none"
    NEW_VERSION="${RELEASE_TAG}"
    if test -x "$(command -v go)"; then
        OLD_VERSION="$(go version | awk '{print $3}')"
    fi
    if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
       printf "\n$(warning_message "You have installed this version: %s")\n" $OLD_VERSION; exit 1;
    fi
}

# compare version size 
version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

# install curl command
install_curl_command() {
    if !(test -x "$(command -v curl)"); then
        if test -x "$(command -v yum)"; then
            yum install -y curl
        elif test -x "$(command -v apt)"; then
            apt install -y curl
        else 
            printf "\e${RGB_WARNING}You must pre-install the curl tool\e${RGB_END}\n"
            exit 1
        fi
    fi  
}

# Download go file
download_file() {
    url="${1}"
    destination="${2}"

    printf "Fetching ${url} \n\n"

    if test -x "$(command -v curl)"; then
        code=$(curl --connect-timeout 15 -w '%{http_code}' -L "${url}" -o "${destination}")
    elif test -x "$(command -v wget)"; then
        code=$(wget -t2 -T15 -O "${destination}" --server-response "${url}" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        printf "\e${RGB_WARNING}Neither curl nor wget was available to perform http requests.\e${RGB_END}\n"
        exit 1
    fi

    if [ "${code}" != 200 ]; then
        printf "\e${RGB_WARNING}Request failed with code %s\e${RGB_END}\n" $code
        exit 1
    else 
	    printf "\n${RGB_WARNING}Download succeeded\e${RGB_END}\n"
    fi
}

# set golang environment
set_environment() {
    #test ! -e $PROFILE && PROFILE="${HOME}/.bash_profile"
    #test ! -e $PROFILE && PROFILE="${HOME}/.bashrc"

    if [ -z "`grep 'export\sGOROOT' ${PROFILE}`" ];then
        echo -e "\n## GOLANG" >> $PROFILE
        echo "export GOROOT=\"${GO_ROOT}\"" >> $PROFILE
    else
        sed -i "s@^export GOROOT.*@export GOROOT=\"${GO_ROOT}\"@" $PROFILE
    fi

    if [ -z "`grep 'export\sGOPATH' ${PROFILE}`" ];then
        echo "export GOPATH=\"${GO_PATH}\"" >> $PROFILE
    else
        sed -i "s@^export GOPATH.*@export GOPATH=\"${GO_PATH}\"@" $PROFILE
    fi
    
    if [ -z "`grep 'export\sGOBIN' ${PROFILE}`" ];then
        echo "export GOBIN=\"\$GOPATH/bin\"" >> $PROFILE
    else 
        sed -i "s@^export GOBIN.*@export GOBIN=\$GOPATH/bin@" $PROFILE        
    fi   

    if [ -z "`grep 'export\sGO111MODULE' ${PROFILE}`" ];then
        if version_ge $RELEASE_TAG "go1.11.1"; then
            echo "export GO111MODULE=on" >> $PROFILE
        fi
    fi       

    if [ "${IN_CHINA}" == "1" ]; then 
        if [ -z "`grep 'export\sGOSUMDB' ${PROFILE}`" ];then
            echo "export GOSUMDB=off" >> $PROFILE
        fi      
    fi

    if [ -z "`grep 'export\sGOPROXY' ${PROFILE}`" ];then
        if version_ge $RELEASE_TAG "go1.13"; then
            GOPROXY_TEXT="${GOPROXY_TEXT},direct"
        fi
        echo "export GOPROXY=\"${GOPROXY_TEXT}\"" >> $PROFILE
    fi  
    
    if [ -z "`grep '\$GOROOT/bin:\$GOBIN' ${PROFILE}`" ];then
        echo "export PATH=\"\$PATH:\$GOROOT/bin:\$GOBIN\"" >> $PROFILE
    fi        
}

show_install_information() {
printf "Current OS:      $(warning_message "%s")
Current ARCH:    $(warning_message "%s")
GOROOT:          $(warning_message "%s")
GOPATH:          $(warning_message "%s") 
Current Version: $(warning_message "%s")
Target  Version: $(warning_message "%s")
Latest  Version: $(warning_message "%s")
\n" $OS $ARCH $(replaceHome $GO_ROOT) $(replaceHome $GO_PATH) $OLD_VERSION $RELEASE_TAG $LATEST_VERSION
}

continue_install() {
    printf  "Press $(warning_message "Ctrl+C") now to abort this script, or wait for the installation to continue."
	echo
	sleep 5
}

# Show success message
show_success_message() {
printf "
Install success, please execute again $(warning_message "source %s")
\n" $PROFILE
}

check_go_root() {
    if [[ -n "$GOROOT" ]] ; then
        printf "The $(warning_message GOROOT) is already set to $(warning_message %s)\n" $GOROOT
        GO_ROOT=$GOROOT 
    else
        goroot=$(replaceHome "${GO_ROOT}")
        printf "The $(warning_message GOROOT) is unset, the default is $(warning_message %s)\n" $goroot
    fi

    while true ; do
        printf "Please input new GOROOT, or wait for using the $(warning_message %s): " $(replaceHome "${GO_ROOT}")
        if read -t ${TIMEOUT} goroot ; then
            if [[ -n "${goroot}" ]] ; then
                GO_ROOT=${goroot}
                break
            else 
                break
            fi
        else
            echo ""
            break
        fi
    done

    goroot=$(replaceHome "${GO_ROOT}")
    printf "\nThe $(warning_message GOROOT) is set to $(warning_message %s)\n" $goroot
}

check_go_path() {
    if [[ -n "$GOPATH" ]] ; then
        printf "The $(warning_message GOPATH) is already set to $(warning_message %s)\n" $GOPATH
        GO_PATH=$GOPATH 
    else
        gopath=$(replaceHome "${GO_PATH}")
        printf "The $(warning_message GOPATH) is unset, the default is $(warning_message %s)\n" $gopath
    fi

    while true ; do
        printf "Please input new GOPATH, or wait for using the $(warning_message %s): " $(replaceHome "${GO_PATH}")
        if read -t ${TIMEOUT} gopath ; then
            if [[ -n "${gopath}" ]] ; then
                GO_PATH=${gopath}
                break
            else 
                break
            fi
        else
            echo ""
            break
        fi
    done

    gopath=$(replaceHome "${GO_PATH}")
    printf "\nThe $(warning_message GOPATH) is set to $(warning_message %s)\n" $gopath
    create_gopath
}

replaceHome() {
    tmp=$1
    if [[ -n "${tmp}" ]] ; then
        tmp=${tmp/"\$HOME"/"${HOME}"}
        echo $tmp
    fi
}

check_os_and_arch() {
    init_os
    init_arch
    printf "The $(warning_message OS) is $(warning_message %s), The $(warning_message ARCH) is $(warning_message %s), The $(warning_message BIT) is $(warning_message %s)\n" $OS $ARCH $BIT
}

make_dir() {
    param=$(replaceHome "$1")
    if [ ! -d "$param" ]; then
        mkdir -p "$param"
    fi
}

main() {
    tool_info

    echo -e "\n$(info_message "Start Detect Shell ")"
    check_shell

    echo -e "\n$(info_message "Start Load Default Param")"
    load_vars "$@"

    set -e

    install_curl_command

    echo -e "\n$(info_message "Start Detect OS And ARCH ")"
    check_os_and_arch

    echo -e "\n$(info_message "Start Check In China ")"
    check_in_china

    echo -e "\n$(info_message "Start Detect Golang ROOT ")"
    check_go_root

    echo -e "\n$(info_message "Start Detect Golang PATH ")"
    check_go_path

    echo -e "\n$(info_message "Start Detect Golang Version ")"
    # latest_version
    list_versions

    compare_version

    echo -e "\n$(info_message "Show Install Information ")"
    show_install_information

    continue_install

    echo -e "\n$(info_message "Start Download Golang ")" 
    BINARY_URL="${DOWNLOAD_URL}${RELEASE_TAG}.${OS}-${ARCH}.tar.gz"
    DOWNLOAD_FILE="$(mktemp).tar.gz"
    download_file $BINARY_URL $DOWNLOAD_FILE

    echo -e "\n$(info_message "Install and Remove Golang ")" 
    make_dir $GO_ROOT
    make_dir $GO_PATH

    goroot=$(replaceHome "${GO_ROOT}")
    cd ${goroot}/../
    rm -rf ${goroot}
    tar -zxf $DOWNLOAD_FILE
    rm -rf $DOWNLOAD_FILE

    echo -e "\n$(info_message "Set Golang Environment ")" 
    set_environment
    
    show_success_message
}

main "$@" || exit 1
