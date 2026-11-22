# GoldenGate Field Kit

APEX도, 웹서버도, Docker도 고객 환경에 요구하지 않는 파트너/현장 엔지니어용 GoldenGate CLI 도구입니다. 기본 실행 파일은 shell-only `ogg_fk.sh`이며, Python 버전 `ogg_field_kit.py`는 보조로 유지합니다.

## 원칙

- 고객 GoldenGate 서버에 agent, web server, service를 설치하지 않습니다.
- 현장 기본 흐름은 `bash`, `curl`, GoldenGate client-side `adminclient`/`logdump`, Oracle `sqlplus`만 사용합니다.
- GoldenGate 비밀번호는 config에 저장하지 않습니다.
- OCI GoldenGate 또는 OS 접근이 없는 on-prem MSA는 trail directory를 직접 보지 않고, Admin Service REST metadata와 sequence download를 사용합니다.
- Docker는 현장 기본값이 아닙니다. 필요한 랩 환경에서만 별도 target으로 수동 구성합니다.

## 빠른 시작

```bash
cd /u01/oracle/msa/util
./ogg_fk.sh --target onprem-rest menu
./ogg_fk.sh --target onprem-rest targets
```

기본 config 파일명은 `my-ogg.json`입니다. `--config`를 생략하면 현재 디렉터리의 `my-ogg.json`을 먼저 찾습니다.

현재 데모 설정의 `onprem-rest` 예시는 다음 성격입니다.

```json
{
  "admin_url": "http://127.0.0.1:9112/services/v2",
  "admin_client_url": "http://127.0.0.1:9112",
  "admin_user": "oggadmin",
  "mode": "rest",
  "cli_mode": "local",
  "client_ogg_home": "/u01/app/ogg/ogg2310",
  "download_client_ogg_home": "/u01/app/ogg/ogg2310",
  "oracle_schema": "SOE",
  "oracle_admin_connect": "/ as sysdba",
  "oracle_pdb": "FREEPDB1",
  "oracle_sqlplus": "/u01/app/oracle/product/19c/WEST/bin/sqlplus",
  "oracle_ext_dir_name": "OGG_FK_TRAIL_DIR"
}
```

현장에서는 host, port, `client_ogg_home`, `oracle_*` 값만 고객 환경에 맞게 바꿉니다.

## 메뉴

```text
1. List targets
2. REST snapshot
3. Admin Client interactive/login
4. List trail metadata/files
5. Download trail sequence + local Logdump interactive
6. Download trail sequence only
7. Local/downloaded file Logdump interactive
8. Advanced direct Logdump on OGG host filesystem
9. SQL external-table analysis of downloaded trail
0. Exit
```

일반 작업 순서는 보통 `4 -> 6 또는 5 -> 7 또는 9`입니다.

## REST trail 조회와 다운로드

REST-only target에서는 OS directory를 직접 보지 않습니다. Trail name과 sequence는 Admin Service REST에서 확인하고, 필요한 sequence만 client 쪽으로 내려받습니다.

```bash
./ogg_fk.sh --target onprem-rest trails-list
./ogg_fk.sh --target onprem-rest trail-download --trail-name c1 --seq 6211
./ogg_fk.sh --target onprem-rest download-logdump-shell --trail-name c1 --seq 6211
```

다운로드 위치는 기본적으로 다음 형태입니다.

```text
/u01/oracle/msa/util/trail-downloads/<target>/<trail>/<trail><9-digit-sequence>
```

예:

```text
/u01/oracle/msa/util/trail-downloads/onprem-rest/c1/c1000006211
```

메뉴 7번은 단일 파일을, 메뉴 9번은 단일 또는 여러 파일을 선택할 수 있습니다. 메뉴 9번에서는 `1`, `1,2,3`, `1-4`, `c1:6012-6015`처럼 번호 묶음이나 trail sequence range를 입력할 수 있습니다.

## Local Logdump 분석

다운로드 후 local `logdump`를 실행할 때 다음 설정을 자동으로 먼저 적용합니다.

```text
ghdr on
detail data on
usertoken detail on
ggstoken detail on
headertoken detail on
```

그 다음부터는 OGG 엔지니어가 익숙한 명령을 그대로 입력합니다.

```text
Logdump > n
Logdump > pos 2616
Logdump > pos reverse
Logdump > pos forward
Logdump > scanforendtrans
Logdump > exit
```

## 메뉴 9: SQL External Table 분석

메뉴 9번은 다운로드된 trail 파일을 선택한 뒤, 같은 폴더에 external table용 DAT 파일과 SQL/report 파일을 생성합니다. 대량 transaction이 여러 trail sequence에 걸친 경우를 위해 여러 파일을 순차 분석할 수 있습니다.

단일 파일 생성 예:

```text
trail-downloads/onprem-rest/c1/c1000006211
trail-downloads/onprem-rest/c1/lgd_c1000006211.dat
trail-downloads/onprem-rest/c1/ogg_fk_trail_analyze_c1000006211.sql
trail-downloads/onprem-rest/c1/ogg_fk_trail_analyze_c1000006211.lst
```

여러 파일 생성 예:

```text
trail-downloads/onprem-rest/c1/c1000006211
trail-downloads/onprem-rest/c1/c1000006213
trail-downloads/onprem-rest/c1/lgd_c1_6211_6213.dat
trail-downloads/onprem-rest/c1/ogg_fk_trail_analyze_c1_6211_6213.sql
trail-downloads/onprem-rest/c1/ogg_fk_trail_analyze_c1_6211_6213.lst
```

메뉴 입력 예:

```text
1              # 목록의 1번 trail만 분석
1,2,3          # 목록의 1,2,3번 trail 분석
1-4            # 목록의 1번부터 4번까지 분석
c1:6012-6015   # c1 trail sequence 6012,6013,6014,6015 분석
6012-6015      # 목록에 trail name이 하나뿐이면 c1:6012-6015처럼 자동 해석
```

동작 흐름:

1. `ogg_trail_parse.sh`가 각 trail을 sequence 순서로 파싱합니다.
2. 메뉴 9번 DAT는 분석 순서 보존을 위해 `file_no`, `file_name`을 앞에 붙이고, 뒤에 기존 13개 컬럼 `resv1..resv13`을 둡니다.
3. Oracle DIRECTORY object를 DAT 폴더로 생성합니다.
4. `SOE.OGG_FK_LGD_EXT` external table을 생성합니다.
5. `SOE.OGG_FK_LGD_TMP` staging table을 생성하고 `resv10`을 number RBA로 변환합니다.
6. 여러 trail에서 RBA가 다시 시작되는 문제를 피하기 위해 `global_rba = file_no * 1000000000000000 + resv10`을 생성합니다.
7. `SOE.OGG_FK_LGD_TMP_I01(global_rba,resv1)`와 `SOE.OGG_FK_LGD_TMP_I02(file_no,resv10,resv1)` index를 생성합니다.
8. rows-by-file, operation/table summary, commit size candidate, PK update candidate report를 spool합니다.

실행 예:

```bash
cd /u01/oracle/msa/util
./ogg_fk.sh --target onprem-rest menu
# Select 9
# Trail numbers/ranges/local paths [1]: c1:6012-6015
# Oracle analysis schema [SOE]:
# Parse record limit per file (empty = all):
```

Command 직접 실행도 가능합니다.

```bash
./ogg_fk.sh --target onprem-rest trail-sql-analyze \
  --trail-range c1:6012-6015 \
  --schema SOE

./ogg_fk.sh --target onprem-rest trail-sql-analyze \
  --trail /u01/oracle/msa/util/trail-downloads/onprem-rest/c1/c1000006211 \
  --trail /u01/oracle/msa/util/trail-downloads/onprem-rest/c1/c1000006213 \
  --schema SOE
```

## 메뉴 10: 적재된 LGD 테이블 Transaction 분석

메뉴 10번은 메뉴 9번이 이미 만든 `SOE.OGG_FK_LGD_TMP`를 다시 분석합니다. Trail 파일을 다시 다운로드하거나 파싱하지 않고, 원하는 threshold만 바꿔가며 대량 one-commit transaction을 반복 조회할 때 사용합니다.

예:

```text
Select [0]: 10
Oracle analysis schema [SOE]:
Large transaction DML record threshold [1000]: 1000000
```

Command 직접 실행:

```bash
./ogg_fk.sh --target onprem-rest loaded-tx-analyze \
  --schema SOE \
  --threshold 1000
```

분석 기준:

1. `resv1='(x00)'`를 transaction begin 후보로 봅니다.
2. `resv1='(x02)'`를 commit 후보로 봅니다.
3. `global_rba` 순서로 begin부터 commit까지의 범위를 잡습니다.
4. `resv11`이 있는 row를 DML record로 보고, threshold 이상인 transaction을 report합니다.
5. 여러 trail sequence를 메뉴 9번에서 함께 적재한 경우에도 `global_rba` 기준으로 이어서 분석합니다.

주의:

- `sqlplus`가 client에 있어야 합니다. `oracle_sqlplus`로 명시하거나 PATH에 둡니다.
- `/ as sysdba` 같은 OS 인증을 쓰면 root가 아니라 Oracle software owner, 예: `oracle`, 로 실행합니다.
- `oracle_sqlplus`가 `/.../bin/sqlplus`이면 도구가 `ORACLE_HOME`을 자동 추정하고, `/etc/oratab`에서 같은 home을 찾으면 `ORACLE_SID`도 자동 설정합니다.
- Oracle DB가 DAT 파일 경로를 읽을 수 있어야 합니다. DB 서버와 client가 다르면 `oracle_ext_dir`를 DB 서버가 볼 수 있는 경로로 지정하고, DAT를 그 위치에 생성하게 합니다.
- `oracle_admin_connect`는 기본 예시가 `/ as sysdba`입니다. 현장에서는 wallet, OS 인증, 또는 보안 정책에 맞는 접속 문자열로 조정합니다.
- `oracle_pdb`는 CDB/PDB 환경에서만 설정합니다. Non-CDB면 빈 값으로 둡니다.

## Target 모드 규칙

환경 이름이 아니라 접근 방식으로 mode를 정합니다.

- `mode: "rest"`: GoldenGate Admin Service REST API만 사용합니다. OCI GoldenGate와 on-prem MSA 모두 가능하며 OS/trail directory 접근은 전제하지 않습니다.
- `mode: "local"`: 현재 서버에서 `adminclient`/`logdump` 바이너리를 직접 실행합니다.
- `mode: "ssh"`: 엔지니어 PC나 bastion에서 고객 GoldenGate 서버로 SSH 접속해 기존 바이너리만 실행합니다.

On-prem도 REST API만 쓸 거면 OCI와 같은 형태로 `mode: "rest"`를 씁니다. Trail 내용 분석은 REST로 sequence를 client에 다운로드한 뒤 local `logdump` 또는 메뉴 9번 SQL 분석으로 진행합니다.

## Parser 단독 사용

기존 `print-trail-info.sh` + `print-trail-summary.sh` 조합은 `ogg_trail_parse.sh` 하나로 합쳤습니다. 이제 별도 wrapper를 거치지 않고 이 script가 `logdump` 호출과 13컬럼 parsing을 모두 처리합니다.

```bash
LOGDUMP=/u01/app/ogg/ogg2310/bin/logdump ./ogg_trail_parse.sh -n 20 trail-downloads/onprem-rest/c1/c1000006211 > lgd_c1000006211.dat
```

단독 parser 출력은 기존 호환을 위해 13컬럼 pipe-delimited 형식입니다. 메뉴 9번 SQL 분석용 DAT는 여기에 `file_no`, `file_name` 두 컬럼을 앞에 추가한 15컬럼 형식으로 생성합니다.
