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

v0.139는 7장 Source 업무 테이블을 만드는 절차를 복구한다.
`sh create_source_business_objects.sh`로 필수 테이블을 준비하고,
`sh gen_init.sh`로 고객과 계약 데이터를 만든 다음 `sh gen_0.sh 2`를
실행한다. 필수 테이블이 빠져 있으면 생성기는 데이터를 변경하기 전에 중단한다.

v0.138은 온라인 부록에서만 사용하는 GoldenGate for MySQL container가
PC 재부팅 뒤 자동으로 시작되지 않도록 restart policy를 명시적으로
비활성화한다. 필요한 경우 해당 온라인 부록 절차에서만 기동한다. 또한
Lab Kit 초기화 시 Base Linux의 `root` 계정에 `set -o vi`를 중복 없이
설정해, 새 terminal에서도 동일한 명령행 편집 방식을 사용할 수 있다.

v0.137은 기존 MongoDB container를 재사용할 때 canonical 관리자 암호가
현재 Lab Kit과 다른 경우에도 replica-set keyfile의 내부 인증으로 계정을
안전하게 보정한다. container와 volume을 삭제하지 않으므로 이전 실습
데이터를 보존하면서 즉시 재실행할 수 있다. `lab13_init.sh migration`은
MySQL과 MongoDB를 더 실습하려는 독자를 위한 온라인 부록 전용 경로로
구분하고, 13장 본문 명령 목록에서는 제외한다.

v0.136은 Chapter 13의 GoldenGate 통합 Console에서 MySQL과 MongoDB
Migration 기능을 16 GB급 독자 환경에서도 실습할 수 있도록 `migration`
모드를 추가한다. `sh lab13_init.sh migration`은 Chapter 12의 APEX/ORDS
선행 구성을 재사용한 뒤 Oracle Source와 기본 GoldenGate Hub를 내리고,
Target APEX/ORDS와 MySQL, HeatWave, MongoDB Source/Target, 각 GoldenGate
runtime만 기동한다. id7에서는 일곱 container가 약 5.50~5.85 GiB를 사용했고,
MySQL 및 MongoDB의 실제 변경이 Target에 도착하는 것까지 확인했다.

GoldenGate for MySQL image가 없으면 독자가 별도로 받은 지정 버전 설치
파일의 SHA-256을 확인한 뒤 고정된 Oracle Linux base image로 빌드한다.
제품 설치 파일과 빌드된 image는 이 저장소와 Release에 포함하지 않는다.

v0.135는 Chapter 12 Trail purge task가 Microservices deployment의 표준
Trail data directory를 사용하도록 바로잡는다. Classic Architecture의 상대
경로인 `dirdat`를 강제로 지정하지 않으므로 OGGHUB의 `ca`와 OGGBD의 `da`
Trail을 실제로 찾을 수 있다. 설정 검증도 path override가 다시 들어오면
실패하도록 보강했다.

v0.134는 Chapter 20 Data Fabric 변경 요청이 실제 적용된 뒤에도 APEX가
기본 응답 `OK`를 JSON으로 해석하지 못해 실패로 표시하던 문제를 바로잡는다.
Supporting Objects의 AJAX callback이 명시적인 JSON 성공 응답을 반환하므로
`Set Table` 완료 건수와 결과가 화면에 정확히 표시된다.

또한 GoldenGate split 경로를 다시 구성할 때 Extract를 모두 생성한 뒤
Trail을 연결하고, 삭제된 process handle을 Administration Service 재기동으로
정리한다. `lab20_init.sh`는 Chapter 20에서 사용하지 않는 D01이 이미 삭제된
상태도 정상으로 처리하므로 부분 실행 후 재시도와 즉시 재실행이 모두
같은 최종 상태로 수렴한다.

v0.133은 Chapter 20 Data Fabric Designer 설치가 끝난 뒤 SQL*Plus를
명시적으로 종료한다. 설치 결과가 정상이어도 `SQL>` 프롬프트에서 입력을
기다리던 문제를 없애 `lab20_init.sh`가 다음 단계로 계속 진행한다.

v0.132는 App 101의 Supporting Objects에 Chapter 20 Data Fabric 테이블과
`GGADMIN.FABRIC_DESIGNER_PKG`를 포함한다. 따라서 13장에서 App 101을 수동으로
가져오며 Supporting Objects를 설치한 깨끗한 환경에서도 Canvas 페이지가
별도 사전 상태 없이 렌더링된다. 기존 App 101 설치는 `lab20_init.sh`가 같은
정식 설치 SQL로 보완하고, OGG 워크스페이스 내부 ID를 동적으로 확인하며
패키지 명세와 본문이 모두 `VALID`인지 검증한다.

v0.131은 독자용 Lab Kit 동작을 v0.130과 동일하게 유지한다. 별도
writer-tools의 누적 Lab 16 경로가 APEX/ORDS 설치 후 기존 저자용 App 101
helper를 호출하도록 보완하여, Lab 19까지 완료한 저자 baseline에 13장의
수동 import 완료 상태가 누락되지 않게 한다. 책과 독자용 Lab 13 절차는
변경하지 않는다.

v0.130은 13장의 App 101 실습을 APEX App Builder를 이용한 독자 수동 import
절차로 그대로 유지한다. 저자 누적 자동화는 별도 writer-tools에서 이 완료
상태를 만들며 독자용 `lab13_init.sh`에 import 로직을 넣지 않는다. Lab 20은
수동 import된 alias `GOLDENGATE-CONSOLE`, Data Fabric Designer Page 200과
실제 ORDS endpoint를 먼저 확인하고, 누락되면 Data Fabric 초기화 전에 13장
수동 절차를 완료하라고 안내한다.

v0.128은 `lab20_init.sh`가 Lab 20에서 사용하지 않는 기존 핵심 복제 경로
`C01`과 `D01`을 명시적으로 정상 종료하고 `STOPPED` 상태를 확인한다.
Data Fabric 실습 경로인 `FC01`, `FC02`, `FD01`, `FD02`, `FD03`은 모두
`RUNNING`인지 검증하므로, 독자는 Lab 20에 필요한 프로세스와 이전 장의
프로세스를 명확히 구분할 수 있다. 이 흐름은 독자 기준 환경인 id7에서
초기 실행과 즉시 재실행으로 검증했다.

v0.109는 저자용 Lab 06 자동화가 Target에 검증 테이블을 직접 만들거나
데이터를 넣지 않고, Source에서 발생한 `SOE.STAFF` DDL과 DML이 C01, trail,
D01을 거쳐 Target에 도착하도록 바로잡는다. 실행별 시각 토큰을 확인하므로
이전 Target 값이 남아 있어도 새 복제를 성공으로 오인하지 않으며, D01이
ABENDED되면 긴 대기 없이 보고서 원인과 함께 중단한다.

v0.108은 `reset_lab_all.sh`가 GoldenGate process 정의와 OS process의 종료를
확인한 뒤 소유 trail을 제거하고, 재구성 후에는 임시 트랜잭션으로
Source-Capture-Distribution-Kafka 전체 전달을 검증한다. Chapter 20 reset도
이전 lane과 checkpoint를 정리하며, OSA 시작/종료 및 상태 점검은 stale PID,
workload SQL 오류, 알려진 vendor 진단을 구분해 더 명확한 결과를 제공한다.

v0.107은 저자용 writer-tools의 resume 체크포인트에 다섯 Lab Kit
컨테이너의 식별값을 함께 저장한다. 일반 stop/start에서는 완료 상태를
재사용하지만 `stopDocker.sh --rm` 후 컨테이너가 재생성되면 이전 완료
표시를 자동으로 무효화하고 해당 baseline을 다시 수행한다. 독자용 Lab Kit
실행 로직은 v0.106과 동일하다.

v0.106은 `oracle/init.sh`와 `centos/init.sh`가 호출하는 공통 초기화
함수에서 각 컨테이너의 root 및 서비스 계정 `.bash_profile`, `.bashrc`,
`.profile`에 `/etc/profile.d/goldengate-lab-utf8.sh`를 읽는 블록을 직접
반영한다. init 단계에서 각 profile을 새 셸로 읽어 `locale charmap`이
`UTF-8`인지 검증하므로 별도의 수동 locale 설정 없이 다음 로그인부터
한글 SQL을 정상적으로 편집할 수 있다.

v0.105는 `create_docker.sh`가 컨테이너뿐 아니라 Base Linux의 root와 oracle
profile에도 UTF-8 locale을 영구 설정한다. `LANG`, `LC_CTYPE`, `LC_ALL`을
설치된 UTF-8 locale로 통일하고, 이미 열려 있는 부모 셸에는 profile을 다시
읽거나 재로그인하라는 안내를 출력한다.

v0.104는 한글 업무 데이터가 들어 있는 OSA SQL 네 개를 UTF-8/LF로
정규화한다. 첫 줄은 LF이고 나머지는 CRLF였던 혼합 줄바꿈을 제거해 `vi`에서
`^M`과 깨진 한글이 나타나지 않으며, 릴리스 빌드가 UTF-8 유효성과 CR 문자
부재를 검사해 같은 문제가 재발하지 않도록 한다.

v0.103은 `reset_lab_all.sh`가 파괴적인 reset을 시작하기 전에 현재 호스트의
OSA Source 스크립트와 SQL을 Source DB 컨테이너에 동기화한다. Lab Kit을
갱신한 뒤 기존 컨테이너를 재사용해도 `prepare_osa_source_objects.sh`와 분리된
seed SQL이 누락되지 않으며, 호스트 원본이 없으면 아무것도 변경하기 전에
정확한 오류로 중단한다.

v0.102는 데이터베이스 컨테이너 초기화에서 더 이상 사용하지 않는 JDK 17과
JDK 8 RPM 설치 시도를 제거한다. ORDS용 Java는 12장의 표준 설치 절차가
JDK 21로 구성하므로, 제품 media에 구형 RPM이 없어도 불필요한 오류가
출력되지 않는다. 별도 저자 도구는 `writer_prepare_lab15.sh`와
`writer_prepare_lab16.sh` 실행 시 `OGGADMIN_PASS`를 숨김 입력으로 받는다.

v0.101은 7장의 기본 Source 업무 객체 SQL을
`create_source_business_objects.sql`, 15장의 OSA 전체 Source 준비 script를
`prepare_osa_source_objects.sh`로 구분한다. 기존 이름은 호환 wrapper로 남긴다.
5,000건의 `SOE.CALL_CENTER_LOG` seed는 별도
`call_center_log_inserts.sql`에서 읽어 가독성을 높였으며, 컨테이너 초기화가
설치된 UTF-8 locale을 shell profile에 설정해 `vi`에서도 한글을 정상 표시한다.

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
