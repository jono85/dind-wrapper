#!/bin/bash
#00 Starter
SCRIPTNUM='00'

echo "{$SCRIPTNUM} Starter script launched."

echo "{$SCRIPTNUM} Sleeping for 5 seconds."
sleep 5

echo "{$SCRIPTNUM} Running 'hello-world' container to test DIND is working properly..."

echo "{$SCRIPTNUM} \$\$\$ docker run --rm hello-world"
docker run --rm hello-world

echo "{$SCRIPTNUM} "
echo "{$SCRIPTNUM} Starter script finished, exiting."
echo "{$SCRIPTNUM} "
