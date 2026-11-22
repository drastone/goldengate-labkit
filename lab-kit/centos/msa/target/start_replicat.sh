#!/bin/bash

#variables
vPass=$1
vASHost=localhost
vASPort=$2
vExtract=$3
vDSPort=$4
vPathName=$5
vASPort1=$6
vReplicat=$7

function _startReplicat {
     curl -X POST \
     http://$vASHost:$vASPort1/services/v2/commands/execute \
       --user "admin:"$vPass   \
       -k -H 'Cache-Control: no-cache' \
       -d '{
               "name":"start",
               "processName":"'$vReplicat'",
               "processType":"replicat"
          }' | python3 -mjson.tool
}


function _main {
     _startReplicat
}

_main

