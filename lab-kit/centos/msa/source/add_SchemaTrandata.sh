#!/bin/bash

#variables
vPass=$1
vASHost=localhost
vASPort=$2
vSchema=$3
vGGAlias=SGGATE

function _addSchemaTrandata {
        curl -X POST \
        http://$vASHost:$vASPort/services/v2/connections/OracleGoldenGate.$vGGAlias/trandata/schema \
        --user "oggadmin:"$vPass   \
	-k \
        -H 'Cache-Control: no-cache' \
        -d '{
            "operation":"add",
            "schemaName":"'"$vSchema"'"
        }' > /dev/null
}

function _main {
     _addSchemaTrandata
}

_main

