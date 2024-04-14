#!/bin/bash

[ -t 1 ] && . colors

source h-manifest.conf
source $CUSTOM_CONFIG_FILENAME
HOSTNAME=`hostname`

if test -f /opt/rocm-6.0.2/bin/amd-smi; then
    echo "not to install rocm"
else
    echo "start to install rocm"
	apt install -y gnupg2
	sudo mkdir --parents --mode=0755 /etc/apt/keyrings
	wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0.2 focal main" | tee --append /etc/apt/sources.list.d/rocm.list
	echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' |  tee /etc/apt/preferences.d/rocm-pin-600
	apt update
	apt install rocm-dev -y
	tar xvf /hive/miners/custom/apoolminer-amd/zluda-release-20240409.tar.gz -C /hive/miners/custom/apoolminer-amd/
fi

if dpkg -s libc6 | grep Version  | grep -q "2.35"; then
  echo "Match found ,not to update libc6"
else
  echo "No match, need to update libc6"
  echo "deb http://cz.archive.ubuntu.com/ubuntu jammy main" >> /etc/apt/sources.list
  apt update
  DEBIAN_FRONTEND=noninteractive apt install libc6 -y 
fi

[[ -z $CUSTOM_LOG_BASENAME ]] && echo -e "${RED}No CUSTOM_LOG_BASENAME is set${NOCOLOR}" && exit 1
[[ -z $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No CUSTOM_CONFIG_FILENAME is set${NOCOLOR}" && exit 1
[[ ! -f $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}Custom config ${YELLOW}$CUSTOM_CONFIG_FILENAME${RED} is not found${NOCOLOR}" && exit 1
CUSTOM_LOG_BASEDIR=`dirname "${CUSTOM_LOG_BASENAME}"`
[[ ! -d $CUSTOM_LOG_BASEDIR ]] && mkdir -p $CUSTOM_LOG_BASEDIR

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/hive/lib:/hive/miners/custom/apoolminer-amd/zluda:/opt/rocm-6.0.2/lib

len=`echo $ADDRESS |awk '{print length}'`
if ps aux | grep 'apoolminer' | grep 'account'|grep -v 'grep'; then
    echo -e "${RED}Apoolminer already running${NOCOLOR}"
    exit 1
else
        ./apoolminer --account $ADDRESS --pool $PROXY $EXTRA 2>&1 | tee --append ${CUSTOM_LOG_BASENAME}.log
fi
