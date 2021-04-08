#!/usr/bin/env bash

#set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)
set -x

if [ "${1:0:1}" = '-' ]; then

	#set -- bash -c "$@"
	echo set -- bash -c "$@"

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
	-Djava.security.egd=file:/dev/./urandom \
	-Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m \
    -XX:PerfDataSamplingInterval=500 -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:NewRatio=2 \
	-XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=20 -XX:ConcGCThreads=4 \
    -XX:InitiatingHeapOccupancyPercent=70 -XX:+CMSClassUnloadingEnabled"


export GEOSERVER_OPTS=\
		"-Dorg.geotools.referencing.forceXY=true \
         -Dorg.geotools.shapefile.datetime=true \
		 -Dgeoserver.login.autocomplete=off "

export JAVA_OPTS="${JAVA_OPTS} ${GEOSERVER_OPTS}"

# especific

exec $CATALINA_HOME/bin/catalina.sh run

