function setup_ssl() {
   echo "--- Setup ssl for secure deployment ---"
   SSL_DIR="${OGG_DEPLOYMENT_HOME}"/ssl

   export OGGF_DOMAIN=${OGGF_DOMAIN:=$HOSTNAME}
   export OGG_SERVERCERT=${SSL_DIR}/server.pem
   export OGG_SERVERCERT_KEYFILE=${SSL_DIR}/server-key.pem
   export OGG_SERVERCERT_KEYFILE_PWD=${OGGF_DEPLOYMENT_ID}
   export OGG_CLIENTCERT=${SSL_DIR}/client.pem
   export OGG_CLIENTCERT_KEYFILE=${SSL_DIR}/client-key.pem
   export OGG_CLIENTCERT_KEYFILE_PWD=${OGGF_DEPLOYMENT_ID}

   export OGGF_SERVER_CRT_P12=${SSL_DIR}/server.p12
   export OGGF_CLIENT_CRT_P12=${SSL_DIR}/client.p12

   export OGGF_SERVER_CRT_PWD=${OGGF_DEPLOYMENT_ID}
   export OGGF_CLIENTCERT_PWD=${OGGF_DEPLOYMENT_ID}

    if [ -f "${OGG_SERVERCERT}" ]; then
        echo "${OGG_SERVERCERT} exist -- skip"
        return
    fi

   #This is for OGGF to pick up the certificate file names
   echo "OGG_SERVERCERT=$OGG_SERVERCERT"
   echo "OGG_SERVERCERT_KEYFILE=$OGG_SERVERCERT_KEYFILE"
   echo "OGG_CLIENTCERT=$OGG_CLIENTCERT"
   echo "OGG_CLIENTCERT_KEYFILE=$OGG_CLIENTCERT_KEYFILE"

   local USE_OLD_GEN=false
   if [ "$USE_OLD_GEN" == "true" ]; then
     CA=${SSL_DIR}/ca.pem
     CA_KEY=${SSL_DIR}/ca-key.pem
     mkdir -p "$(dirname "${NGINX_CRT}")"
     mkdir -p "$(dirname "${CA}")"
     #echo "/usr/local/bin/gen-certificate.sh --dest=${APP_DATA_HOME}/config --server --domain=$OGGF_DOMAIN --server-crt=${OGG_SERVERCERT} --server-key=${OGG_SERVERCERT_KEYFILE} --ca-key=${CA_KEY} --ca=${CA} --passphrase=${OGGF_DEPLOYMENT_ID}"
     /usr/local/bin/gen-certificate.sh --dest=${APP_DATA_HOME}/config --server --domain=$OGGF_DOMAIN --server-crt=${OGG_SERVERCERT} --server-key=${OGG_SERVERCERT_KEYFILE} --ca-key=${CA_KEY} --ca=${CA} --passphrase=${OGGF_DEPLOYMENT_ID}
     #--client-crt=${OGG_CLIENTCERT} --client-key=${OGG_CLIENTCERT_KEYFILE}
   fi

   local CommonOU="CN=${OGGF_DOMAIN},OU=GoldenGate,OU=Enterprise Replication,OU=Server Technology,O=Oracle Corp,L=Redwood Shores,ST=CA,C=US"

   local SERVER_WALLET_DIR=${SSL_DIR}/wallet
   mkdir -p ${SERVER_WALLET_DIR}
   chmod 744 ${SERVER_WALLET_DIR}

   export WALLET_LOG=${WALLET_LOG:-/dev/null}

   export OGG_WALLET_PWD=${OGGF_DEPLOYMENT_ID}
   #create root ca
   orapki wallet create -wallet ${SERVER_WALLET_DIR}/root_ca -auto_login -pwd "${OGG_WALLET_PWD}" &> $WALLET_LOG
   orapki wallet add -wallet ${SERVER_WALLET_DIR}/root_ca -dn "CN=RootCA" -keysize 2048 -self_signed -validity 7300 -pwd "${OGG_WALLET_PWD}" -sign_alg sha256 &>> $WALLET_LOG
   orapki wallet export -wallet ${SERVER_WALLET_DIR}/root_ca -dn "CN=RootCA" -cert ${SERVER_WALLET_DIR}/rootCA_Cert.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   #create server wallet
   orapki wallet create  -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -pwd "${OGG_WALLET_PWD}" -auto_login &>> $WALLET_LOG
   orapki wallet add -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -dn "${CommonOU}" -keysize 2048 -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet export -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -dn "${CommonOU}" -request ${SERVER_WALLET_DIR}/servername_req.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki cert create -wallet ${SERVER_WALLET_DIR}/root_ca -request ${SERVER_WALLET_DIR}/servername_req.pem -cert ${SERVER_WALLET_DIR}/servername_Cert.pem -serial_num 20 -validity 375  -sign_alg sha256 &>> $WALLET_LOG
   orapki wallet add -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -trusted_cert -cert ${SERVER_WALLET_DIR}/rootCA_Cert.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet add -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -user_cert -cert ${SERVER_WALLET_DIR}/servername_Cert.pem  -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   #orapki wallet add     -wallet ${SSL_DIR}/wallet/${OGGF_DOMAIN} -pwd "${OGG_WALLET_PWD}" -dn "CN=${CommonOU}" -keysize 2048 -self_signed -validity 7300 &>> $WALLET_LOG
   #orapki wallet add     -wallet ${SSL_DIR}/wallet/${OGGF_DOMAIN} -pwd "${OGG_WALLET_PWD}" -trusted_cert -cert ${OGG_SERVERCERT} &>> $WALLET_LOG
   #create client wallet
   local CLIENT_WALLET_DIR=${SSL_DIR}/cwallet
   mkdir -p ${CLIENT_WALLET_DIR}
   chmod 744 ${CLIENT_WALLET_DIR}
   orapki wallet create -wallet ${CLIENT_WALLET_DIR} -auto_login -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet add -wallet ${CLIENT_WALLET_DIR} -dn "${CommonOU}" -keysize 2048 -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet export -wallet ${CLIENT_WALLET_DIR} -dn "${CommonOU}" -request ${CLIENT_WALLET_DIR}/client_req.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki cert create -wallet ${SERVER_WALLET_DIR}/root_ca -request ${CLIENT_WALLET_DIR}/client_req.pem -cert ${CLIENT_WALLET_DIR}/client_Cert.pem -serial_num 30 -validity 375 -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet add -wallet ${CLIENT_WALLET_DIR} -trusted_cert -cert ${SERVER_WALLET_DIR}/rootCA_Cert.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   orapki wallet add -wallet ${CLIENT_WALLET_DIR} -user_cert -cert ${CLIENT_WALLET_DIR}/client_Cert.pem -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG

   export OGG_SERVER_WALLET=${SERVER_WALLET_DIR}/${OGGF_DOMAIN}
   echo "OGG_SERVER_WALLET=${OGG_SERVER_WALLET}"
   export OGG_CLIENT_WALLET=$CLIENT_WALLET_DIR
   echo "OGG_CLIENT_WALLET=${OGG_CLIENT_WALLET}"

   chmod 744 ${SSL_DIR}
   rm -rf $SERVER_WALLET_DIR/${OGGF_DOMAIN}/*.lck
   rm -rf $CLIENT_WALLET_DIR/*.lck

   #extract server.pem, server-key.pem
   echo "extracting server.pem,p12"
   #orapki wallet export -wallet ${SERVER_WALLET_DIR}/${OGGF_DOMAIN} -dn "${CommonOU}" -cert ${OGG_SERVERCERT} -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   openssl pkcs12 -in ${SERVER_WALLET_DIR}/${OGGF_DOMAIN}/ewallet.p12 -nokeys -out ${OGG_SERVERCERT} -passin pass:${OGG_WALLET_PWD}
   openssl pkcs12 -in ${SERVER_WALLET_DIR}/${OGGF_DOMAIN}/ewallet.p12 -nocerts -out ${OGG_SERVERCERT_KEYFILE} -passin pass:${OGG_WALLET_PWD}  -passout pass:${OGG_WALLET_PWD}
   openssl pkcs12 -export -in ${OGG_SERVERCERT} -inkey ${OGG_SERVERCERT_KEYFILE} -out ${OGGF_SERVER_CRT_P12} -passin pass:${OGG_WALLET_PWD}  -passout pass:${OGGF_SERVER_CRT_PWD}

   #extract client.pem, client-key.pem
   echo "extracting client.pem,p12"
   #orapki wallet export -wallet ${CLIENT_WALLET_DIR} -dn "${CommonOU}" -cert  ${OGG_CLIENTCERT} -pwd "${OGG_WALLET_PWD}" &>> $WALLET_LOG
   openssl pkcs12 -in ${CLIENT_WALLET_DIR}/ewallet.p12 -nokeys -out ${OGG_CLIENTCERT} -passin pass:${OGG_WALLET_PWD}
   openssl pkcs12 -in ${CLIENT_WALLET_DIR}/ewallet.p12 -nocerts -out ${OGG_CLIENTCERT_KEYFILE} -passin pass:${OGG_WALLET_PWD}   -passout pass:${OGG_WALLET_PWD}
   openssl pkcs12 -export -in ${OGG_CLIENTCERT} -inkey ${OGG_CLIENTCERT_KEYFILE} -out ${OGGF_CLIENT_CRT_P12} -passin pass:${OGG_WALLET_PWD}  -passout pass:${OGGF_CLIENTCERT_PWD}

   setup_user_permissions ${SSL_DIR}

use_new=false
if [ "$use_new" == "true" ]; then
   mkdir -p "$(dirname "${NGINX_CRT}")"
   cp ${OGG_SERVERCERT} ${NGINX_CRT}
   cp ${OGG_SERVERCERT_KEYFILE} ${NGINX_KEY}
   ls -l ${NGINX_CRT}
   ls -l ${NGINX_KEY}

   #Copy client certificate
   CERT_DIR=${APP_HOME}/certificate
   mkdir -p "$CERT_DIR"
   cp ${SERVER_WALLET_DIR}/rootCA_Cert.pem ${CERT_DIR}/ca.pem
   setup_user_permissions ${CERT_DIR}
   ls -l ${CERT_DIR}/ca.pem

   CCERT_DIR=${APP_DATA_HOME}/certificate
   mkdir -p "${CCERT_DIR}"
   cp ${OGG_CLIENTCERT} ${CCERT_DIR}/client.pem
   setup_user_permissions ${CERT_DIR}
   ls -l ${CCERT_DIR}/client.pem
fi
   #echo "-- $SSL_DIR --"
   #ls -l ${SSL_DIR}
   #echo "-- $SERVER_WALLET_DIR --"
   #ls -l $SERVER_WALLET_DIR
   #echo "-- $CLIENT_WALLET_DIR --"
   #ls -l $CLIENT_WALLET_DIR
}
