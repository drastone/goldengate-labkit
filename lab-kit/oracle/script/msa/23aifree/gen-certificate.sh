#! /bin/bash

set -e

DEST="."
DOMAIN="localhost"
SERVER_CRT="server.pem"
SERVER_KEY="server.key"
CLIENT_CRT="client.pem"
CLIENT_KEY="client.key"
SERVER_CRT_P12="server.p12"
CA_KEY="ca-key.pem"
CA="ca.pem"
PASS_PHRASE=""

show_crt=false
need_fullchain=true

create_server=true
convert_p12=false

#Starting on September 1st (2020), SSL/TLS SERVER_CRTs cannot be issued for longer than 13 months (397 days
DAYS=397

verbose=false
for arg in "$@"; do
    case "$arg" in
    --verbose)
      verbose=true
      ;;
    --p12=*)
      convert_p12=true
      SERVER_CRT_P12="${arg#*=}"
      ;;
    --server)
      create_server=true
      ;;
    --client)
      create_client=true
      ;;
    --domain=*)
      DOMAIN="${arg#*=}"
      ;;
    --server-crt=*)
      SERVER_CRT="${arg#*=}"
      ;;
    --server-key=*)
      SERVER_KEY="${arg#*=}"
      ;;
    --client-crt=*)
      CLIENT_CRT="${arg#*=}"
      ;;
    --client-key=*)
      CLIENT_KEY="${arg#*=}"
      ;;
    --ca=*)
      CA="${arg#*=}"
      ;;
    --ca-key=*)
      CA_KEY="${arg#*=}"
      ;;
    --dest=*)
      DEST="${arg#*=}"
      ;;
    --passphrase=*)
      PASS_PHRASE="${arg#*=}"
      ;;
    --no-fullchain)
      need_fullchain=false
      ;;
    --show)
      show_crt=true
      ;;
    esac
done

function trace() {
  if [ "$verbose" == "true" ]; then
    echo "---- $1"
  fi
}

function combineCrtCa() {
  crt=$1
  ca=$2

  FULLCHAIN=${crt}.full

  cat ${crt} > ${FULLCHAIN}
  if [ -f "$ca" ]; then
    cat ${ca} >> ${FULLCHAIN}
  fi
  trace "******************************** $FULLCHAIN ********************************"
  #cat ${FULLCHAIN}
  if [ -f "$ca" ]; then
    openssl verify -CAfile ${ca} -verbose ${FULLCHAIN}
  else
     openssl verify -verbose ${FULLCHAIN}
  fi
  cp ${crt} ${crt}.partial
  mv ${crt}.full ${crt}
}

function createServerCrt() {
    trace "******************************** Creating Server Crt ********************************"
# Create ca conf
cat > ca.conf <<EOF
[ req ]
default_bits = 4096
prompt = no
default_md = sha256
x509_extensions = v3_ca
distinguished_name = dn

[ dn ]
C = US
ST = California
L = Redwood Shores
O = Oracle
OU = Goldengate CA

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = critical,keyCertSign

EOF

if [ ! -f $CA ]; then
  # Create CA and private key
  trace  "creating ca=$CA"
  trace  "openssl req -x509 -sha256 -days $DAYS -nodes -newkey rsa:4096 -config ca.conf -keyout ${CA_KEY} -out ${CA} -passin pass:${PASS_PHRASE}"
  openssl req -x509 -sha256 -days $DAYS -nodes -newkey rsa:4096 -config ca.conf -keyout ${CA_KEY} -out ${CA} -passin pass:${PASS_PHRASE}
  if [ "$show_crt" == "true" ]; then
    trace  "******************************** $CA ********************************"
    trace  "openssl x509 -in ${CA} -text"
    openssl x509 -in ${CA} -text
  fi
else
  trace  "using existing ca=$CA"
  #ls -l $CA
fi

# Generate Private key
trace  "openssl genrsa -out ${SERVER_KEY} 4096"
openssl genrsa -out ${SERVER_KEY} -passout pass:${PASS_PHRASE} 4096

# create CSR request using private key
trace  "openssl req -new -sha256 -key ${SERVER_KEY} -out oggfe.csr -subj "/CN=${DOMAIN}" -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}"
openssl req -new -sha256 -key ${SERVER_KEY} -out oggfe.csr -subj "/CN=${DOMAIN}" -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}

echo "subjectAltName=DNS:${DOMAIN},DNS:localhost,IP:127.0.0.1" > extfile.cnf
echo extendedKeyUsage = serverAuth >> extfile.cnf

# Create SERVER_CRT with self signed CA
trace  "creating ca=$CA server_crt=$SERVER_CRT"
trace  "openssl x509 -req -in oggfe.csr -CA ${CA} -CAkey ${CA_KEY}  -CAcreateserial -out ${SERVER_CRT} -days $DAYS -sha256 -extfile extfile.cnf -passin pass:${PASS_PHRASE}"
openssl x509 -req -in oggfe.csr -CA ${CA} -CAkey ${CA_KEY}  -CAcreateserial -out ${SERVER_CRT} \
    -days $DAYS -sha256 -extfile extfile.cnf -passin pass:${PASS_PHRASE}

if [ "$need_fullchain" == "true" ]; then
  combineCrtCa ${SERVER_CRT} ${CA}
fi

if [ "$create_client" == "true" ]; then
  # Generate Client Private key
  trace  "openssl genrsa -out ${CLIENT_KEY} 4096"
  openssl genrsa -out ${CLIENT_KEY} -passout pass:${PASS_PHRASE} 4096

  # create Client CSR request using private key
  trace  "openssl req -new -sha256 -key ${CLIENT_KEY} -out client.csr -subj "/CN=${DOMAIN}" -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}"
  openssl req -new -sha256 -key ${CLIENT_KEY} -out client.csr -subj "/CN=${DOMAIN}" -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}

  cat > extfile <<EOF
basicConstraints = CA:FALSE
nsCertType = client
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

  # Create CLIENT_CRT with self signed CA
  trace  "creating ca=$CA client_crt=$CLIENT_CRT"
  trace  "openssl x509 -req -in client.csr -CA ${CA} -CAkey ${CA_KEY}  -CAcreateserial -out ${CLIENT_CRT} -days $DAYS -sha256 -extfile extfile.cnf -passin pass:${PASS_PHRASE}"
  openssl x509 -req -in client.csr -CA ${CA} -CAkey ${CA_KEY}  -CAcreateserial -out ${CLIENT_CRT} \
      -days $DAYS -sha256 -extfile extfile.cnf -passin pass:${PASS_PHRASE}

  if [ "$need_fullchain" == "true" ]; then
    combineCrtCa ${CLIENT_CRT} ${CA}
  fi

fi

[ -f extfile.cnf ] && rm extfile.cnf
[ -f oggfe.csr ] && rm oggfe.csr
[ -f client.csr ] && rm client.csr

if [ "$show_crt" == "true" ]; then
  trace  "******************************** $SERVER_CRT ********************************"
  openssl x509 -text -noout -in ${SERVER_CRT}  -passin pass:${PASS_PHRASE}
fi

trace "verifying $CA $SERVER_CRT"
openssl verify -CAfile ${CA} -verbose ${SERVER_CRT}

if [ -f "$CLIENT_CRT" ]; then
  trace "verifying $CA $CLIENT_CRT"
  openssl verify -CAfile ${CA} -verbose ${CLIENT_CRT}
fi

# To Test
#openssl s_client -connect oggf:443

#echo "openssl s_client -showcerts -servername www.oracle.com -connect www.oracle.com:443 > cacert.pem"
#echo quit | openssl s_client -showcerts -servername www.oracle.com -connect www.oracle.com:443 > cacert.pem
#openssl x509 -text -noout -in cacert.pem

}

function convertToP12() {
  trace "******************************** Creating P12 ********************************"

  # Combine private key and public SERVER_CRT
  trace "generating $SERVER_CRT_P12"
  if [ -f "$CA" ]; then
    trace "openssl pkcs12 -inkey ${SERVER_KEY} -in ${SERVER_CRT} -export -out ${SERVER_CRT_P12} -CAfile ${CA} -chain -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}"
    openssl pkcs12 -inkey ${SERVER_KEY} -in ${SERVER_CRT} -export -out ${SERVER_CRT_P12} -CAfile ${CA} -chain -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}
    trace "******************************** $SERVER_CRT_P12 ********************************-"
    if [ "$show_crt" == "true" ]; then
      openssl pkcs12 -info -in ${SERVER_CRT_P12}  -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}
    fi
    #cannot verify p12 without TRUSTED_CERTIFICATE
    #e.g. not working with SELF-SIGNED_CERTIFICATE
    #trace "openssl verify -CAfile ${CA} -verbose ${SERVER_CRT_P12}"
    #openssl verify -CAfile ${CA} -verbose ${SERVER_CRT_P12}
  else
    trace "openssl pkcs12 -inkey ${SERVER_KEY} -in ${SERVER_CRT} -export -out ${SERVER_CRT_P12} -chain -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}"
    openssl pkcs12 -inkey ${SERVER_KEY} -in ${SERVER_CRT} -export -out ${SERVER_CRT_P12} -chain -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}
    trace "******************************** $SERVER_CRT_P12 ********************************-"
    if [ "$show_crt" == "true" ]; then
      trace "pkcs12 -info -in ${SERVER_CRT_P12}  -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}"
      openssl pkcs12 -info -in ${SERVER_CRT_P12}  -passin pass:${PASS_PHRASE} -passout pass:${PASS_PHRASE}
    fi
  fi
}

trace create_server=$create_server
trace create_client=$create_client
trace convert_p12=$convert_p12
trace DEST=$DEST
trace DOMAIN=$DOMAIN
trace SERVER_CRT=$SERVER_CRT
trace SERVER_KEY=$SERVER_KEY
trace CA_KEY=$CA_KEY
trace CA=$CA

if [ "$DEST" != "." ]; then
  mkdir -p $DEST
fi


pushd $DEST
if [ "$create_server" == "true" ]; then
  createServerCrt
fi
if [ "$convert_p12" == "true" ]; then
  convertToP12
fi

if [ "$create_client" == "true" ]; then
  if [ ! -f "$CLIENT_CRT" ]; then
    cp ${SERVER_CRT} ${CLIENT_CRT}
    cp ${SERVER_KEY} ${CLIENT_KEY}
  fi
fi

[ -f ca.conf ] && rm ca.conf
[ -f ca.srl ] && rm ca.srl

popd
