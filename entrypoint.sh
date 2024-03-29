#!/usr/bin/env bash

error() {
    echo "Error: $*" >&2
}

init_srv_config() {
    servers=""
    priorities=""
    forced_hosts=""

    LIST=$(env | grep -Eo '^SRV[0-9]+' | sort -u)
    for srv in ${LIST}
    do
        name="${srv}_NAME"
        address="${srv}_ADDRESS"
        motd="${srv}_MOTD"
        restricted="${srv}_RESTRICTED"

        servers="${servers}  ${!name:-${srv}}:
    address: ${!address}
    motd: '${!motd:-${srv}}'
    restricted: ${!restricted:-false}
"
        priorities="${priorities}      - ${!name:-${srv}}
"
        forced_hosts="${forced_hosts}      ${!name:-${srv}}.${FORCED_HOSTS_DOMAIN}: ${!name:-${srv}}
"
    done

    export CONFIG_SERVERS=${servers}
    export CONFIG_PRIORITIES=${priorities}
    export CONFIG_FORCED_HOSTS=${forced_hosts}
}

init_groups_config() {
    groups=""
    
    LIST=$(env | grep -Eo '^ADMIN[0-9]+' | sort -u)
    for admin in ${LIST}
    do
        groups="${groups}  ${!admin}:
    - admin
"
    done

    export CONFIG_GROUPS=${groups}
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
init_srv_config
init_groups_config

envsubst > /server/config.yml < /config.yml.tmpl
cat /server/config.yml

echo "Starting..."
JVM_OPTS="-Xms${INIT_MEMORY:-${MEMORY}} -Xmx${MAX_MEMORY:-${MEMORY}} ${JVM_OPTS}"
exec java $JVM_OPTS -jar $BUNGEE_JAR "$@"