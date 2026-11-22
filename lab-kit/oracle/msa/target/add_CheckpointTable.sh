#!/bin/bash

#variables
vPass=$1
vASHost=localhost
vASPort=$2
vGGAlias=OracleGoldenGate.oggalias1

function _createCkptTbl {
     curl -s -X POST \
     http://$vASHost:$vASPort/services/v2/connections/$vGGAlias/tables/checkpoint \
       --user "admin:"$vPass   \
       -k \
       -H 'Cache-Control: no-cache' \
       -d '{
               "operation":"add",
               "name":"PDB01.C##OGG.ggsckpt"
     }' 
}

function _main {
     _createCkptTbl
}

_main
