# GoldenGate Field Kit

APEX도, 웹서버도 설치하지 않는 파트너/현장 엔지니어용 GoldenGate CLI 도구입니다. Python 표준 라이브러리만 사용합니다.

## 원칙

- 고객 GoldenGate 서버에 agent, web server, service를 설치하지 않습니다.
- 엔지니어 PC, 작업용 bastion, 또는 이미 접속 승인된 GoldenGate host에서 `python3 ogg_field_kit.py`로 실행합니다.
- 비밀번호는 `getpass()`로 입력받아 화면에 표시하지 않습니다.
- Self-managed GoldenGate는 `adminclient`/`logdump` 바이너리를 local 또는 SSH로 실행합니다. 데모/랩에서는 Docker 컨테이너 안의 바이너리도 사용할 수 있습니다.
- OCI GoldenGate managed deployment는 OS 접근과 trail directory 접근을 전제하지 않고 REST metadata 중심으로 조회합니다.

## 빠른 시작

```bash
cd /u01/oracle/msa/util
python3 ogg_field_kit.py init-config
python3 ogg_field_kit.py targets
```

기본 config 파일명은 `my-ogg.json`입니다. `--config`를 생략하면 현재 디렉터리의 `my-ogg.json`을 먼저 찾습니다. 비밀번호는 config에 저장하지 않는 것을 권장합니다.

### Python 없는 고객 사이트용 shell-only 실행

고객 사이트에서 Python 설치가 어렵다면 `ogg_fk.sh`를 사용합니다. 이 버전은 Python/jq/web server 없이 `bash`와 표준 유틸리티만으로 `adminclient`, `logdump`, trail full path 자동 탐색을 수행합니다. REST metadata 조회는 `curl`이 있을 때 동작합니다.

```bash
cd /u01/oracle/msa/util
./ogg_fk.sh --target onprem-rest menu
./ogg_fk.sh --target onprem-rest targets
./ogg_fk.sh --target onprem-rest logdump-shell --trail-name c1 --seq 6186
./ogg_fk.sh --target onprem-rest logdump-run --trail-name c1 --seq 6186 --cmd env
```

`logdump-shell`과 `logdump-run`은 Python 버전과 동일하게 시작 시 `ghdr on`, `detail data on`, `usertoken detail on`, `ggstoken detail on`, `headertoken detail on`을 자동 적용합니다. Shell 버전은 Admin Client 비밀번호 자동 입력을 지원하지 않으므로, 비밀번호가 필요한 작업은 `admin-shell`에서 실제 Admin Client prompt로 접속하는 방식을 권장합니다.

## Target 모드 규칙

환경 이름이 아니라 **접근 방식**으로 mode를 정합니다.

- `mode: "rest"`: GoldenGate Admin Service REST API만 사용합니다. OCI GoldenGate와 on-prem MSA 모두 가능하며, OS/trail directory 접근은 전제하지 않습니다.
- `mode: "local"`: 현재 서버에서 `adminclient`/`logdump` 바이너리를 직접 실행합니다.
- `mode: "ssh"`: 엔지니어 PC나 bastion에서 고객 GoldenGate 서버로 SSH 접속해 기존 바이너리만 실행합니다.

`mode`는 GoldenGate metadata/trail 접근 방식을 뜻합니다. `adminclient`와 `logdump`는 별도 CLI 바이너리이므로, REST-only target에서도 `cli_mode`로 실행 위치를 따로 지정할 수 있습니다. 예를 들어 REST 조회는 host port로 하고, Admin Client 실행은 데모 컨테이너 안의 `/u01/ogg/bin/adminclient`를 쓰는 식입니다.

즉 on-prem GoldenGate도 REST API만 쓸 거면 OCI와 같은 형태로 `mode: "rest"`를 쓰면 됩니다. Trail 내용까지 logdump로 분석해야 하고 OS 접근이 가능하면 `local` 또는 `ssh` target을 추가합니다.

### 1. Self-managed local

GoldenGate 서버에 이미 접속해 있고, 그 서버에서 Python을 실행하는 경우입니다.

```json
{
  "targets": {
    "source": {
      "description": "Self-managed GoldenGate on current host",
      "admin_url": "http://localhost:9011",
      "admin_user": "oggadmin",
      "mode": "local",
      "ogg_home": "/u01/oracle/msa/util",
      "trail_dirs": [
        "/u01/oracle/msa/util/var/lib/data",
        "/u01/oracle/msa/util/dirdat"
      ]
    }
  }
}
```

여기서 `trail_dirs`는 `logdump open <file>`이 접근 가능한 실제 trail 파일 위치입니다.

### 2. Self-managed SSH

엔지니어 PC나 bastion에서 고객 GoldenGate 서버에 SSH로 접속해 기존 바이너리만 실행하는 경우입니다. 고객 서버에 추가 설치는 없습니다.

```json
{
  "targets": {
    "remote-source": {
      "description": "Self-managed GoldenGate over SSH",
      "admin_url": "http://localhost:9011",
      "admin_user": "oggadmin",
      "mode": "ssh",
      "ssh": "ogg@customer-ogg-host",
      "ogg_home": "/u01/oracle/msa/util",
      "trail_dirs": [
        "/u01/oracle/msa/util/var/lib/data",
        "/u01/oracle/msa/util/dirdat"
      ]
    }
  }
}
```

### 3. REST-only target: OCI GoldenGate 또는 on-prem MSA

REST-only target은 backend OS에 접근하지 않는 방식입니다. OCI GoldenGate managed service는 이 방식이 기본이고, on-prem MSA도 운영자가 OS 접근을 허용하지 않거나 REST 조회만 필요한 경우 같은 형태로 구성할 수 있습니다.

On-prem REST-only 예시:

```json
{
  "targets": {
    "onprem-rest": {
      "description": "On-prem GoldenGate MSA REST-only",
      "admin_url": "https://onprem-ogg-host:9011",
      "admin_user": "oggadmin",
      "mode": "rest"
    }
  }
}
```

OCI GoldenGate managed 예시:

```json
{
  "targets": {
    "oci-managed": {
      "description": "OCI GoldenGate managed deployment",
      "admin_url": "https://deployment-console-host:9011",
      "admin_user": "oggadmin",
      "mode": "rest"
    }
  }
}
```

데모 컨테이너처럼 REST endpoint는 host port로 접근하고 CLI 바이너리는 컨테이너 안에서 실행해야 하는 경우에는 `cli_mode`를 추가합니다. 고객 환경에서는 이 Docker 항목을 빼고 `cli_mode: "local"` 또는 `cli_mode: "ssh"`로 바꾸면 됩니다.

```json
{
  "targets": {
    "onprem-rest": {
      "description": "demo_ogg_23ai GoldenGate Admin Service",
      "admin_url": "http://127.0.0.1:9112/services/v2",
      "admin_user": "oggadmin",
      "mode": "rest",
      "cli_mode": "docker",
      "cli_container": "demo_ogg_23ai",
      "cli_docker": "sudo docker",
      "client_ogg_home": "/u01/ogg",
      "admin_client_url": "http://localhost:9012"
    }
  }
}
```

## 사용 예시

메뉴:

```bash
python3 ogg_field_kit.py --target onprem-rest menu
```

Admin Client interactive:

```bash
python3 ogg_field_kit.py --target onprem-rest admin-shell
```

메뉴 또는 `admin-shell`이 뜨면 데모 컨테이너 안에서는 다음 URL로 접속합니다.

```text
connect http://localhost:9012 as oggadmin !
```

Self-managed trail 목록:

```bash
python3 ogg_field_kit.py --target source trails-list
```

REST-only trail metadata, OCI 또는 on-prem MSA:

```bash
python3 ogg_field_kit.py --target oci-managed trails-list --insecure
python3 ogg_field_kit.py --target onprem-rest trails-list --insecure
```

이 명령은 기존 APEX Trails Page 159와 같은 흐름을 사용합니다.

```text
GET /services/v2/trails
GET /services/v2/trails/<trail-name>
```

상세 응답에서는 `name`, `processRef`, `sizeMB`, `spaceUsed`, `sequenceMin`, `sequenceMax`를 요약합니다. CLI runner가 filesystem을 볼 수 있으면 같은 화면 아래에 실제 trail full path도 함께 표시합니다. 예를 들어 `/u02/Deployment/var/lib/data/c1000006186`처럼 보이면, logdump plain interactive에서 그대로 `open /u02/Deployment/var/lib/data/c1000006186`을 입력할 수 있습니다.

Self-managed logdump one-shot:

`--trail`은 `logdump open <file>`로 열 실제 trail 파일 경로입니다. REST metadata에서 본 trail name과 sequence만 알고 있으면 `--trail-name c1 --seq 6186`처럼 입력할 수 있고, 도구가 `c1000006186` 파일명을 만든 뒤 CLI runner 안에서 GoldenGate 표준 후보 경로와 환경변수 기반 경로를 자동 탐색합니다. 메뉴에서는 5번으로 trail metadata를 본 뒤 6번에서 표시된 번호를 선택하면 full path를 자동으로 찾고 해당 trail을 open한 뒤 실제 `Logdump >` 프롬프트로 넘깁니다. 이후에는 OGG 엔지니어가 익숙한 `n`, `pos <rba>`, `pos reverse`, `pos forward`, `scanforendtrans`, `exit` 같은 logdump 명령을 그대로 입력합니다.

APEX처럼 trail name + sequence로 자동 logdump open 후 interactive 진입:

```bash
python3 ogg_field_kit.py --target onprem-rest logdump-shell \
  --trail-name c1 \
  --seq 6186
```

logdump interactive와 one-shot은 시작할 때 다음 설정을 자동으로 먼저 적용합니다.

```text
ghdr on
detail data on
usertoken detail on
ggstoken detail on
headertoken detail on
```

자동 설정과 open 이후 실제 logdump 프롬프트에서 직접 실행:

```text
Logdump > n
Logdump > pos 2616
Logdump > pos reverse
Logdump > pos forward
Logdump > scanforendtrans
Logdump > exit
```

```bash
python3 ogg_field_kit.py --target source logdump-run \
  --trail /u02/Deployment/var/lib/data/aa000000001 \
  --cmd 'next 10'
```

OCI GoldenGate backup에서 추출한 trail 파일 분석:

```bash
python3 ogg_field_kit.py --target source logdump-run \
  --trail /path/to/unzipped/Deployment/var/lib/data/aa000000001 \
  --cmd 'next 10'
```

Admin Service REST snapshot:

```bash
python3 ogg_field_kit.py --target oci-managed snapshot --insecure --html ogg-snapshot.html
```

Admin Client one-shot, self-managed/local 또는 SSH 대상:

```bash
python3 ogg_field_kit.py --target source admin-run \
  --connect-url http://localhost:9011 \
  --connect-user oggadmin \
  --cmd 'info all'
```

## REST-only target에서 trail file 기준

REST-only target에서는 OS directory를 직접 보지 않습니다. OCI GoldenGate managed deployment는 항상 이 제약을 갖고, on-prem MSA도 OS 접근 없이 REST만 쓰기로 하면 같은 기준을 적용합니다. 대신 다음 흐름을 사용합니다.

- 콘솔 또는 REST metadata로 Trail 이름, producer/consumer, sequence를 확인합니다.
- 지원되는 버전에서는 deployment console/REST에서 trail sequence를 다운로드합니다.
- 또는 manual backup을 생성하고 다운로드한 뒤 압축을 풀어 `Deployment/var/lib/data` 아래 trail 파일을 local `logdump`로 분석합니다.

즉 `mode: "rest"` target에서는 `trail_dirs`를 설정하지 않는 것이 맞습니다. `trail_dirs`는 `mode: "local"` 또는 `mode: "ssh"` target에서만 의미가 있습니다. logdump CLI runner가 OS를 볼 수 있는 환경이면, 도구가 trail name + sequence로 full path를 자동 탐색합니다. 자동 탐색 범위를 제한해야 하는 고객 환경에서는 선택적으로 `cli_trail_search_roots` 또는 `cli_trail_dirs`를 설정할 수 있습니다.
