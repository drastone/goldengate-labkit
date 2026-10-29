# Oracle 제품 설치 파일 다운로드 목록

이 문서는 `Oracle GoldenGate 실전 데이터 플랫폼` Lab Kit에 필요한 Oracle
제품 설치 파일의 공식 다운로드와 배치 위치를 안내한다.

Oracle 제품 설치 파일과 라이선스가 적용되는 바이너리는 이 GitHub
저장소와 Lab Kit Release에 포함하지 않는다. 독자는 본인의 Oracle 계정으로
[Oracle Software Delivery Cloud](https://edelivery.oracle.com/)에 로그인하고,
현재 표시되는 라이선스 조건을 확인한 뒤 직접 내려받아야 한다.

## 현재까지 확인한 대표 제품 3종

| 제품 | eDelivery 파일명 | 배치 위치 | 확인 기준 |
|---|---|---|---|
| Oracle AI Database 26ai EE, Linux x86-64 | `V1054592-01.zip` | `/home/oracle/oracle/pkg` | 2.3G, SHA-256 `2a5d2583df076209e624dff750829f9a562473c27c8f926d546cf9ad2a1a2efd` |
| Oracle GoldenGate for Oracle, Linux x86-64 | `V1054774-01.zip` | `/home/oracle/oracle/pkg` | 497M, SHA-256 `cd9220e74c7e3afe73bd00c40778faf8bee6cb0fb18140eee0e0ad9d4d140f96` |
| GoldenGate for Distributed Applications and Analytics, Linux x86-64 | `V1054834-01.zip` | `/home/oracle/oracle/pkg` | eDelivery 표시 520.7 MB, SHA-256 `8971fdfeb734a30df09b486f3c49a99ff4335a0daced21a8f70783d783413c45` |

제품 release가 갱신되면 파일명, 크기, checksum이 달라질 수 있다. 위 값은
2026년 10월 29일 Lab Kit 검증 기록이며, 실제 다운로드 시에는 eDelivery의
`View Digest Details`에 표시되는 값을 우선한다.

## 배치 확인

세 파일을 모두 내려받은 뒤 WSL에서 다음과 같이 확인한다.

```bash
cd /home/oracle/oracle/pkg

ls -lh V1054592-01.zip V1054774-01.zip V1054834-01.zip
sha256sum V1054592-01.zip V1054774-01.zip V1054834-01.zip
```

제품 하나를 받을 때마다 바로 Docker image를 build하지 않는다. 필요한
제품 media를 먼저 모두 다운로드하고 크기와 checksum을 검증한 다음,
도서의 안내에 따라 Docker image를 일괄 build한다.

## 다음 업데이트 대상

OSA/GGSA와 JDK를 포함한 나머지 필수 제품은 Lab Kit의 실제
`preflight_downloads.sh` 요구 사항과 대조한 뒤 이 목록에 계속 추가한다.
ZooKeeper, Kafka, Spark는 현재 Lab Kit의 Dockerfile이 Apache Archive에서
자동으로 내려받고 고정된 SHA-512 checksum으로 검증하므로 독자가 별도로
다운로드하지 않는다.
