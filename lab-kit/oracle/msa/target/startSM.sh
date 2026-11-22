#!/bin/bash

if [[ -z "${OGG_HOME}" ]]; then
    echo "Error: OGG_HOME environment variable is not set."
    exit
fi
if [[ -z "${OGG_ETC_HOME}" ]]; then
    echo "Error: OGG_ETC_HOME environment variable is not set."
    exit
fi
if [[ -z "${OGG_VAR_HOME}" ]]; then
    echo "Error: OGG_VAR_HOME environment variable is not set."
    exit
fi

SERVICEMANAGER_EXE="${OGG_HOME}/bin/ServiceManager"

function getPID {
    PID=$(cat "${OGG_VAR_HOME}/run/ServiceManager.pid" 2>/dev/null)
}
function isRunning {
    kill -0 ${PID} 2>/dev/null
}

getPID
if (isRunning); then
    echo "Service Manager is already running (PID: ${PID})"
    exit
fi

if [ ! -f "${SERVICEMANAGER_EXE}" ]; then
    echo "Error: Service Manager binary file (${SERVICEMANAGER_EXE}) not found"
    exit
fi

echo "Starting Service Manager process..."
"${SERVICEMANAGER_EXE}" --quiet

getPID
if (isRunning); then
    echo "Service Manager process started (PID: ${PID})"
else
    echo "Service Manager process could not be started"
fi
