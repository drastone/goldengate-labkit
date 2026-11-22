#!/bin/bash
## Copyright (c) 2022, Oracle and/or its affiliates.
set -e

#Enable it only for debugging
#set -x

##
##  d e p l o y m e n t - m a i n . s h
##  Execute OGG Deployment
##

##
##  a b o r t
##  Terminate with an error message
##
function abort() {
    echo "Error - $*"
    exit 1
}

:     "${OGG_DEPLOYMENT:=Local}"
:     "${OGG_ADMIN:=oggadmin}"
:     "${OGG_LISTEN_ON:=127.0.0.1}"

:     "${OGG_DEPLOYMENT_HOME:?}"
[[ -d "${OGG_DEPLOYMENT_HOME}" ]] || abort "Deployment storage, '${OGG_DEPLOYMENT_HOME}', not found."
:     "${OGG_TEMPORARY_FILES:?}"
[[ -d "${OGG_TEMPORARY_FILES}" ]] || abort "Deployment temporary storage, '${OGG_TEMPORARY_FILES}', not found."
:     "${OGG_HOME:?}"
[[ -d "${OGG_HOME}"            ]] || abort "Deployment runtime, '${OGG_HOME}'. not found."

NGINX_CRT="$(awk '$1 == "ssl_certificate"     { gsub(/;/, ""); print $NF; exit }' < /etc/nginx/nginx.conf)"
NGINX_KEY="$(awk '$1 == "ssl_certificate_key" { gsub(/;/, ""); print $NF; exit }' < /etc/nginx/nginx.conf)"

export OGG_DEPLOYMENT OGG_ADMIN NGINX_CRT NGINX_KEY

export OGGF_DOMAIN=${OGGF_DOMAIN:=$HOSTNAME}
#echo "OGGF_DOMAIN=$OGGF_DOMAIN"
#echo "HOSTNAME=$HOSTNAME"
#echo "NGINX_CRT=${NGINX_CRT}"
#echo "NGINX_KEY=${NGINX_KEY}"

##
##  g e n e r a t e P a s s w o r d
##  If not already specified, generate a random password with:
##  - at least one uppercase character
##  - at least one lowercase character
##  - at least one digit character
##
function generatePassword {
    if [[ -n "${OGG_ADMIN_PWD}" || -d  "${OGG_DEPLOYMENT_HOME}/Deployment/etc" ]]; then
        return
    fi
    local password
    password="$(openssl rand -base64 9)-$(openssl rand -base64 3)"
    if [[ "${password}" != "${password/[A-Z]/_}" && \
          "${password}" != "${password/[a-z]/_}" && \
          "${password}" != "${password/[0-9]/_}" ]]; then
        export OGG_ADMIN_PWD="${password}"
        echo "----------------------------------------------------------------------------------"
        echo "--  Password for OGG administrative user '${OGG_ADMIN}' is '${OGG_ADMIN_PWD}'"
        echo "----------------------------------------------------------------------------------"
        return
    fi
    generatePassword
}

function generateDeploymentId() {
    deploymentIdFile="${APP_DATA_HOME}/deploymentId"
    echo "${deploymentIdFile}"
    if [ -f "${deploymentIdFile}" ]; then
      echo "reading OGGF_DEPLOYMENT_ID from ${deploymentIdFile}"
#      cat "${deploymentIdFile}"
      line=`grep 'OGGF_DEPLOYMENT_ID=' ${deploymentIdFile} | head -n 1`
      OGGF_DEPLOYMENT_ID=${line#*=}
      export OGGF_DEPLOYMENT_ID
      echo "OGGF_DEPLOYMENT_ID=$OGGF_DEPLOYMENT_ID"
      return
    fi

    deploymentId="$(uuidgen)"
    export OGGF_DEPLOYMENT_ID=${deploymentId}
    echo "OGGF_DEPLOYMENT_ID=$OGGF_DEPLOYMENT_ID" > "${deploymentIdFile}"
    cat "${deploymentIdFile}"
}

##
##  l o c a t e _ j a v a
##  Locate the Java installation and set JAVA_HOME
##
function locate_java() {
    [[ -n "${JAVA_HOME}" ]] && return 0

    local java
    java=$(command -v java)
    [[ -z "${java}" ]] && abort "Java installation not found"

    JAVA_HOME="$(dirname "$(dirname "$(readlink -f "${java}")")")"
    export JAVA_HOME
}

##
##  l o c a t e _ l  i  b _  j  v  m
##  Locate the shared library libjvm.so and set LD_LIBRARY_PATH
##
function locate_lib_jvm() {
    [[ -z "${JAVA_HOME}" ]] && abort "Java installation not found"

    local libjvm
    libjvm="$(find "${JAVA_HOME}" -name libjvm.so | head -1)"
    if [ -z "${libjvm}" ]; then
        echo "Warning: The shared library libjvm.so cannot be located."
    else
        local JVM_LIBRARY_PATH
        JVM_LIBRARY_PATH="$(dirname "${libjvm}" )"
        export LD_LIBRARY_PATH=$JVM_LIBRARY_PATH:$LD_LIBRARY_PATH
    fi
}

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
##  s e t u p _ d e p l o y m e n t _ d i r e c t o r i e s
##  Create and set permissions for directories for the deployment
##
function setup_deployment_directories() {
    rm    -fr        "${OGG_DEPLOYMENT_HOME}"/Deployment/var/{run,temp,lib/db} \
                     "${OGG_TEMPORARY_FILES}"/{run,temp}
    mkdir -p         "${OGG_TEMPORARY_FILES}"/{run,temp,db} \
                     "${OGG_DEPLOYMENT_HOME}"/Deployment/var/lib
    ln -s            "${OGG_TEMPORARY_FILES}"/run  "${OGG_DEPLOYMENT_HOME}"/Deployment/var/run
    ln -s            "${OGG_TEMPORARY_FILES}"/temp "${OGG_DEPLOYMENT_HOME}"/Deployment/var/temp
    ln -s            "${OGG_TEMPORARY_FILES}"/db   "${OGG_DEPLOYMENT_HOME}"/Deployment/var/lib/db

    chown    ogg:ogg "${OGG_DEPLOYMENT_HOME}" "${OGG_TEMPORARY_FILES}"
    chmod    0750    "${OGG_DEPLOYMENT_HOME}" "${OGG_TEMPORARY_FILES}"
    find             "${OGG_DEPLOYMENT_HOME}" "${OGG_TEMPORARY_FILES}" -mindepth 1 -maxdepth 1 -not -name '.*' -exec \
    chown -R ogg:ogg {} \;
}

function setup_user_permissions() {
   DIR=$1
   chown -R ogg:ogg ${DIR}
   chmod -R 744 ${DIR}
   find ${DIR} -type f -exec chmod 644 {} \;
}

##
##  s t a r t _ o g g
##  Initialize and start the OGG installation
##
function start_ogg() {
    $(run_as_ogg) python3 /usr/local/bin/deployment-init.py
    $(run_as_ogg) tail -F "${OGG_DEPLOYMENT_HOME}"/ServiceManager/var/log/ServiceManager.log &
    ogg_pid=$!
}

function setup_nginx() {
  use_old=true
  if [ "$use_old" == "true" ]; then
    CERT_DIR=${APP_HOME}/certificate
    CCERT_DIR=${APP_DATA_HOME}/certificate

    if [ ! -d "${CERT_DIR}" ]; then
      mkdir -p "$CERT_DIR"
    fi
    if [ ! -d "${CCERT_DIR}" ]; then
      mkdir -p "${CCERT_DIR}"
    fi
    export OGG_CLIENTCERT=${CCERT_DIR}/client.pem
    export OGG_CLIENTCERT_KEYFILE=${CERT_DIR}/client-key.pem
    export OGG_SERVERCERT=${CCERT_DIR}/server.pem
    export OGG_SERVERCERT_KEYFILE=${CERT_DIR}/server-key.pem
    CA=${CCERT_DIR}/ca.pem
    CA_KEY=${CERT_DIR}/ca-key.pem
    [[ ! -f "${NGINX_CRT}" || ! -f "${NGINX_KEY}" ]] && {
         DOMAIN=$HOSTNAME
         mkdir -p "$(dirname "${NGINX_CRT}")"
         #echo "/usr/local/bin/gen-certificate.sh --dest=${CCERT_DIR} --server --domain=$DOMAIN --server-crt=${NGINX_CRT} --server-key=${NGINX_KEY} --ca-key=${CA_KEY} --ca=${CA} --client-crt=${CLIENTCERT} --client-key=${CLIENTCERT_KEYFILE} --passphrase=${OGGF_DEPLOYMENT_ID}"
         #/usr/local/bin/gen-certificate.sh --dest=${CCERT_DIR} --server --client --domain=$DOMAIN --server-crt=${NGINX_CRT} --server-key=${NGINX_KEY} --ca-key=${CA_KEY} --ca=${CA} --client-crt=${OGG_CLIENTCERT} --client-key=${OGG_CLIENTCERT_KEYFILE} --passphrase=${OGGF_DEPLOYMENT_ID}
         /usr/local/bin/gen-certificate.sh --dest=${CCERT_DIR} --server --domain=$DOMAIN --server-crt=${NGINX_CRT} --server-key=${NGINX_KEY} --ca-key=${CA_KEY} --ca=${CA} --passphrase=${OGGF_DEPLOYMENT_ID}
    }

    [[ ! -f "${OGG_SERVERCERT}" || ! -f "$OGG_SERVERCERT_KEYFILE}" ]] && {
      cp $NGINX_KEY $OGG_SERVERCERT_KEYFILE
      cp $NGINX_CRT $OGG_SERVERCERT


      #!!Important
      #This is for oggfe to pick up the certificates
      echo "OGG_SERVERCERT=$OGG_SERVERCERT"
      echo "OGG_SERVERCERT_KEYFILE=$OGG_SERVERCERT_KEYFILE"

      #In order to use separate java client such as SSLPoke
      #echo "import $CA to $JAVA_HOME/lib/security/cacerts"
      #keytool -import -noprompt -trustcacerts -file $CA -alias nginx-ca -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
      #echo "import $OGG_SERVERCERT to $JAVA_HOME/lib/security/cacerts"
      #keytool -import -noprompt -trustcacerts -file $OGG_SERVERCERT -alias oggf-server -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
    }

    setup_user_permissions ${CERT_DIR}
    setup_user_permissions ${CCERT_DIR}

    #echo "$CA"; ls -l $CA
    #echo "$OGG_SERVERCERT"; ls -l $OGG_SERVERCERT
  fi
}

##
##  s t a r t _ n g i n x
##  Start the NGinx reverse proxy daemon
##
function start_nginx() {
    replace-variables.sh /etc/nginx/*.conf
    /usr/sbin/nginx -t
    /usr/sbin/nginx
}

##
##  Termination handler
##
function termination_handler() {
    [[ -z "${ogg_pid}" ]] || {
        kill  "${ogg_pid}"
        unset    ogg_pid
    }
    [[ ! -f "/var/run/nginx.pid" ]] || {
        /usr/sbin/nginx -s stop
    }
    exit 0
}

##
##  Signal Handling for this script
##
function signal_handling() {
    trap -                   SIGTERM SIGINT
    trap termination_handler SIGTERM SIGINT
}

##
##  Entrypoint
##
OGG_SECURE_DEPLOYMENT=${OGG_SECURE_DEPLOYMENT:=false}
APP_HOME=${APP_HOME:=/u01/oggf}
if [ ! -d "$APP_HOME" ]; then
  mkdir -p "$APP_HOME"
fi
APP_DATA_HOME=${APP_DATA_HOME:=/u02/oggf}
if [ ! -d "$APP_DATA_HOME" ]; then
  mkdir -p "$APP_DATA_HOME"
fi

generatePassword

echo "OGG_SECURE_DEPLOYMENT=${OGG_SECURE_DEPLOYMENT}"
echo "APP_HOME=${APP_HOME}"
echo "APP_DATA_HOME=${APP_DATA_HOME}"
generateDeploymentId
setup_deployment_directories

setup_nginx
if [ "$OGG_SECURE_DEPLOYMENT" == "true" ]; then
  source /usr/local/bin/setup_ssl.sh
  setup_ssl
fi
locate_java
locate_lib_jvm
start_ogg
start_nginx
signal_handling
wait
