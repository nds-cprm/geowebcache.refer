#!/usr/bin/env bash

#set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)
set -x

if [ "${1:0:1}" = '-' ]; then

	#set -- bash -c "$@"
	echo set -- bash -c "$@"

fi

# allow the container to be started with `--user`
if [ "${1}" =  "--user" ] && [ "$(id -u)" = '0' ]; then

    echo gosu $1 "$BASH_SOURCE" "$@"

fi

# allow the scripts from pseudo init directory
if [ -d "/docker-entrypoint.d/" ]; then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo "$0: running $f"
                    "$f"
                else
                    echo "$0: sourcing $f"
                    . "$f"
                fi
                ;;
            *)
                echo "$0: ignoring $f"
                ;;
        esac
    done
fi


# especific

export CATALINA_HOME=/usr/share/tomcat9

export CATALINA_BASE=/opt/tomcat

export JAVA_OPTS="-server -Djava.awt.headless=true -server \
    -XX:PerfDataSamplingInterval=500 -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:NewRatio=2 \
	-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=5 \
    -XX:InitiatingHeapOccupancyPercent=70 -XX:+CMSClassUnloadingEnabled"

export GEOSERVER_OPTS=\
		"-Dorg.geotools.referencing.forceXY=true \
         -Dorg.geotools.shapefile.datetime=true -Dgeoserver.login.autocomplete=off \
         -DGEOSERVER_CONSOLE_DISABLED=${GEOSERVER_WEB_UI_DISABLED:-FALSE}"

export JAVA_OPTS="${JAVA_OPTS} ${GEOSERVER_OPTS}"

# especific

exec $CATALINA_HOME/bin/catalina.sh run

