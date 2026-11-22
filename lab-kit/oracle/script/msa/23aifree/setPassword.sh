#!/bin/bash
## Copyright (c) 2023, Oracle and/or its affiliates.

#Enable it only for debugging
#set -x

##
##  setPassword.sh
##  Change the password for the deployment
##

:     "${OGG_DEPLOYMENT:=Local}"
:     "${OGG_ADMIN:=oggadmin}"
:     "${OGG_LISTEN_ON:=127.0.0.1}"

##
##  r u n _ a s _ o g g
##  Return a string used for running a process as the 'ogg' user
##
function run_as_ogg() {
    local user="ogg"
    local uid gid
    uid="$(id -u "${user}")"
    gid="$(id -g "${user}")"
    echo "setpriv --ruid ${uid} --euid ${uid} --groups ${gid} --rgid ${gid} --egid ${gid} -- "
}

##
##  g e n e r a t e P a s s w o r d
##  If not already specified, generate a random password with:
##  - at least one uppercase character
##  - at least one lowercase character
##  - at least one digit character
##
function getPassword {
    if [[ -n "${OGG_ADMIN_PWD}" ]]; then
        return
    fi
    #Need to fetch from goldengate deployment log
    APP_DATA_HOME=${APP_DATA_HOME:=/u02/oggf}
    line=`grep 'Password for OGG administrative user' ${APP_DATA_HOME}/logs/deployment.log`
    OGG_ADMIN=`echo $line | awk -F"'" '{print $2}'`
    export OGG_ADMIN
    OGG_ADMIN_PWD=`echo $line | awk -F"'" '{print $4}'`
    export OGG_ADMIN_PWD
}

##
##  change password in ggma
##
function change_password_ggma() {
    $(run_as_ogg) python3 /usr/local/bin/deployment-set-password.py $*
}

function getUrl() {
  local path="v1.0/$1"
  if [ "$reverseProxy" == "true" ]; then
    url="$scheme://$host:$port/oggfServices/$path"
  else
    url="$scheme://$host:$port/$path"
  fi
}

function getToken() {
  getUrl $path

   cat > /tmp/authreq.json <<EOF
{
  "connectionName" : "${OGGF_LOCAL_GOLDENGATE}",
  "deploymentUsername" : "${OGG_ADMIN}",
  "deploymentPassword" : "${OGG_ADMIN_PWD}"
}
EOF

  getUrl "auth/token"

  if [ "$verbose" == "true" ]; then
    echo "curl -s -X POST $headersArgs $url -H \"Access-Control-Request-Method: POST\" -H \"Content-Type: application/json\" -d @/tmp/authreq.json > /tmp/apiresp"
    cat /tmp/authreq.json
  fi
  curl -s -X POST $headersArgs $url -H "Access-Control-Request-Method: POST" -H "Content-Type: application/json" -d @/tmp/authreq.json > /tmp/apiresp
  token=`cat /tmp/apiresp | jq -r ".token"`
  if [ "$verbose" == "true" ]; then
    cat /tmp/apiresp
    echo "token=$token"
  fi
  echo $token > /tmp/token
  export OGGF_TOKEN=$token
  rm -f /tmp/apiresp
  rm -rf /tmp/authreq.json
}

function getConnectionId() {
  name=$1
  getUrl "connections?filter=name%3D$name"
  if [ "$verbose" == "true" ]; then
    echo "curl -s -X GET $url -H "Authorization: Bearer $OGGF_TOKEN" -H \"Access-Control-Request-Method: POST\" -H \"Content-Type: application/json\" -d @/tmp/req.json > /tmp/apiresp"
  fi
  curl -s -X GET $url -H "Authorization: Bearer $OGGF_TOKEN" -H "Access-Control-Request-Method: POST" -H "Content-Type: application/json" -d @/tmp/req.json > /tmp/apiresp
  if [ "$verbose" == "true" ]; then
    cat /tmp/apiresp
  fi
  connectionId=`cat /tmp/apiresp | jq -r ".items[0].id"`
}

function updateConnectionPassword() {
  connectionId=$1
  newpassword=$2
  cat > /tmp/req.json <<EOF
{
  "properties": {
      "password": "${newpassword}"
    }
}
EOF
  getUrl "connections/$connectionId"
  if [ "$verbose" == "true" ]; then
    echo "curl -s -X PUT $url -H "Authorization: Bearer $OGGF_TOKEN" -H \"Access-Control-Request-Method: POST\" -H \"Content-Type: application/json\" -d @/tmp/req.json > /tmp/apiresp"
    cat /tmp/req.json
  fi
  curl -s -X PUT $url -H "Authorization: Bearer $OGGF_TOKEN" -H "Access-Control-Request-Method: POST" -H "Content-Type: application/json" -d @/tmp/req.json > /tmp/apiresp
  if [ "$verbose" == "true" ]; then
    cat /tmp/apiresp
  fi
  rm -f /tmp/apiresp
  rm -rf /tmp/req.json
}

##
##  change password in oggf
##
function change_password_oggf() {
    newpassword=$1
    getToken
    getConnectionId ${OGGF_LOCAL_GOLDENGATE}
    updateConnectionPassword $connectionId $newpassword
}

verbose=false

OGGF_LOCAL_GOLDENGATE=LocalGoldenGate
host=localhost
port=80
reverseProxy=true
scheme=${scheme:=http}

getPassword

(
  set -e
  change_password_ggma $*
  set +e
)
errorCode=$?
if [ $errorCode -ne 0 ]; then
  exit $errorCode
fi
(
  set -e
  OGG_ADMIN_PWD=$1
  change_password_oggf $*
  set +e
  echo "Successfully updated the password in ${OGGF_LOCAL_GOLDENGATE} connection"
)
errorCode=$?
if [ $errorCode -ne 0 ]; then
  echo "Failed to update the password in ${OGGF_LOCAL_GOLDENGATE} connection"
  exit $errorCode
fi
