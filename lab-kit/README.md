# GoldenGate Lab Kit 배포 골격

이 디렉터리는 책 독자에게 제공할 Docker 기반 Lab Kit의 기준 파일을 정리한다. Oracle Database, Oracle GoldenGate, OSA/GGSA, JDK 같은 제품 설치 파일은 라이선스와 계정 권한이 필요한 파일이므로 이 저장소와 배포 tar에 포함하지 않는다. 독자는 각 제품의 공식 다운로드 경로에서 파일을 직접 받은 뒤 지정된 `pkg` 디렉터리에 둔다.

이 저장소의 `docs/online-appendix/lab-kit`는 버전 기준을 추적하기 위한 골격이다. 실제 독자 배포 tar는 검증 서버의 전체 실습 디렉터리에서 제품 media와 runtime data를 제외해 만든다. `oracle/msa`, `oracle/script`, `centos/conf`, `iceberg` 같은 보조 파일과 디렉터리는 최종 tar 생성 전에 `/u01` 기준으로 한 번 더 정리한다.

## 기본 배치

독자는 Lab Kit tar 파일을 WSL 내부 Linux file system의 `/home/oracle` 아래에 푼다.

```text
/home/oracle/
  docker-compose.yml
  check_labkit.sh
  create_docker.sh
  preflight_downloads.sh
  startDocker.sh
  oracle/
    Dockerfile23ai
    DockerfileOGG23ai
    DockerfileOGGBD23ai
    init.sh
    pkg/
  centos/
    Dockerfile
    init.sh
    pkg/
  iceberg/
  troubleshooting/
    scripts/
```

노트북 WSL에서는 `/home/oracle`을 기본 실습 디렉터리로 사용한다. OCI나 별도 서버에서 block volume을 `/u01`에 mount한 경우에도 같은 구조를 `/u01`에 풀 수 있다. `docker-compose.yml`의 host bind 경로는 상대 경로를 사용하므로, 어느 디렉터리에 풀었는지에 따라 자동으로 그 디렉터리 아래의 파일과 데이터를 사용한다.

App 340 설치와 Page 70 vector 및 FP care 구성 SQL은 완료 후 SQL*Plus를
명시적으로 종료하므로 Lab 18 초기화가
설치 완료 메시지에서 입력을 기다리지 않고 후속 검증 단계로 진행한다.

실제 독자용 초기화 script의 화면 출력은 장별 중앙 디렉터리
`/home/oracle/logs/labXX`에 동시에 저장한다. 정상 완료, 실패, SSH 연결 종료를
포함한 signal, 수행 시간과 로그 경로를 남기며 `latest.log`가 가장 최근
실행 로그를 가리킨다. 책에서 수동 절차로 진행하는 5장과 11장에는 별도
`labXX_init.sh`를 제공하지 않는다.

13장에서는 `/home/oracle/labs/lab13/lab13_init.sh`가 Target APEX의 `OGG`
workspace에 App 101을 application ID `101`, alias `GOLDENGATE-CONSOLE`,
parsing schema `GGADMIN`으로 설치한다. Supporting Objects와 Data Fabric
Designer Page 200, 실제 ORDS 실행 URL까지 검증하며, 완료 상태에서 다시
실행하면 application을 덮어쓰지 않고 안전하게 건너뛴다.

18장에서는 `/home/oracle/labs/lab18/lab18_init.sh`를 실행해 Target APEX의
`OGG` workspace에 업무 App 300부터 400까지 11개를 자동으로 import한다.
이 script는 GoldenGate D01이 Source SOE 원천 table과 상담 event를 Target
SOE로 전달했는지 먼저 확인하고, 정보계 vector/FP 케어 객체를 Target SOE에만
생성한다. `GGADMIN`은 APEX parsing schema로 필요한 권한만 받는다. App 101은
13장에서 이미 준비하며, Data Mesh Control Tower App 410은 19장 이후
절차에서 별도로 준비한다. 같은 script를 다시 실행해도 안전하다.

## 독자가 직접 넣어야 하는 제품 파일

| 위치 | 파일 | 용도 |
|---|---|---|
| `/home/oracle/oracle/pkg/V1054592-01.zip` | Oracle AI Database 26ai EE DB Home | `oracle/database:23.26.0-ee` image build |
| `/home/oracle/oracle/pkg/V1054774-01.zip` | Oracle GoldenGate 23.26.1.0.0 for Oracle | `oracle/goldengate:23.26.1-oracle` image build |
| `/home/oracle/oracle/pkg/V1054834-01.zip` | GoldenGate for Distributed Applications and Analytics 23.26.1 계열 | `oracle/oggforbigdata:23.26.1-daa` image build |
| `/home/oracle/oracle/pkg/jdk-17.0.6_linux-x64_bin.rpm` | Oracle JDK 17 RPM | 23ai/26ai DB container 내부 ORDS/APEX 보조 도구 |
| `/home/oracle/oracle/pkg/jdk-8u211-linux-x64.rpm` | Oracle JDK 8 RPM | 기존 OGG/보조 script 호환 |
| `/home/oracle/centos/pkg/p34575004_191008_Linux-x86-64.zip` | Oracle Stream Analytics/GGSA 19.1.0.0.8 patch | Big Data/Analytics container 구성 |
| `/home/oracle/centos/pkg/jdk-8u401-linux-x64.rpm` | Oracle JDK 8 RPM | Big Data/Analytics container Java runtime |
| `/home/oracle/centos/pkg/p6880880_190000_Linux-x86-64.zip` | OPatch media | OGG patch 적용 보조 |
| `/home/oracle/centos/pkg/p36878982_23512407OGGRU_Linux-x86-64.zip` | OGG RU patch media | Big Data/Analytics container 구성 |
| `/home/oracle/centos/pkg/p36878991_23512407OGGRU_Linux-x86-64.zip` | OGG RU patch media | Big Data/Analytics container 구성 |

제품 파일명, patch 번호, 크기, checksum은 최종 출간 전 `oracle-product-downloads/README.md`에서 다시 확인한다.

ZooKeeper, Kafka, Spark는 독자가 `centos/pkg`에 직접 넣지 않는다. 버전과 SHA-512 체크섬을 `centos/Dockerfile`에 고정하고, Big Data/Analytics image build 중 Apache Archive에서 내려받아 검증한 뒤 설치한다. 공개 배포 위치가 바뀌거나 지원 버전을 조정해야 할 때는 최신 Lab Kit의 Dockerfile을 갱신해 제공한다.

## 현재 기준 이미지 태그

`docker-compose.yml`과 Dockerfile은 다음 이미지를 기준으로 맞춘다.

```text
oracle/database:23.26.0-ee
oracle/goldengate:23.26.1-oracle
oracle/oggforbigdata:23.26.1-daa
```

예전 19c 컨테이너인 `demo_osrc`, `demo_otrg`는 현재 Lab Kit 기본 구성에서 제외한다. Source/Target DB는 `demo_osrc_23ai`, `demo_otrg_23ai`를 사용한다.

## 포트 공개 기준

노트북 WSL 실습의 기본 port mapping은 `127.0.0.1`에만 bind한다. 예를 들어 Source DB listener는 `127.0.0.1:8521:1521`, GoldenGate hub는 `127.0.0.1:6780:80`처럼 열린다. 이렇게 하면 같은 노트북의 Windows browser나 SQL client에서는 접속할 수 있지만, 주변 네트워크의 다른 PC에는 직접 공개되지 않는다.

다른 PC에서 화면 캡처나 브라우저 접속이 필요할 때는 compose file을 넓게 열기보다 필요한 port만 SSH tunnel로 연결한다. 실습 편의를 위해 임시로 `0.0.0.0`에 공개해야 한다면 Windows 방화벽, 회사 보안 정책, 공유기/공인 IP 노출 여부를 먼저 확인하고, 실습이 끝난 뒤 다시 local-only로 되돌린다.

## 외부 오픈소스 이미지 기준

MinIO는 Docker Hub의 `minio/minio`가 아니라 공식 문서에서 함께 안내하는 Quay registry의 `quay.io/minio/minio`를 기준으로 사용한다. 2026-09-15 id7 검증 중 Docker Hub `minio/minio`는 `pull access denied` 응답이 발생했고, Quay의 `quay.io/minio/minio:RELEASE.2024-01-16T16-07-38Z` manifest 조회는 성공했다. 출판 전에는 기본 Lab Kit에서 사용하는 MinIO, Iceberg REST Catalog, Trino image tag를 다시 확인한다. Elasticsearch, Kibana, Logstash, Flink, ksqlDB, InfluxDB, Grafana는 노트북 기본 환경에서 제외하고, 필요한 장에서 선택형 확장으로 다룬다.

## 출간 이후 Lab Kit 갱신 기준

Docker 기반 실습은 외부 container registry와 공개 image tag에 영향을 받는다. 출간 시점에 검증한 `docker-compose.yml`이더라도, 독자가 실습하는 시점에는 registry 정책, image 위치, tag 제공 방식, 인증 요구 사항이 바뀔 수 있다. 대표적인 증상은 다음과 같다.

```text
pull access denied
repository does not exist
manifest unknown
authentication required
TLS handshake timeout
context canceled
```

이런 오류가 발생하면 독자는 먼저 GitHub 온라인 부록 또는 출판사 다운로드 페이지에서 최신 Lab Kit 파일을 확인한다. 특히 다음 파일은 계속 갱신 대상이다.

```text
docker-compose.yml
check_labkit.sh
create_docker.sh
preflight_downloads.sh
startDocker.sh
stopDocker.sh
status_labkit.sh
oracle/Dockerfile23ai
oracle/DockerfileOGG23ai
oracle/DockerfileOGGBD23ai
oracle/init.sh
centos/Dockerfile
centos/init.sh
centos/initSSH.sh
```

GitHub 사용이 익숙하지 않은 독자는 브라우저에서 책에 안내된 GitHub 저장소를 열고 `Code` 버튼을 누른 뒤 `Download ZIP`으로 전체 파일을 내려받아도 된다. ZIP 파일이 Windows의 `Downloads` 폴더에 저장되었다면 WSL에서 다음 순서로 압축을 풀고 Lab Kit 파일만 덮어쓴다. 제품 ZIP/RPM은 다시 받지 않아도 되며, `/home/oracle/oracle/pkg`와 `/home/oracle/centos/pkg`에 그대로 둔다.

```bash
win_user=YOUR_WINDOWS_USER
update_dir=/tmp/labkit_update_$(date +%Y%m%d_%H%M%S)
mkdir -p "$update_dir"
cd "$update_dir"
unzip "/mnt/c/Users/${win_user}/Downloads/goldengate-worklog-main.zip"

src="$update_dir/goldengate-worklog-main/docs/online-appendix/lab-kit"

cd /home/oracle
bdir=backup/config_$(date +%Y%m%d_%H%M%S)
mkdir -p "$bdir/oracle" "$bdir/centos"
cp -a docker-compose.yml check_labkit.sh create_docker.sh preflight_downloads.sh startDocker.sh stopDocker.sh status_labkit.sh "$bdir/"
cp -a oracle/Dockerfile23ai oracle/DockerfileOGG23ai oracle/DockerfileOGGBD23ai oracle/init.sh "$bdir/oracle/"
cp -a centos/Dockerfile centos/init.sh centos/initSSH.sh "$bdir/centos/"

cp -a "$src/docker-compose.yml" "$src/check_labkit.sh" "$src/create_docker.sh" "$src/preflight_downloads.sh" "$src/startDocker.sh" "$src/stopDocker.sh" "$src/status_labkit.sh" /home/oracle/
cp -a "$src/oracle/Dockerfile23ai" "$src/oracle/DockerfileOGG23ai" "$src/oracle/DockerfileOGGBD23ai" "$src/oracle/init.sh" /home/oracle/oracle/
cp -a "$src/centos/Dockerfile" "$src/centos/init.sh" "$src/centos/initSSH.sh" /home/oracle/centos/

chmod +x /home/oracle/check_labkit.sh /home/oracle/create_docker.sh /home/oracle/preflight_downloads.sh /home/oracle/startDocker.sh /home/oracle/stopDocker.sh /home/oracle/status_labkit.sh
chmod +x /home/oracle/oracle/init.sh /home/oracle/centos/init.sh /home/oracle/centos/initSSH.sh

sh check_labkit.sh
sh create_docker.sh
sh status_labkit.sh
```

위 명령에서 `YOUR_WINDOWS_USER`는 Windows 로그인 사용자 이름으로 바꾼다. GitHub에서 받은 ZIP 파일의 이름이 `goldengate-worklog-main.zip`이 아니라면 실제 다운로드된 파일명에 맞춘다. `oracle/pkg`와 `centos/pkg` 디렉터리는 제품 설치 파일을 두는 곳이므로, 온라인 부록 파일을 적용할 때 이 디렉터리 안의 ZIP/RPM을 삭제하거나 덮어쓰지 않는다.

`check_labkit.sh`는 먼저 `docker compose config --services`로 Compose 문법을 확인하고, `docker compose pull --ignore-buildable --policy missing`으로 외부 image pull 문제를 먼저 드러낸다. `docker compose pull`은 없는 외부 image를 실제로 내려받으므로 첫 실행에는 시간이 걸릴 수 있지만, `--policy missing` 옵션 때문에 다음 실행부터는 이미 local에 있는 image를 다시 받지 않아 훨씬 빨라진다. 이어서 `preflight_downloads.sh`가 필수 로컬 제품 media 파일과 사전에 build해 두어야 하는 `oracle/database:23.26.0-ee`, `oracle/goldengate:23.26.1-oracle`, `oracle/oggforbigdata:23.26.1-daa` image 존재 여부를 확인한다. ZooKeeper, Kafka, Spark의 다운로드와 SHA-512 검증은 Big Data/Analytics image build 단계에서 수행한다. 어떤 단계에서든 실패하면 `ERROR:`로 시작하는 메시지가 표시되고 script가 중단된다. 이 단계에서 실패하면 Oracle Database나 GoldenGate container build까지 진행하지 말고, GitHub 온라인 부록의 image mapping, download URL, package file name, 최신 compose/script 파일을 먼저 확인한다. `create_docker.sh`도 내부에서 `check_labkit.sh`를 먼저 호출하므로, 독자가 사전 점검을 실수로 건너뛰어도 같은 검사를 다시 수행한다.

`create_docker.sh`는 시작 시각, 종료 시각, 전체 수행시간을 출력하고, 같은 내용을 `/home/oracle/logs/create_docker_YYYYMMDD_HHMMSS.log`에도 저장한다. 로그 저장은 화면 출력에 `tee`를 덧붙이는 방식이라 Docker image build 수행시간에는 큰 영향을 주지 않는다. 대신 warning이 많이 출력되는 build에서도 실제 `ERROR`, `FATAL`, `failed to solve` 지점을 나중에 다시 찾기 쉽다. Oracle Database 26ai 계열 image를 build하는 동안 `LISTENER:No valid IP Address returned for the host buildkitsandbox` 오류가 발생할 수 있으므로, 이 Lab Kit는 기본값으로 `DOCKER_BUILDKIT=0`을 사용해 DB prebuild 단계를 classic builder에서 실행한다. 사용자가 직접 `DOCKER_BUILDKIT=1`을 지정했다면 해당 오류가 발생할 때 값을 해제하고 다시 실행한다.

Oracle Database 26ai image build 중 `DATABASE IS READY TO USE!`가 출력된 뒤 `cat: /opt/oracle/cfgtoollogs/netca/netca_configure_out.log: No such file or directory`가 보이는 경우가 있다. 이 파일은 상태 확인을 위한 보조 로그이므로, 최신 `Dockerfile23ai`에서는 고정 파일 하나에 의존하지 않고 `/opt/oracle/cfgtoollogs/netca` 아래의 NETCA 로그가 있으면 출력한다. 로그가 없으면 `INFO` 메시지만 남기고 `checkDBStatus.sh`로 실제 DB 상태를 확인한다.

Big Data/analytics 초기화 단계에서는 `demo_centos` container 내부의 `sshd`를 먼저 시작한 뒤, `initSSH.sh`가 `oracle` 사용자 기준 passwordless SSH를 확인한다. 예전 검증 환경에서는 `demo_centos` 안의 ZooKeeper/Kafka를 `systemctl`로 관리했지만, 일부 노트북 WSL2 환경에서는 container의 PID 1이 systemd여도 CentOS 7 systemd와 cgroup v2/D-Bus 조합 때문에 `/run/systemd/private`가 생성되지 않아 `Failed to get D-Bus connection`이 발생할 수 있다. 따라서 현재 기본 Lab Kit는 `systemctl`을 먼저 시도하되, 실패하면 ZooKeeper/Kafka를 직접 background process로 기동하고 listener를 확인한다. 독자는 `systemctl status kafka` 대신 `sh status_labkit.sh`를 기본 상태 확인 명령으로 사용한다.

Lab Kit 생성이 끝나면 긴 `docker ps -a` 출력 전체를 본문 기준으로 삼지 않고, 다음 명령으로 핵심 runtime 상태를 확인한다. 기본 Lab Kit는 Source/Target Oracle Database, GoldenGate Hub, OGG for DAA, Kafka/ZooKeeper가 들어 있는 `demo_centos`, 그리고 Iceberg 확인용 MinIO, Iceberg REST Catalog, Trino를 기준으로 점검한다.

```bash
cd /home/oracle
sh status_labkit.sh
```

실습을 잠시 멈출 때는 `stopDocker.sh`로 Lab Kit container를 정지한다. 이 명령은 container를 삭제하지 않으므로, 다음에 `startDocker.sh`로 다시 올릴 수 있다.

```bash
cd /home/oracle
sh stopDocker.sh
```

compose 또는 Dockerfile 변경사항을 반영하기 위해 container를 새로 만들고 싶다면 `--rm` 옵션을 명시한다. 이 옵션은 Lab Kit container만 삭제하며, `oracle/pkg`, `centos/pkg`의 제품 ZIP/RPM, 사전에 build한 base image, 그리고 bind mount된 data directory는 삭제하지 않는다.

```bash
cd /home/oracle
sh stopDocker.sh --rm
sh check_labkit.sh
sh create_docker.sh
sh status_labkit.sh
```

자세한 배경, 정상 출력 예시, 오류별 대응 순서는 [Registry Preflight와 Lab Kit 갱신 기준](./registry-preflight.md)에 정리한다.

## tar 생성 기준

`/u01`에서 검증한 완성본을 독자 배포용 tar로 묶을 때는 runtime data, Docker 내부 저장소, 제품 설치 파일, 임시 파일을 제외한다.

```bash
cd /u01
mkdir -p /u01/export
tar -czvf /u01/export/ogg_labkit_skeleton_$(date +%Y%m%d).tar.gz \
  --exclude='./docker' \
  --exclude='./docker-data' \
  --exclude='./docker-images' \
  --exclude='./export' \
  --exclude='./logs' \
  --exclude='./tmp' \
  --exclude='./oracle/pkg/*' \
  --exclude='./centos/pkg/*' \
  --exclude='./elastic/esdata/*' \
  --exclude='./grafana/data/*' \
  --exclude='./influxdb/data/*' \
  --exclude='./influxdb/config/*' \
  --exclude='./iceberg/minio/*' \
  --exclude='./iceberg/warehouse/*' \
  --exclude='./ogg_labkit_*.tar.gz' \
  --exclude='./ogg_*.tar' \
  --exclude='*.log' \
  --exclude='*.swp' \
  --exclude='*.swo' \
  --exclude='*.swn' \
  .
```

`backup/` 디렉터리는 크기와 내용이 확인된 경우에만 포함한다. APEX export, Data Pump export처럼 책 실습 재현에 필요한 백업은 남길 수 있지만, 계정 정보, 고객 데이터, 대용량 runtime dump가 섞여 있으면 별도 정리 후 포함한다.

## 실행 전 확인

tar를 푼 뒤 독자는 다음 항목을 확인한다.

```bash
cd /home/oracle
ls -ltr docker-compose.yml create_docker.sh startDocker.sh
ls -ltr check_labkit.sh preflight_downloads.sh
ls -ltr oracle/pkg
ls -ltr centos/pkg
docker image ls
sh check_labkit.sh
```

`docker compose config --services` 출력에 `demo_osrc`와 `demo_otrg`가 보이면 예전 19c 서비스가 남아 있는 것이므로, 현재 Lab Kit 기준 파일을 다시 적용한다.
