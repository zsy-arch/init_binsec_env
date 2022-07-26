#!/bin/bash

ask() {
    local prompt default reply

    if [[ ${2:-} = 'Y' ]]; then
        prompt='Y/n'
        default='Y'
    elif [[ ${2:-} = 'N' ]]; then
        prompt='y/N'
        default='N'
    else
        prompt='y/n'
        default=''
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read -r reply </dev/tty

        # Default?
        if [[ -z $reply ]]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

ask 'Do you want to run the script?' && echo 'A linux shell script to init PWN & REV environment'
echo 'Please use suitable(fast internet) APT MIRROR before run this script'
ask 'continue?' || exit

cd ~

echo '[*] Update & upgrade apt & install basic utils'
ask 'continue?' || exit
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y openssh-server vim python3-pip git lib32ncurses6 lib32z1 libssl-dev libffi-dev build-essential gdb gdb-multiarch "binfmt*" gcc-multilib ruby

echo "Please input your git http.proxy and https.proxy(optional), e.g. http://127.0.0.1:7890/"

GIT_HTTP_PROXY=""
GIT_HTTPS_PROXY=""

read -e -i "$GIT_HTTP_PROXY" -p "Please enter your GIT_HTTP_PROXY: " input
[[ ! -z "$GIT_HTTP_PROXY" ]] && git config --global http.proxy "$GIT_HTTP_PROXY" && echo "GIT_HTTP_PROXY: $GIT_HTTP_PROXY"
read -e -i "$GIT_HTTPS_PROXY" -p "Please enter your GIT_HTTPS_PROXY: " input
[[ ! -z "$GIT_HTTPS_PROXY" ]] && git config --global https.proxy "$GIT_HTTPS_PROXY" && echo "GIT_HTTPS_PROXY: $GIT_HTTPS_PROXY"

echo "[*] Test python3: $(python3 -V)"
echo "[*] Test pip3: $(pip3 -V)"

PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
read -e -i "$PIP_INDEX_URL" -p "Please enter your PIP_INDEX_URL and clear the input if you want to use the default: " input
echo "[*] PyPi index url $PIP_INDEX_URL"
[[ ! -z "$PIP_INDEX_URL" ]] && sudo pip3 config set global.index-url "$PIP_INDEX_URL"
sudo pip3 install --upgrade pip

RUBY_PROXY=""
RUBY_MIRROR="https://gems.ruby-china.com/"
read -e -i "$RUBY_PROXY" -p "Please enter your RUBY_PROXY: " input
read -e -i "$RUBY_MIRROR" -p "Please enter your RUBY_MIRROR and clear the input if you want to use the default: " input
[[ ! -z "$RUBY_PROXY" ]] && gem update --system --http-proxy "$RUBY_PROXY"
[[ ! -z "$RUBY_MIRROR" ]] && gem sources --add "$RUBY_MIRROR" --remove https://rubygems.org/
echo "$(gem -v)"

echo 'Install PWN tools (pwntools, checksec, ROPgadget, one_gadget)'
ask 'continue?' || exit
pip3 install pwntools
sudo apt install -y checksec python3-ropgadget
sudo gem install one_gadget

echo 'Install pwndbg'
ask 'continue?' || exit

result="$(gdb <<< 'quit' | grep 'pwndbg>')"
if [ -z "$result" ]
then
	mkdir -p ~/pwnutils
	cd ~/pwnutils
	git clone https://github.com/pwndbg/pwndbg
	cd pwndbg
	./setup.sh
else
	echo "[*] You have installed pwndbg"
fi
result=""

echo 'Install QEMU'
ask 'continue?' || exit
sudo apt install -y qemu-system qemu-user qemu-user-static  

echo 'Install Sagemath'
ask 'continue?' || exit
sudo apt install -y sagemath

