#!/bin/bash

echo "{WRAPPER} ********************************************************"
echo "{WRAPPER} [$(date "+%Y-%m-%d %H:%M:%S")] Started DIND Wrapper container '$HOSTNAME'"
echo "{WRAPPER} "
echo "{WRAPPER} * Launching DIND docker daemon..."
/usr/local/bin/dockerd-entrypoint.sh &>/dev/null &

DOCKER_SOCKETS_AVAILABLE=0
DOCKERWAIT=0
while [ $DOCKER_SOCKETS_AVAILABLE -eq 0 ]
do
	sleep 1
	DOCKERWAIT=$(($DOCKERWAIT+1))
	echo "{WRAPPER}   * Waiting for docker socket... $DOCKERWAIT secs elapsed."
	DOCKER_SOCKETS_AVAILABLE=$(netstat | grep -c containerd)
	if [ $DOCKERWAIT -gt 30 ]; then echo "{WRAPPER}   * ERROR: Docker socket did not initialize properly, container will exit now." && exit 1 ; fi
done

echo "{WRAPPER}   * Docker socket now available!" 
echo "{WRAPPER} ===================================" 
echo "{WRAPPER} "
sleep 1
#########################################

#defaults
export SCRIPTS_DIR='scripts'
export STARTER_SCRIPT='00-start.sh'

export CONTAINER_WORKDIR=$(pwd)
echo "{WRAPPER} WORKDIR of this container is '$CONTAINER_WORKDIR'"
echo "{WRAPPER} Wrapper config file (absolute) path is '$CONTAINER_WORKDIR/$CONFIG_FILE'"

if [ -f $CONFIG_FILE ]
then
	echo "{WRAPPER} Found config file $CONFIG_FILE"

	export SCRIPTS_DIR=$(jq -r '.SCRIPTS_DIR' $CONFIG_FILE)
	if [[ $SCRIPTS_DIR != 'null' ]]
	then
		echo "{WRAPPER} SCRIPTS_DIR set from config file: '$SCRIPTS_DIR'"
	else
		export SCRIPTS_DIR='scripts' #default
		echo "{WRAPPER} SCRIPTS_DIR not set in config file, using default '$SCRIPTS_DIR'"
	fi

	export STARTER_SCRIPT=$(jq -r '.STARTER_SCRIPT' $CONFIG_FILE)
	if [[ $STARTER_SCRIPT != 'null' ]]
	then
		echo "{WRAPPER} STARTER_SCRIPT set from config file: '$STARTER_SCRIPT'"
	else
		export STARTER_SCRIPT='00-start.sh' #default
		echo "{WRAPPER} STARTER_SCRIPT not set in config file, using default '$STARTER_SCRIPT'"
	fi
else
	#use defaults
	echo "{WRAPPER} Config file '$CONFIG_FILE' not found, continuing with defaults..."
	echo "{WRAPPER} Default SCRIPTS_DIR: '$SCRIPTS_DIR'"
	echo "{WRAPPER} Default STARTER_SCRIPT: '$STARTER_SCRIPT'"
fi

echo "{WRAPPER} Setting +x permissions for all files in '$SCRIPTS_DIR/'"
chmod +x $SCRIPTS_DIR/*
chmod +x $SCRIPTS_DIR/*.*

echo "{WRAPPER} Launching $SCRIPTS_DIR/$STARTER_SCRIPT"
echo "{WRAPPER} "
$SCRIPTS_DIR/$STARTER_SCRIPT
echo "{WRAPPER} "

echo "{WRAPPER} ===================================" 
echo "{WRAPPER} All scripts finished."
echo "{WRAPPER}  "

SELF_DESTRUCT_TIMER=5
while [ $SELF_DESTRUCT_TIMER -ne 0 ]
do
	echo "{WRAPPER} This container will self-destruct in $SELF_DESTRUCT_TIMER seconds..."
	sleep 1
	SELF_DESTRUCT_TIMER=$(($SELF_DESTRUCT_TIMER-1))
done
echo "{WRAPPER} "
echo "{WRAPPER} Good bye!"
echo "{WRAPPER} "
echo "{WRAPPER} ********************************************************"
echo "{WRAPPER} "
