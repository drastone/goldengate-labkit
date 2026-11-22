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

고객 사이트에서 Python 설치가 어렵다면 `ogg_fk.sh`를 사용합니다. 이 버전은 Python/jq/web server 없이 `bash`와 표준 유틸리티만으로 `adminclient`, REST metadata 조회, trail sequence 다운로드, local `logdump` 분석을 수행합니다. REST 기능은 `curl`이 있을 때 동작합니다. 일반 on-prem target은 Docker를 사용하지 않고 host-local `adminclient`/`logdump`를 실행하며, Docker가 필요한 데모 컨테이너는 `lab-docker` target으로 분리합니다.

```bash
cd /u01/oracle/msa/util
./ogg_fk.sh --target onprem-rest menu
./ogg_fk.sh --target onprem-rest targets
./ogg_fk.sh --target onprem-rest admin-shell --connect
./ogg_fk.sh --target onprem-rest trails-list

# OS 접근이 없는 OGG/OCI GG에서는 REST로 trail sequence를 client에 다운로드한 뒤 local logdump로 분석
./ogg_fk.sh --target onprem-rest trail-download --trail-name c1 --seq 6186
./ogg_fk.sh --target onprem-rest download-logdump-shell --trail-name c1 --seq 6186
./ogg_fk.sh --target onprem-rest download-logdump-run --trail-name c1 --seq 6186 --cmd env

# Demo container target을 쓰더라도 분석 파일은 client local에 다운로드해서 local logdump로 분석
./ogg_fk.sh --target lab-docker download-logdump-shell --trail-name c1 --seq 6186
```

메뉴 `7. Local/downloaded file Logdump interactive`는 이미 내려받은 파일을 다시 분석할 때 씁니다. `./trail-downloads/<target>/<trail>/` 아래 파일을 자동으로 찾아 `trail`, `sequence`, 크기, 저장 경로를 보여주고 번호로 선택하게 합니다. 파일을 직접 입력할 수도 있지만, 보통은 목록에서 번호를 고르면 됩니다.

`download-logdump-shell`과 `download-logdump-run`은 REST로 trail sequence 하나를 client filesystem에 내려받은 뒤 local `logdump`로 엽니다. 시작 시 `ghdr on`, `detail data on`, `usertoken detail on`, `ggstoken detail on`, `headertoken detail on`을 자동 적용합니다. Admin Client는 target의 `admin_client_url`을 기준으로 접속합니다. `admin-shell --connect` 또는 메뉴 3번은 Python이 있으면 PTY로 `connect <url> as <user> !` 명령만 먼저 넣고, 비밀번호는 실제 Admin Client prompt에서 숨김 입력합니다. Python이 없는 현장에서는 같은 connect command를 화면에 보여주므로 그대로 입력하면 됩니다. 만약 `sudo docker` 권한 오류가 난다면 고객 on-prem target이 아니라 Docker demo target을 선택한 것이므로 `onprem-rest`는 `cli_mode: local` 또는 `ssh`로 두고, 컨테이너 데모는 Docker 권한이 있는 계정에서 `lab-docker`로 실행합니다.

## Target 모드 규칙

환경 이름이 아니라 **접근 방식**으로 mode를 정합니다.

- `mode: "rest"`: GoldenGate Admin Service REST API만 사용합니다. OCI GoldenGate와 on-prem MSA 모두 가능하며, OS/trail directory 접근은 전제하지 않습니다.
- `mode: "local"`: 현재 서버에서 `adminclient`/`logdump` 바이너리를 직접 실행합니다.
- `mode: "ssh"`: 엔지니어 PC나 bastion에서 고객 GoldenGate 서버로 SSH 접속해 기존 바이너리만 실행합니다.

`mode`는 GoldenGate metadata/trail 접근 방식을 뜻합니다. `adminclient`와 `logdump`는 별도 CLI 바이너리이므로, REST-only target에서도 `cli_mode`로 실행 위치를 따로 지정할 수 있습니다. 예를 들어 REST 조회는 host port로 하고, Admin Client 실행은 데모 컨테이너 안의 `/u01/ogg/bin/adminclient`를 쓰는 식입니다.

즉 on-prem GoldenGate도 REST API만 쓸 거면 OCI와 같은 형태로 `mode: "rest"`를 쓰면 됩니다. Trail 내용까지 logdump로 분석할 때도 기본은 REST로 sequence를 client에 다운로드한 뒤 local `logdump`로 여는 방식입니다. OS 접근이 가능한 self-managed 환경에서만 `local` 또는 `ssh` target으로 direct path 분석을 추가합니다.

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

데모 컨테이너처럼 REST endpoint는 host port로 접근하고 CLI 바이너리는 컨테이너 안에서 실행해야 하는 경우에는 별도 target, 예를 들어 `lab-docker`, 에만 `cli_mode: "docker"`를 둡니다. 고객 on-prem 환경의 `onprem-rest`는 Docker 항목을 빼고 `cli_mode: "local"` 또는 `cli_mode: "ssh"`로 둡니다.

```json
{
  "targets": {
    "lab-docker": {
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
python3 ogg_field_kit.py --target onprem-rest admin-shell --connect
```

`admin-shell --connect`는 target 설정의 `admin_client_url` 또는 `admin_url`에서 `/services/v2`를 제거한 URL로 접속 명령을 먼저 보냅니다. 현재 `onprem-rest` 샘플이면 다음과 같은 command가 사용됩니다.

```text
connect http://127.0.0.1:9112 as oggadmin !
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

상세 응답에서는 `name`, `processRef`, `sizeMB`, `spaceUsed`, `sequenceMin`, `sequenceMax`를 요약합니다. OS 접근이 없는 고객 환경과 OCI GoldenGate에서는 여기서 확인한 trail name/sequence를 기준으로 `trail-download` 또는 `download-logdump-shell`을 실행합니다. 이 방식은 remote OGG instance의 trail sequence를 REST로 client에 내려받은 뒤 local logdump로 분석합니다.

REST download 후 client-local logdump 분석:

REST metadata에서 본 trail name과 sequence만 알고 있으면 `--trail-name c1 --seq 6186`처럼 입력합니다. 도구는 Admin Service REST의 `/services/v2/trails/<trail>/sequences/<sequence>` API를 사용해 client 쪽 `./trail-downloads/<target>/<trail>/` 아래에 `c1000006186` 같은 파일명으로 저장한 뒤 local `logdump`로 엽니다. 이후에는 OGG 엔지니어가 익숙한 `n`, `pos <rba>`, `pos reverse`, `pos forward`, `scanforendtrans`, `exit` 같은 logdump 명령을 그대로 입력합니다.

```bash
python3 ogg_field_kit.py --target onprem-rest trail-download \
  --trail-name c1 \
  --seq 6186

python3 ogg_field_kit.py --target onprem-rest download-logdump-shell \
  --trail-name c1 \
  --seq 6186
```

Self-managed/OS 접근 가능 환경에서만 direct CLI runner logdump:

```bash
python3 ogg_field_kit.py --target source logdump-shell \
  --trail /u02/Deployment/var/lib/data/c1000006186
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


## REST-only target에서 trail file 기준

REST-only target에서는 OS directory를 직접 보지 않습니다. OCI GoldenGate managed deployment는 항상 이 제약을 갖고, on-prem MSA도 OS 접근 없이 REST만 쓰기로 하면 같은 기준을 적용합니다. 대신 다음 흐름을 사용합니다.

- 콘솔 또는 REST metadata로 Trail 이름, producer/consumer, sequence를 확인합니다.
- 지원되는 버전에서는 deployment console/REST에서 trail sequence를 다운로드합니다.
- 또는 manual backup을 생성하고 다운로드한 뒤 압축을 풀어 `Deployment/var/lib/data` 아래 trail 파일을 local `logdump`로 분석합니다.

즉 `mode: "rest"` target에서는 `trail_dirs`를 설정하지 않는 것이 맞습니다. `trail_dirs`는 `mode: "local"` 또는 `mode: "ssh"` target에서만 의미가 있습니다. 기본 흐름은 `trails-list`로 sequence를 확인하고 `trail-download` 또는 `download-logdump-shell`로 client에 내려받는 것입니다. OS 접근이 가능한 self-managed 환경에서만 advanced 옵션 `--resolve-files` 또는 direct `logdump-shell`을 사용해 trail name + sequence로 full path를 탐색합니다. 자동 탐색 범위를 제한해야 하는 고객 환경에서는 선택적으로 `cli_trail_search_roots` 또는 `cli_trail_dirs`를 설정할 수 있습니다.
