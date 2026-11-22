clear

. ./env.ini

echo ""
echo -n "Input Extract Name : "
read EXT_NM
echo ""

UPEXT_NM=`echo $EXT_NM | tr '[a-z]' '[A-Z]'`

echo "########## Start Extract $UPEXT_NM ##########"
echo ""

curl -u $ADMIN_USER:$ADMIN_PASS -H "Content-Type: application/json" -H "Accept: application/json" -d '{"name": "start", "processType": "ER", "processName": "'"$UPEXT_NM"'"}' -X POST http://$HOST_IP:$ADMN_SERVER_PORT/services/v2/commands/execute | python -m json.tool

sleep 2

curl -u $ADMIN_USER:$ADMIN_PASS -H "Content-Type: application/json" -d '{"credentials": {"alias": "'"$CRE_ALIAS"'"}, "command": "INFO"}' -H "Accept: application/json" -X POST http://$HOST_IP:$ADMN_SERVER_PORT/services/v2/extracts/$UPEXT_NM/command | python -m json.tool

echo ""
