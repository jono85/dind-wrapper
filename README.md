# dind-wrapper

This is a minimal dind wrapper container that auto-starts the DIND daemon from the entrypoint script, tries to read a default config file from a mounted volume, and then run a script from the mounted volume as well.

Based on docker:dind container with added most basic tools - bash, curl, jq

## Pre-requisites

 - The container must be run as PRIVILEGED (docker run --privileged .......) for the dind daemon to work
 - You should mount a volume to **/data** where your main config file and other scripts will be located
 - Main config file should be available in the mounted volume under **/data/wrapper-config.json**
### Config file contents:
 - Can be referrenced from any further script as $CONFIG_FILE; use for example jq to read specific values. 
 - Can contain any values you want to store there
 - Two default values looked for by entrypoint script (and converted into system variables) are: 

	   {
	        "SCRIPTS_DIR": "scripts",
	        "STARTER_SCRIPT": "00-start.sh"
	   }

 - SCRIPTS_DIR is relative to the mounted volume, so in this example /data/scripts
 - STARTER_SCRIPT will be started by the entrypoint script.
	 - it will launch `$SCRIPTS_DIR/$STARTER_SCRIPT`, 
	 - in this case we are already in WORKDIR /data/ and it will launch **scripts/00-start.sh**

## Env Variables
You can reference these variables from any of your subscripts:
$CONFIG_FILE - default set to **wrapper-config.json**
$CONTAINER_WORKDIR - is set by entrypoint after container is started. Whatever the workdir in the container is configured for, will have the absolute path in this variable. Default is **/data**
|variable name|info|default value|
|--|--|--|
| $CONFIG_FILE | default config file for the wrapper container | wrapper-config.json |
| $CONTAINER_WORKDIR | set by entrypoint after container is started. Whatever the workdir in the container is configured for, will have the absolute path in this variable. | /data |
| $SCRIPTS_DIR | dir from where starter script will be launched, probably good idea to put your other scripts there as well | scripts |
| $STARTER_SCRIPT | filename for the starter script to be launched from entrypoint | 00-start.sh |

## Standard mounted volume structure

|absolute path|info|
|--|--|
|/data/|mount point of the volume|
|/data/scripts/|directory for starter and other scripts|
|/data/scripts/00-start.sh|default starter script|
|/data/wrapper-config.json|default config file|

## Running the container
    docker run \
	    --privileged \
	    --name "my-dind-wrapper" \
	    --hostname "my-dind-wrapper" \
	    -v /host/path/to/mounted/volume:/data \
	    jono85/dind-wrapper
