# GoldenGate Lab Kit

`Oracle GoldenGate 실전 데이터 플랫폼` 도서의 실습 환경을 구성하기 위한
비공식 독자용 Lab Kit입니다.

이 저장소는 저자가 개인적으로 관리하며 Oracle의 공식 저장소가 아닙니다.
Oracle 제품 설치 파일, 라이선스가 적용되는 바이너리, 계정 정보, API 키,
wallet 및 실습 데이터는 포함하지 않습니다. Oracle 제품은 반드시 공식
경로에서 직접 내려받아야 합니다.

## 다운로드

Oracle Linux 8.10 on WSL2에서 다음 명령을 실행합니다.

```bash
cd /home/oracle

curl -fLO https://github.com/drastone/goldengate-labkit/releases/latest/download/goldengate-labkit.tar.gz
curl -fLO https://github.com/drastone/goldengate-labkit/releases/latest/download/goldengate-labkit.tar.gz.sha256

sha256sum -c goldengate-labkit.tar.gz.sha256
tar -xzf goldengate-labkit.tar.gz --strip-components=1
```

압축을 해제한 후 도서의 안내에 따라 라이선스가 적용되는 제품 파일을
`oracle/pkg`와 `centos/pkg`에 배치합니다. ZooKeeper, Kafka, Spark는
Big Data/Analytics 이미지를 만들 때 Apache Archive에서 자동으로 내려받고
고정된 SHA-512 체크섬으로 검증합니다. Docker Engine과 Docker Compose
plugin이 준비된 다음에는 아래 사전 점검을 실행합니다.

Oracle 제품 파일명, 배치 위치, checksum은
[제품 설치 파일 다운로드 목록](docs/downloads/README.md)에서 확인합니다.

```bash
cd /home/oracle
bash check_labkit.sh
```

사전 점검에서 오류가 남아 있는 동안에는 `create_docker.sh`를 실행하지
마십시오.

## 배포 원칙

- Release의 `latest` URL은 최신 검증본을 가리킵니다.
- 버전은 Release 태그와 압축 내부의 `VERSION` 파일에서 확인할 수 있습니다.
- 설치 파일과 변동 가능성이 큰 절차는 도서 및 온라인 부록에서 안내합니다.
- 실습 서비스는 독자 PC의 로컬 환경에서만 사용하고 인터넷에 공개하지 않습니다.
