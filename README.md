# GoldenGate Lab Kit

`Oracle GoldenGate 실전 데이터 플랫폼` 도서의 실습 환경을 구성하기 위한
비공식 독자용 Lab Kit입니다.

이 저장소는 저자가 개인적으로 관리하며 Oracle의 공식 저장소가 아닙니다.
Oracle 제품 설치 파일, 라이선스가 적용되는 바이너리, 계정 정보, API 키,
wallet 및 실습 데이터는 포함하지 않습니다. Oracle 제품은 반드시 공식
경로에서 직접 내려받아야 합니다.

## Windows WSL 준비

현재 검증된 Oracle Linux WSL 배포판과 설치 방법은
[WSL 호환성 안내](WSL.md)에서 확인합니다. 독자가 실행하는 설치 파일은
짧은 이름의 `setup.ps1`이며, 실제 설치 명령을 보여 준 다음 확인을 받아
실행합니다.

Lab 실행 중 Windows drive 공간이 부족하거나 WSL의 `ext4.vhdx`를 정리해야
하는 경우에는 [WSL 저장 공간 점검과 VHDX 회수](WSL-STORAGE.md)를 확인합니다.

## 다운로드

Oracle Linux 8.10 on WSL2에서 다음 명령을 실행합니다.

```bash
cd /home/oracle

curl -fLO https://github.com/drastone/goldengate-labkit/releases/latest/download/goldengate-labkit.tar.gz
curl -fLO https://github.com/drastone/goldengate-labkit/releases/latest/download/goldengate-labkit.tar.gz.sha256

sha256sum -c goldengate-labkit.tar.gz.sha256
tar -xzf goldengate-labkit.tar.gz --strip-components=1
```

v0.100은 `lab18_init.sh`가 연속 실행하는 App 340 관련 SQL 세 개를 모두
점검해 Page 70 vector 구성 SQL과 FP care 구성 SQL에도 명시적 `exit`를
추가한다. 각 단계의 완료 메시지 이후 SQL*Plus가 입력을 기다리지 않고
다음 검증 단계로 진행한다.

v0.99는 App 340 설치 SQL이 완료된 뒤 SQL*Plus를 명시적으로 종료하도록
`exit`를 추가한다. 이로써 `lab18_init.sh`가 App 340 설치 완료 메시지에서
입력을 기다리며 멈추지 않고 후속 검증 단계로 진행한다.

v0.98은 실제 독자용 `labXX_init.sh` 실행 결과를 장별 중앙 로그 디렉터리
`/home/oracle/logs/labXX`에 저장한다. 정상 완료, 명령 실패, SSH 연결 종료를
포함한 signal, 수행 시간과 로그 경로를 기록하며 `latest.log`가 가장 최근
실행 로그를 가리킨다. 책에서 수동 절차로 진행하는 5장과 11장의 불필요한
init script도 배포본에서 제거해 id7 및 원고 흐름과 일치시켰다.

v0.97은 APEX demo 계정 갱신 결과의 SQL*Plus 열 폭과 제목을 정리해 사용자명,
잠금 상태, 만료일, 실패 횟수를 한 화면에서 읽기 쉽게 표시한다.

v0.96은 `startDocker.sh`가 Compose bind mount로 제공되는 GoldenGate API
helper를 다시 `docker cp`하지 않도록 개선한다. mount된 파일의 존재를 확인한
뒤 API와 Data Fabric helper를 재시작하고 health endpoint까지 검증하므로
`device or resource busy` 오류 없이 기존 컨테이너와 신규 환경을 모두 지원한다.

5장의 Source/Target 데이터베이스 준비는 책의 SQL*Plus 절차와
`labs/lab05/lab05_commands.txt`를 따라 수행한다. 저자의 반복 검증을 위한
자동 구성은 별도 writer tools에만 두며 reader-facing `lab05_init.sh`는
제공하지 않는다.

v0.89는 12장의 `lab12_init.sh`가 Source와 Target 양쪽에
APEX/ORDS를 구성하도록 확장한다. Source에는 업무 application 100, 102, 110,
120, 130, 140을 자동으로 import하며, 반복 실행에서는 이미 설치된 항목을
안전하게 건너뛴다. 12장 이전의 `startDocker.sh` 실행에서는 아직 설치되지
않은 APEX/ORDS를 오류로 취급하지 않고 안내 후 건너뛰며, 12장 이후에는
35080과 36080 endpoint를 모두 기동·검증한다. v0.89는 모든 장의
`labXX_init.sh`가 독자 명령 `sh labXX_init.sh`에서 Bash 실행으로 안전하게
전환되는지 릴리스 검사에서 자동 확인한다.

18장의 `lab18_init.sh`는 Target의 APEX/ORDS와 `OGG` workspace, GoldenGate로
복제된 `SOE` 원천 table을 확인한 뒤 업무 application 300부터 400까지
11개를 자동으로 import한다. 이후 vector, 이탈 예측, care queue 같은
Lab 18 분석 객체를 Source가 아닌 Target 업무 schema `SOE`에 생성하고,
App 340이 이 객체를 사용하도록 구성한다. 원천 복제가 준비되지 않았으면
변경 전에 중지하고 `reset_lab_all.sh --create-objects` 복구 명령을 안내한다.

App 101은 GoldenGate 통합 Console의 수동 import 절차를 위해 제외하며,
Data Mesh Control Tower App 410은 19장 이후 흐름에서 별도로 준비한다.
업무 application이 구독하는 Theme의 원본 App 102가 Target에 없으면 먼저
자동으로 import한다. App 102, 이미 설치된 application, 이미 생성된
분석 객체는 안전하게 재사용하므로 같은 script를 다시 실행해도 된다.

v0.84에서 반영한 OSA/GGSA Geo Spatial 서울권 초기 화면, 자동 확대 방지,
Pie visualization의 선택형 `Use 3D rendering`, OSA script 경로 정리는 그대로
유지한다.

`startOSA.sh`는 현재 OSA UI에서 누락된 Pie visualization의
`Use 3D rendering` 선택 항목도 복원한다. 모든 Pie graph를 강제로 변경하지
않으며, 생성 또는 편집 화면에서 선택한 graph에만 3D 효과가 적용된다.
기존 설치를 갱신한 뒤에는 `stopOSA.sh`, `startOSA.sh` 순서로 OSA를 다시
시작하고 브라우저에서 `Ctrl+F5`로 UI bundle을 새로 불러온다.

압축을 해제한 후 도서의 안내에 따라 라이선스가 적용되는 제품 파일을
`oracle/pkg`와 `centos/pkg`에 배치합니다. ZooKeeper, Kafka, Spark는
Big Data/Analytics 이미지를 만들 때 Apache Archive에서 자동으로 내려받고
고정된 SHA-512 체크섬으로 검증합니다.

Oracle 제품 파일명, 배치 위치, checksum은
[제품 설치 파일 다운로드 목록](docs/downloads/README.md)에서 확인합니다.

긴 Docker build 명령의 입력 오류를 줄이기 위해 v0.31부터 기본 image build
script를 제공합니다. v0.32부터는 파일 위치와 checksum, Docker Engine,
여유 공간을 build 전에 확인하는 `--check-only`와 자동 로그 저장 기능도
제공합니다.

```bash
cd /home/oracle
cat build_base_images.sh
sh build_base_images.sh --check-only
sh build_base_images.sh
```

점검과 build 출력은 `/home/oracle/logs` 아래의 timestamp가 포함된 log 파일에
화면 출력과 동시에 저장됩니다. 로그 끝에는 종료 시각, 총 소요 시간과
성공 또는 실패 결과가 함께 기록됩니다.

세 Oracle 기본 image가 준비된 다음 전체 사전 점검을 실행합니다.

```bash
sh check_labkit.sh
```

사전 점검에서 오류가 남아 있는 동안에는 `create_docker.sh`를 실행하지
마십시오.

## 배포 원칙

- Release의 `latest` URL은 최신 검증본을 가리킵니다.
- 버전은 Release 태그와 압축 내부의 `VERSION` 파일에서 확인할 수 있습니다.
- 설치 파일과 변동 가능성이 큰 절차는 도서 및 온라인 부록에서 안내합니다.
- 실습 서비스는 독자 PC의 로컬 환경에서만 사용하고 인터넷에 공개하지 않습니다.
