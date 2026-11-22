#!/usr/bin/env bash
set -eu

OSA_DB_CONTAINER="${OSA_DB_CONTAINER:-demo_osrc_23ai}"
OSA_CONTAINER="${OSA_CONTAINER:-demo_centos}"
OSA_DB_HOST="${OSA_DB_HOST:-172.28.0.3}"
OSA_DB_PORT="${OSA_DB_PORT:-1521}"
OSA_DB_SERVICE="${OSA_DB_SERVICE:-ORCLPDB1}"
OSA_SCHEMA="${OSA_SCHEMA:-OSA}"
OSA_PASSWORD="${OSA_PASSWORD:-WElcome1234##}"
OSA_ADMIN_USER="${OSA_ADMIN_USER:-osaadmin}"
OSA_ADMIN_PASSWORD="${OSA_ADMIN_PASSWORD:-$OSA_PASSWORD}"
START_OSA="${START_OSA:-N}"

OSA_BASE="/home/oracle/osa/osa-base"
OSA_BIN="${OSA_BASE}/bin"
OSA_ETC="${OSA_BASE}/etc"
OSA_SSL="${OSA_ETC}/osa-ssl"

echo "==> Prepare OSA metadata schema in ${OSA_DB_CONTAINER}:${OSA_DB_SERVICE}"
docker exec -i "${OSA_DB_CONTAINER}" bash -lc 'sqlplus -s "/ as sysdba"' <<SQL
alter user sys identified by "${OSA_PASSWORD}";
alter session set container=${OSA_DB_SERVICE};

declare
  n number;
begin
  select count(*) into n from dba_users where username = upper('${OSA_SCHEMA}');
  if n = 0 then
    execute immediate 'create user ${OSA_SCHEMA} identified by "${OSA_PASSWORD}" default tablespace users temporary tablespace temp quota unlimited on users';
  end if;
end;
/

alter user ${OSA_SCHEMA} identified by "${OSA_PASSWORD}" account unlock;

grant create session, create table, create view,
      create sequence, create procedure, create trigger,
      create type, create synonym, create job
   to ${OSA_SCHEMA};

grant unlimited tablespace to ${OSA_SCHEMA};

select username, account_status from dba_users where username = upper('${OSA_SCHEMA}');
exit;
SQL

echo "==> Configure OSA datasource"
docker exec -u oracle "${OSA_CONTAINER}" bash -lc "
  set -eu
  cd '${OSA_BIN}'
  enc=\$(./osa-secure-tool.sh '${OSA_PASSWORD}' | sed -n 's/^OSA Secured Password = //p')
  test -n \"\$enc\"
  cd '${OSA_ETC}'
  cp -p osa-datasource.xml osa-datasource.xml.bak_osa26_lab 2>/dev/null || true
  sed -i 's|<Set name=\"URL\">.*</Set>|<Set name=\"URL\">jdbc:oracle:thin:@${OSA_DB_HOST}:${OSA_DB_PORT}/${OSA_DB_SERVICE}</Set>|' osa-datasource.xml
  sed -i 's|<Set name=\"User\">.*</Set>|<Set name=\"User\">${OSA_SCHEMA}</Set>|' osa-datasource.xml
  sed -i \"s|<Set name=\\\"Password\\\">.*</Set>|<Set name=\\\"Password\\\">\${enc}</Set>|\" osa-datasource.xml
"

echo "==> Configure OSA self-signed SSL certificate for lab use"
docker exec -u oracle "${OSA_CONTAINER}" bash -lc "
  set -eu
  mkdir -p '${OSA_SSL}'
  cd '${OSA_SSL}'
  if [ ! -f self-server.p12 ]; then
    openssl req -x509 -newkey rsa:3072 \
      -keyout self-server.key \
      -out self-server.crt \
      -days 365 \
      -subj '/CN=ogg-lab-osa/OU=GGSA/O=Lab/L=Seoul/ST=Seoul/C=KR' \
      -nodes -sha256 >/tmp/osa_openssl_req.log 2>&1
    openssl pkcs12 -export \
      -out self-server.p12 \
      -inkey self-server.key \
      -in self-server.crt \
      -passout pass:'${OSA_PASSWORD}' >/tmp/osa_openssl_p12.log 2>&1
    rm -f self-server.key self-server.crt
  fi

  cd '${OSA_BIN}'
  crt_pwd=\$(./osa-secure-tool.sh '${OSA_PASSWORD}' | sed -n 's/^OSA Secured Password = //p')
  test -n \"\$crt_pwd\"
  cat > '${OSA_SSL}/ssl.conf' <<EOF
NEED_SSL=true
OSA_SERVER_CRT_P12=${OSA_SSL}/self-server.p12
OSA_SERVER_CRT_PWD=\${crt_pwd}
OSA_SERVER_CRT_GENERATED_BY=app
OSA_SERVER_CRT_FAIL_ON_VALIDATIONS=false
EOF
  chmod 600 '${OSA_SSL}/ssl.conf' '${OSA_SSL}/self-server.p12'
"

echo "==> Initialize OSA metadata store"
docker exec -u oracle "${OSA_CONTAINER}" bash -lc "
  cd '${OSA_BIN}'
  ./start-osa.sh --prep-only --no-samples \
    dbroot='SYS AS SYSDBA' \
    dbroot_password='${OSA_PASSWORD}' \
    osaadmin_user='${OSA_ADMIN_USER}' \
    osaadmin_password='${OSA_ADMIN_PASSWORD}'
"

if [ "${START_OSA}" = "Y" ]; then
  echo "==> Start OSA server"
  docker exec -u oracle "${OSA_CONTAINER}" bash -lc "
    mkdir -p '${OSA_BASE}/logs'
    cd '${OSA_BIN}'
    timeout 60 ./stop-osa.sh >'${OSA_BASE}/logs/osa-stop-manual.log' 2>&1 || true
    nohup ./start-osa.sh --no-samples \
      dbroot='SYS AS SYSDBA' \
      dbroot_password='${OSA_PASSWORD}' \
      osaadmin_user='${OSA_ADMIN_USER}' \
      osaadmin_password='${OSA_ADMIN_PASSWORD}' \
      >'${OSA_BASE}/logs/osa-startup-manual.log' 2>&1 < /dev/null &
  "

  echo "==> Wait for OSA HTTPS listener"
  docker exec "${OSA_CONTAINER}" bash -lc '
    for i in $(seq 1 90); do
      netstat -ltn | grep -q ":9443 " && exit 0
      sleep 2
    done
    echo "ERROR: OSA 9443 listener did not open"
    exit 1
  '
else
  echo "INFO: OSA server is not started by setup_osa26.sh."
  echo "INFO: Run bash startOSA.sh from the Host Linux layer when the OSA/GGSA lab begins."
fi

echo "OK: OSA 26ai setup completed"
