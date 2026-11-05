## Lab Kit에 APEX 26.1과 ORDS 26.2.3 설치

`demo_otrg_23ai` container에는 처음부터 APEX/ORDS가 준비되어 있지 않을 수 있다. 이 경우 GoldenGate 통합 Console을 import하기 전에 Target DB container에 APEX와 ORDS를 설치한다. 이 책은 재현성을 위해 다음 version을 기준으로 한다.

표 12.5 APEX/ORDS 설치 기준 version

| 구성 요소 | 기준 version | 비고 |
|---|---|---|
| APEX | Oracle APEX 26.1 All languages | APEXlang 26.1.0 기준 |
| ORDS | Oracle REST Data Services 26.2.3.237.1104 | Standalone mode |
| PDB | `ORCLPDB1` | APEX와 ORDS가 연결될 PDB |
| Console schema | `GGADMIN` | App 101 owner/parsing schema |

APEX와 ORDS 설치 media는 3장의 제품 media 일괄 다운로드 단계에서 이미 `/home/oracle/oracle/pkg`에 준비했다. `check_labkit.sh`는 두 파일의 존재 여부와 공식 digest를 검사하며, 하나라도 없거나 값이 다르면 container 생성 전에 `ERROR`로 중단한다. 따라서 12장에서는 제품 media를 다시 다운로드하지 않고, 3장의 사전 점검을 통과한 파일을 그대로 사용한다.

```bash
ls -lh /home/oracle/oracle/pkg/apex_26.1.zip
ls -lh /home/oracle/oracle/pkg/ords-26.2.3.237.1104.zip
```

3장에서 파일을 준비한 뒤 `create_docker.sh`로 새 환경을 만들었다면 두 ZIP은 Target DB image의 `/home/oracle/pkg`에도 포함되어 있다. 과거 Lab Kit으로 이미 만든 container를 재사용하거나 container 안에 파일이 없는 경우까지 처리하기 위해 수동 설치를 시작하기 전에 `lab12_prepare_media.sh`로 host 파일의 digest를 다시 확인하고 필요한 파일만 Target DB container로 복사한다. 전체 자동 설치를 수행하는 `lab12_init.sh`는 이 수동 절차에서는 실행하지 않는다.

```text
[root@DESKTOP-4F78VMG oracle]# cd /home/oracle/labs/lab12
[root@DESKTOP-4F78VMG lab12]# bash lab12_prepare_media.sh
[2026-11-05 14:40:10] ==> START: lab12-prepare-media
OK: sha256sum /home/oracle/oracle/pkg/apex_26.1.zip
OK: sha1sum /home/oracle/oracle/pkg/ords-26.2.3.237.1104.zip
...
[2026-11-05 14:40:12] OK: lab12-prepare-media completed.
```

`OK: lab12-prepare-media completed.`가 표시되면 APEX 수동 설치를 시작한다. 여기서 중요한 점은 APEX를 CDB root가 아니라 `ORCLPDB1`에 설치한다는 것이다.

```bash
docker exec -it demo_otrg_23ai bash

mkdir -p /home/oracle/apex_install
chown oracle:oinstall /home/oracle/apex_install
su - oracle
unzip -q /home/oracle/pkg/apex_26.1.zip -d /home/oracle/apex_install
cd /home/oracle/apex_install/apex

sqlplus / as sysdba
```

```sql
alter session set container=ORCLPDB1;

@apexins.sql SYSAUX SYSAUX TEMP /i/
```

설치가 정상 완료되면 다음과 같은 메시지가 보인다.

```text
Thank you for installing Oracle APEX 26.1.0

Oracle APEX is installed in the APEX_260100 schema.

The structure of the link to the Oracle APEX Administration Services is as follows:
http://host:port/ords/apex_admin

The structure of the link to the Oracle APEX development environment is as follows:
http://host:port/ords/apex
```

설치 후에는 `DBA_REGISTRY`에서 APEX 상태를 확인한다.

```sql
select comp_id, comp_name, version, status
from dba_registry
where comp_id = 'APEX';
```

예상 결과는 다음과 같다.

```text
COMP_ID  COMP_NAME      VERSION  STATUS
-------  -------------  -------  ------
APEX     Oracle APEX    26.1.0   VALID
```

APEX 관련 계정도 확인한다.

```sql
select username, account_status
from dba_users
where username like 'APEX_%'
   or username in ('APEX_PUBLIC_USER','APEX_REST_PUBLIC_USER','APEX_PUBLIC_ROUTER')
order by username;
```

```text
USERNAME               ACCOUNT_STATUS
---------------------  --------------
APEX_260100            LOCKED
APEX_PUBLIC_ROUTER     OPEN
APEX_PUBLIC_USER       OPEN
```

`APEX_260100`은 APEX 내부 metadata schema이므로 `LOCKED` 상태가 정상이다. 이어서 APEX Instance Administrator 계정을 만든다.

```sql
@apxchpwd.sql
```

실습에서는 `ADMIN` 계정을 생성하고 Lab Kit 공통 실습용 password인 `WElcome1234##`를 사용한다. 이 값은 개인 PC의 폐쇄형 실습 환경을 위한 공개 password이며, 운영 환경에서는 계정별 password를 분리하고 secret 관리 체계를 사용한다.

```text
User "ADMIN" does not yet exist and will be created.
Created instance administrator ADMIN.
```

APEX REST 관련 계정은 다음 script로 구성한다.

```sql
@apex_rest_config.sql
```

완료 후 다시 계정을 확인하면 `APEX_LISTENER`와 `APEX_REST_PUBLIC_USER`가 추가되어 있어야 한다.

```text
USERNAME               ACCOUNT_STATUS
---------------------  --------------
APEX_260100            LOCKED
APEX_LISTENER          OPEN
APEX_PUBLIC_ROUTER     OPEN
APEX_PUBLIC_USER       OPEN
APEX_REST_PUBLIC_USER  OPEN
```

이제 ORDS를 설치한다. ORDS product directory와 configuration directory는 분리한다. ORDS가 product directory 아래에 configuration을 두면 upgrade 시 설정이 함께 지워질 수 있으므로, 이 책에서는 `/home/oracle/ords`와 `/home/oracle/ords_config`를 분리한다.

```bash
exit

cd /home/oracle/pkg
mkdir -p /home/oracle/ords
mkdir -p /home/oracle/ords_config
mkdir -p /home/oracle/ords_logs

unzip -q ords-26.2.3.237.1104.zip -d /home/oracle/ords
```

`--config` 옵션을 명시해 ORDS가 사용할 configuration directory를 고정한다.

```bash
export JAVA_HOME=/usr/java/default
export PATH="$JAVA_HOME/bin:$PATH"
/home/oracle/ords/bin/ords --config /home/oracle/ords_config --version
```

정상 출력 예시는 다음과 같다.

```text
Configuration:
  /home/oracle/ords_config

Oracle REST Data Services 26.2.3.r2371104
```

이제 interactive install을 수행한다. ORDS와 Oracle Database가 같은 container에서
실행되므로 SYS password를 입력하는 대신 Oracle이 지원하는 bequeath connection을
사용한다. 이 방식은 OS 인증으로 database installer 권한을 얻고, listener를 통한
SYS 로그인을 만들지 않는다.

```bash
export ORACLE_HOME=/opt/oracle/product/26ai/dbhome_1
export ORACLE_SID=ORCLCDB
export LD_LIBRARY_PATH="$ORACLE_HOME/lib:${LD_LIBRARY_PATH:-}"

/home/oracle/ords/bin/ords \
  --java-options "-DuseOracleHome=true" \
  --config /home/oracle/ords_config \
  install --interactive --bequeath-connect \
  --log-folder /home/oracle/ords_logs
```

TNS 목록이 표시되면 `ORCLPDB1`을 선택한다. APEX를 `ORCLPDB1`에 설치했으므로 ORDS도 같은 PDB에 연결해야 한다. `ORCLCDB`를 선택하면 APEX runtime schema가 있는 PDB와 맞지 않는다.

```text
Enter a number to select the TNS net service name ...
  [1] ORCLCDB      SERVICE_NAME=ORCLCDB
  [2] ORCLPDB1     SERVICE_NAME=ORCLPDB1
  [S] Specify the database connection
Choose [1]: 2
```

bequeath connection에서는 관리자 사용자명과 password를 입력하지 않는다. 다만
ORDS runtime user인 `ORDS_PUBLIC_USER`의 password를 묻는 항목에는 Lab Kit 공통
실습 password `WElcome1234##`를 입력한다. 운영 환경에서는 별도의 강력한 password와
secret 관리 방식을 사용한다.

ORDS 설치 요약 화면이 나오면 `APEX static resources location`을 확인한다. 기본값이 `null`이면 `9`를 선택해 APEX images directory를 입력한다.

```text
[9]   APEX static resources location: null
Choose [A]: 9
Enter the APEX static resources location: /home/oracle/apex_install/apex/images
```

다시 표시되는 요약 화면에서 값이 다음처럼 들어갔는지 확인한 뒤 `A`를 선택한다.

```text
[9]   APEX static resources location: /home/oracle/apex_install/apex/images
[A] Accept and Continue - Create configuration and Install ORDS in the database
Choose [A]: A
```

이 값이 비어 있으면 브라우저에서 APEX 로그인 화면이 CSS 없이 깨지고, "Oracle APEX files have not been loaded" 메시지가 보일 수 있다. APEX 설치 때 지정한 image prefix는 `/i/`이고, ORDS는 이 `/i/` 요청을 `/home/oracle/apex_install/apex/images`의 static file로 서비스해야 한다. 따라서 이 책의 Lab Kit에서는 `reset_image_prefix.sql`로 CDN 경로를 지정하지 않고, ORDS가 local images directory를 서비스하도록 구성한다.

설치가 완료되면 다음 메시지를 확인한다.

```text
Mapped local pools from /home/oracle/ords_config/databases:
  /ords/                              => default                        => VALID

Oracle REST Data Services initialized
Oracle REST Data Services version : 26.2.3.r2371104
```

`/ords/ => default => VALID`는 ORDS URL context가 database pool에 정상 연결되었다는 뜻이다. `Oracle REST Data Services initialized`가 보이면 standalone ORDS가 정상 기동된 상태다.

여기서 한 가지 주의할 점이 있다. Interactive install 직후의 ORDS는 terminal에 붙은 foreground process로 실행된다. 화면 캡처와 설치 확인이 끝났다면 `Ctrl+C`로 빠져나와도 된다. 설치 정보와 ORDS configuration은 이미 `/home/oracle/ords_config`에 저장되어 있으므로 사라지지 않는다. 다만 `Ctrl+C`를 누르면 현재 떠 있던 ORDS process는 종료된다.

따라서 이후부터는 foreground terminal을 계속 붙잡아 두지 말고, Lab Kit에서 제공하는 startup script로 ORDS를 background로 기동한다. 이 파일은 host의 Lab Kit 기준으로 `oracle/pkg/start_ords.sh`에 들어 있으며, `create_docker.sh` 실행 시 `oracle/init.sh`가 container 내부의 `/home/oracle/apex/start_ords.sh`로 복사한다.

`start_ords.sh`는 ORDS 기동 전에 `${ORDS_CONFIG}/global/standalone/etc/jetty-http.xml`도 함께 보강한다. APEX App import처럼 브라우저가 SQL export 파일을 업로드하는 작업은 네트워크가 느리거나 Windows `portproxy`/공유기 port forwarding 경로를 지날 때 ORDS standalone의 기본 Jetty idle timeout 30초에 걸릴 수 있다. 이 경우 ORDS log에는 다음과 같은 메시지가 남고, 브라우저에는 `ERR_CONNECTION_RESET`처럼 보일 수 있다.

```text
POST /ords/wwv_flow.accept?p_context=app-builder/import/... 500
java.util.concurrent.TimeoutException: Idle timeout expired: 30000/30000 ms
```

Lab Kit helper는 이 값을 300000ms, 즉 5분으로 늘려 import와 같은 긴 POST 요청이 중간에 끊기지 않도록 한다. 운영 환경에서는 단순히 timeout을 크게 늘리기보다 reverse proxy, 업로드 크기, 네트워크 품질, 접근 제어를 함께 검토한다.

이미 만들어 둔 container를 재사용 중이라면 아직 `/home/oracle/apex/start_ords.sh`가 없을 수 있다. 이 경우에는 Lab Kit 파일을 최신으로 받은 뒤 `oracle/init.sh`를 한 번 다시 실행하거나, 다음처럼 현재 target container에 helper만 복사한다.

```bash
docker cp /home/oracle/oracle/pkg/start_ords.sh demo_otrg_23ai:/home/oracle/pkg/start_ords.sh

docker exec -u root demo_otrg_23ai bash -lc "
  mkdir -p /home/oracle/apex
  cp -p /home/oracle/pkg/start_ords.sh /home/oracle/apex/start_ords.sh
  chown oracle:oinstall /home/oracle/apex/start_ords.sh
  chmod 755 /home/oracle/apex/start_ords.sh
"
```

```bash
/home/oracle/apex/start_ords.sh
```

정상적으로 기동되면 다음처럼 log file 위치가 표시된다.

```text
[2026-09-22 00:45:10] ORDS started in background. pid=12345 log=/home/oracle/ords_logs/ords-standalone.log
```

같은 script를 다시 실행해도 ORDS가 이미 떠 있으면 중복 기동하지 않는다.

```text
[2026-09-22 00:46:02] ORDS is already running for config /home/oracle/ords_config.
```

필요하면 다음처럼 process와 log를 확인한다.

```bash
ps -ef | grep '[o]rds'
tail -n 40 /home/oracle/ords_logs/ords-standalone.log
```

독자가 매번 이 명령을 직접 실행할 필요는 없다. Lab Kit의 `startDocker.sh`는 container 기동 후 ORDS static path를 점검하고, ORDS가 내려가 있으면 `/home/oracle/apex/start_ords.sh`를 통해 다시 기동하도록 구성한다. 즉 APEX/ORDS 설치는 한 번만 수행하고, 이후 실습 재개는 `startDocker.sh`를 기준으로 진행한다.

브라우저 또는 `curl`로 endpoint를 확인한다.

```bash
curl -I http://localhost:8080/ords/
curl -I http://localhost:36080/ords/
```

Windows host의 브라우저에서는 다음 URL을 사용한다.

```text
http://localhost:36080/ords/apex
http://localhost:36080/ords/apex_admin
```

개인 PC에서 화면을 캡처하거나 다른 장비의 browser로 접속해야 한다면, Windows portproxy와 공유기 port forwarding을 이용해 다음처럼 공인 IP로 접근할 수도 있다.

```text
http://219.240.178.144:36080/ords/apex
```

이 경로가 동작하려면 Docker port publish가 id10 예제처럼 `36080:8080` 형식이어야 한다. Docker가 `127.0.0.1:36080->8080`으로 떠 있으면 Windows portproxy가 WSL IP의 `36080`으로 넘겨도 받을 listener가 없으므로 외부 접속이 실패한다. 이 책의 Lab Kit compose file은 개인 PC 실습 편의를 위해 `127.0.0.1:` prefix를 붙이지 않는 형식을 기본으로 둔다.

```yaml
ports:
  - "36080:8080"
```

이미 생성된 container의 port binding은 실행 중에 바꿀 수 없다. 기존 container가 `127.0.0.1:36080->8080`으로 만들어져 있다면 compose file을 고친 뒤 container recreate가 필요하다. 단, Database container를 recreate하면 container 내부에 설치한 APEX/ORDS와 DB 변경 사항이 사라질 수 있으므로, 현재 실습 중인 container에는 먼저 Windows `portproxy` 예외 처리나 SSH tunnel을 임시로 사용하고, 새 Lab Kit를 만들 때 compose 기준을 반영하는 것이 안전하다.

공용 서버나 cloud VM에서 APEX/ORDS를 바로 노출하는 것은 별도의 보안 검토가 필요하다. 그런 환경에서는 다음처럼 SSH tunnel을 사용한다.

```bash
ssh -i ./.ssh/id_ed25519 -p 7822 -L 36080:127.0.0.1:36080 root@219.240.178.144
```

위 tunnel을 열어 둔 상태에서 browser는 다음 주소로 접속한다.

```text
http://localhost:36080/ords/apex
http://localhost:36080/ords/apex_admin
```

여기까지 완료되면 APEX/ORDS runtime 준비가 끝난다. 다음 절에서는 `GGADMIN` schema와 workspace를 준비하고, GoldenGate 통합 Console App 101을 import한다.

APEX Console이 GoldenGate REST API 같은 내부 endpoint를 호출하려면 DB network ACL이 필요할 수 있다. 개인 PC의 격리된 Lab 환경에서는 다음처럼 넓게 허용할 수 있지만, 운영 환경에서는 `PUBLIC`과 `*`를 사용하지 말고 `GGADMIN`과 필요한 host만 대상으로 제한한다.

```sql
begin
  dbms_network_acl_admin.create_acl(
    acl         => 'all-accept.xml',
    description => 'Accept all networks for lab environment',
    principal   => 'PUBLIC',
    is_grant    => true,
    privilege   => 'connect'
  );

  dbms_network_acl_admin.add_privilege(
    acl       => 'all-accept.xml',
    principal => 'PUBLIC',
    is_grant  => true,
    privilege => 'resolve'
  );

  dbms_network_acl_admin.assign_acl(
    acl  => 'all-accept.xml',
    host => '*'
  );
end;
/
```

이미 같은 ACL이 있으면 `ORA-46212`가 발생할 수 있다. 이때는 실패가 아니라 같은 이름의 ACL이 이미 존재한다는 의미일 수 있으므로 다음 SQL로 확인한다.

```sql
set linesize 200
set pagesize 100

col acl for a30
col host for a20
col principal for a20
col privilege for a12
col is_grant for a8
col lower_port for 999999
col upper_port for 999999

select replace(acl, '/sys/acls/', '') as acl,
       host,
       lower_port,
       upper_port
from dba_network_acls
where acl like '%all-accept.xml%';

select replace(acl, '/sys/acls/', '') as acl,
       principal,
       privilege,
       is_grant
from dba_network_acl_privileges
where acl like '%all-accept.xml%'
order by principal, privilege;
```

정상 확인 예시는 다음과 같다.

```text
ACL                            HOST                 LOWER_PORT UPPER_PORT
------------------------------ -------------------- ---------- ----------
all-accept.xml                 *

ACL                            PRINCIPAL            PRIVILEGE    IS_GRANT
------------------------------ -------------------- ------------ --------
all-accept.xml                 PUBLIC               connect      true
all-accept.xml                 PUBLIC               resolve      true
```
