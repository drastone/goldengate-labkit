#!/bin/bash

#variables
vPass=$1
vASHost=localhost
vASPort=$2
vRepName=$3
vGGAlias=$4
vSrcTrail=$5

function _addReplicat {
    curl -X POST \
    http://$vASHost:$vASPort/services/v2/replicats/$vRepName \
    --user "admin:"$vPass   \
    -k \
    -H 'Cache-Control: no-cache' \
    -d '{
        "description":"Integrated Replicat",
        "config":[
            "Replicat     '$vRepName'",
            "UseridAlias '$vGGAlias'",
            "map ORCLPDB1.soe.addresses,target ORCLPDB1.soe.addresses, keycols(address_id);",
            "map ORCLPDB1.soe.customers, target ORCLPDB1.soe.customers, keycols(customer_id);",
            "map ORCLPDB1.soe.orders, target ORCLPDB1.soe.orders, keycols(order_id);",
            "map ORCLPDB1.soe.order_items, target ORCLPDB1.soe.order_items, keycols(order_id, line_item_id);",
            "map ORCLPDB1.soe.card_details, target ORCLPDB1.soe.card_details, keycols(card_id);",
            "map ORCLPDB1.soe.logon, target ORCLPDB1.soe.logon;",
            "map ORCLPDB1.soe.product_information, target ORCLPDB1.soe.product_information;",
            "map ORCLPDB1.soe.inventories, target ORCLPDB1.soe.inventories, keycols(product_id, warehouse_id);",
            "map ORCLPDB1.soe.product_descriptions, target ORCLPDB1.soe.product_descriptions;",
            "map ORCLPDB1.soe.warehouses, target ORCLPDB1.soe.warehouses;",
            "map ORCLPDB1.soe.orderentry_metadata, target ORCLPDB1.soe.orderentry_metadata;",
            "map ORCLPDB1.soe.CFUND_RAT, target ORCLPDB1.soe.CFUND_RAT;",
			"map ORCLPDB1.soe.CFUND_DT, target ORCLPDB1.soe.CFUND_DT;",
			"map ORCLPDB1.soe.RESERVES_AMT, target ORCLPDB1.soe.RESERVES_AMT;",
			"map ORCLPDB1.soe.TOT_AMT, target ORCLPDB1.soe.TOT_AMT;",
			"map ORCLPDB1.soe.OPSTATUS, target ORCLPDB1.soe.OPSTATUS;",
			"map ORCLPDB1.soe.EMPLOYEE, target ORCLPDB1.soe.EMPLOYEE;",
			"map ORCLPDB1.soe.MSG, target ORCLPDB1.soe.MSG;"
        ],
        "source":{
            "name":"'$vSrcTrail'"
        },
        "mode":{
            "type":"integrated"
        },
        "credentials":{
            "alias":"'$vGGAlias'"
        },
        "checkpoint":{
            "table":"ORCLPDB1.C##OGG.ggsckpt"
        },
        "status":"running"
    }' | python -mjson.tool
}

function _main {
     _addReplicat
}

_main

