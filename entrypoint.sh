#!/usr/bin/env bash

error() {
    echo "Error: $*" >&2
}

generate_config() {
    servers=""
    priorities=""

    LIST=$(env | grep -Eo '^SRV[0-9]+' | sort -u)
    for srv in ${LIST}
    do
        address="${srv}_ADDRESS"
        motd="${srv}_MOTD"
        restricted="${srv}_RESTRICTED"

        servers="${servers}  ${srv}:
    address: ${!address}
    motd: '${!motd:-${srv}}'
    restricted: ${!restricted:-false}
"
        priorities="${priorities}      - ${srv}
"
    done

    export CONFIG_SERVERS=${servers}
    export CONFIG_PRIOTITIES=${priorities}
    envsubst > /server/config.yml < /config.yml.tmpl
}
 
BUNGEE_JAR=${BUNGEE_HOME}/BungeeCord.jar
BUNGEE_JAR_URL=${BUNGEE_BASE_URL}/${BUNGEE_JOB_ID:-lastStableBuild}/artifact/bootstrap/target/BungeeCord.jar

if [[ ! -e ${BUNGEE_JAR} ]]
then
    echo "Downloading ${BUNGEE_JAR_URL}"
    if ! curl -o ${BUNGEE_JAR} -fsSL ${BUNGEE_JAR_URL}
    then
        error "failed to download ${BUNGEE_JAR_URL}"
        exit 1
    fi
fi

echo "Generating config..."
generate_config
cat /server/config.yml

echo "Starting..."
JVM_OPTS="-Xms${INIT_MEMORY:-${MEMORY}} -Xmx${MAX_MEMORY:-${MEMORY}} ${JVM_OPTS}"
exec java $JVM_OPTS -jar $BUNGEE_JAR "$@"