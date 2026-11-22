#!/bin/bash

#variables
vPass=$1
vDSHost=localhost
vDSPort=$2
vPathName=$3
vSrcTrail=$4
vRSHost=$5
vRSPort=$6
vTgtTrail=$7

function _addDistoPath {
    curl -s -X POST \
    http://$vDSHost:$vDSPort/services/v2/sources/$vPathName \
    --user "admin:"$vPass   \
    -H 'Cache-Control: no-cache' \
    -d '{
        "name": "'$vPathName'",
        "status": "running",
        "source": {
            "uri": "trail://'$vDSHost':'$vDSPort'/services/v2/sources?trail='$vSrcTrail'"
        },
        "target": {
            "uri": "ogg://'$vRSHost':'$vRSPort'/services/v2/targets?trail='$vTgtTrail'",
            "details": {
                "trail": { "sizeMB": 100 }
            }
        }
    }' 
}

function _main {
     _addDistoPath
}

_main
