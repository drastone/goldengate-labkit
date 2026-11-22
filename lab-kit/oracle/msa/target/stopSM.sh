#!/bin/bash

if [[ -z "${OGG_VAR_HOME}" ]]; then
    echo "Error: OGG_VAR_HOME environment variable is not set."
    exit
fi

function getPID {
    PID=$(cat "${OGG_VAR_HOME}/run/ServiceManager.pid" 2>/dev/null)
}
function isRunning {
    kill -0 ${PID} 2>/dev/null
}

getPID
if (! isRunning); then
    echo "Service Manager is not running"
    exit
fi

echo "Stopping Service Manager process (PID: ${PID})..."
kill ${PID}

for attempt in $(seq 10); do
    if (! isRunning); then
        echo "Service Manager stopped"
        exit 0
    fi
    sleep 1
done
echo "Service Manager process could not be stopped"
exit 1
