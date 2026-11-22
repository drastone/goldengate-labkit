#!/bin/bash

#variables
vPass=$1
vASHost=localhost
vASPort=$2
vExtName=$3
vGGAlias=$4
vSrcTrail=$5

function _addExtract {
    curl -s -X POST \
    http://$vASHost:$vASPort/services/v2/extracts/$vExtName \
    --user "admin:"$vPass   \
    -k \
    -H 'Cache-Control: no-cache' \
    -d '{
        "description":"Integrated Extract",
        "config":[
            "Extract     '$vExtName'",
            "ExtTrail    '$vSrcTrail'",
            "UseridAlias '$vGGAlias'",
            "table ORCLPDB1.soe.*;"
        ],
        "source":{
            "tranlogs":"integrated"
        },
        "credentials":{
            "alias":"'$vGGAlias'"
        },
        "registration":{
            "optimized":false,
			"containers": ["ORCLPDB1"]
        },
        "begin":"now",
        "targets":[
            {
                "name":"'$vSrcTrail'",
                "sizeMB":10
            }
        ],
        "status":"running"
    }' | python -mjson.tool
}

function _main {
     _addExtract
}

_main
