# Oracle 제품 설치 파일 다운로드 가이드

이 문서는 `Oracle GoldenGate 실전 데이터 플랫폼` Lab Kit에서 사용하는 대표
Oracle 제품 3종을 Oracle Software Delivery Cloud에서 직접 내려받는 전체
절차를 설명한다.

Oracle 제품 설치 파일과 라이선스가 적용되는 바이너리는 이 GitHub
저장소와 Lab Kit Release에 포함하지 않는다. 독자는 본인의 Oracle 계정으로
[Oracle Software Delivery Cloud](https://edelivery.oracle.com/)에 로그인하고,
현재 표시되는 라이선스 조건을 확인한 뒤 직접 내려받아야 한다.

화면의 제품명, release, 파일 크기와 part number는 Oracle의 제품 업데이트에
따라 달라질 수 있다. 이 문서의 화면은 2026년 10월 29일 검증 기준이며,
실제 다운로드 시에는 eDelivery에 표시되는 최신 정보와 `View Digest Details`를
우선한다.

## 다운로드할 대표 제품 3종

| 제품 | eDelivery 파일명 | 배치 위치 | 확인 기준 |
|---|---|---|---|
| Oracle AI Database 26ai EE, Linux x86-64 | `V1054592-01.zip` | `/home/oracle/oracle/pkg` | 2.3G, SHA-256 `2a5d2583df076209e624dff750829f9a562473c27c8f926d546cf9ad2a1a2efd` |
| Oracle GoldenGate for Oracle, Linux x86-64 | `V1054774-01.zip` | `/home/oracle/oracle/pkg` | 497M, SHA-256 `cd9220e74c7e3afe73bd00c40778faf8bee6cb0fb18140eee0e0ad9d4d140f96` |
| GoldenGate for Distributed Applications and Analytics, Linux x86-64 | `V1054834-01.zip` | `/home/oracle/oracle/pkg` | eDelivery 표시 520.7 MB, SHA-256 `8971fdfeb734a30df09b486f3c49a99ff4335a0daced21a8f70783d783413c45` |

## 공통 준비와 주의 사항

1. eDelivery에서 제품을 검색하려면 Oracle Account 로그인이 필요하다. 계정이
   없다면 sign-in 화면에서 `Create Account`를 선택해 생성한다.
2. 같은 브라우저 session에서는 이전에 선택한 제품이 Download Queue에 남을
   수 있다. 다음 제품을 받을 때 이미 다운로드한 제품의 상위 checkbox를
   해제하지 않으면 WGET script에 여러 제품이 함께 포함될 수 있다.
3. WGET script가 요청하는 access token은 eDelivery의 `WGET Options`에서
   `Generate Token`을 눌러 생성한다. 검증 환경에서는 약 1시간 동안
   유효했지만 실제 만료 시간은 Oracle 정책에 따라 달라질 수 있다.
4. Token은 터미널에 한 번만 붙여넣고 Enter를 누른다. 입력 문자가 보이지
   않더라도 다시 붙여넣지 않는다. Token, 임시 URL, Oracle 계정 정보는
   캡처하거나 GitHub에 올리지 않는다.
5. 제품 하나를 받을 때마다 바로 Docker image를 build하지 않는다. 필요한
   제품 media를 먼저 모두 다운로드하고 checksum을 검증한 뒤 image를
   일괄 build한다.

## 1. Oracle AI Database 26ai EE

### 1.1 제품 검색

eDelivery 검색창에 `Oracle AI Database`를 입력한다. 검색 결과의
`Oracle AI Database 23.26.1.0.0`은 Oracle AI Database 26ai 계열의
software version이다. 첫 번째 DLP 항목을 선택한다.

![Oracle AI Database 26ai 검색](assets/figure-03-01-oracle-edelivery-database-26ai-search.png)

화면 오른쪽 위의 `View Items`에 선택 수가 표시되면 `Continue`를 클릭한다.

### 1.2 Platform과 파일 선택

Download Queue에서 `Oracle AI Database 23.26.1.0.0`을 선택하고
`Platforms / Languages`를 `Linux x86-64`로 지정한다. Database server
image를 만드는 데 별도의 Database Client package는 필요하지 않다.

![Database와 Linux x86-64 선택](assets/figure-03-03-oracle-edelivery-download-queue-platform.png)

라이선스 내용을 확인한 뒤 `I reviewed and accept the Oracle License
Agreement`를 선택하고 `Continue`를 클릭한다.

![Database 라이선스 확인](assets/figure-03-04-oracle-edelivery-license-agreement.png)

### 1.3 WGET script와 token 준비

파일 목록에서 `WGET Options`를 클릭한다. 팝업에서 먼저
`Download wget.sh`를 눌러 WGET script를 Windows Downloads 폴더에 저장한다.

![Database WGET Options](assets/figure-03-05-oracle-edelivery-wget-options.png)

WSL에서 script를 제품별 이름으로 옮기고 실행 권한을 설정한다.

```bash
cd /mnt/c/Users/<WindowsUser>/Downloads/
mv wget.sh /home/oracle/oracle/pkg/wget_oracle_db_26ai.sh
cd /home/oracle/oracle/pkg
chmod 700 wget_oracle_db_26ai.sh
ls -l wget_oracle_db_26ai.sh
```

Script를 실행하면 access token 입력을 기다린다.

```text
[root pkg]# sh wget_oracle_db_26ai.sh
Please paste your access token and press Enter:
```

브라우저의 `WGET Options`로 돌아가 `Generate Token`을 클릭한다.

![Database access token 생성](assets/figure-03-06-oracle-edelivery-authentication.png)

새 창에서 `Copy`를 클릭한 뒤 token을 터미널에 한 번 붙여넣고 Enter를 누른다.
다음 그림은 실제 token을 마스킹한 편집본이다.

![Database access token 복사](assets/figure-03-07-oracle-edelivery-copy-authentication.png)

정상적으로 전달되면 background download가 시작된다. 출력이 잠시 없어도
`Download initiated (background)`가 표시됐다면 script를 다시 실행하지 않고
`Download completed`와 `Script Finished`가 나타날 때까지 기다린다.

```text
[ACCESS TOKEN MASKED]
[INFO] Download initiated (background) for: V1054592-01.zip
[INFO] All download(s) initiated in background.
[INFO] Download completed: V1054592-01.zip (saved to: ./V1054592-01.zip)
[INFO] ==== Script Finished ====
```

### 1.4 파일 검증

```bash
cd /home/oracle/oracle/pkg
ls -lh V1054592-01.zip
sha256sum V1054592-01.zip
```

검증 환경의 결과는 다음과 같다.

```text
-rw-r--r-- 1 root root 2.3G Jan 23  2026 V1054592-01.zip
2a5d2583df076209e624dff750829f9a562473c27c8f926d546cf9ad2a1a2efd  V1054592-01.zip
```

## 2. Oracle GoldenGate for Oracle

### 2.1 제품 검색

eDelivery 검색창에 `Oracle GoldenGate`를 입력하고 `Search`를 클릭한다.
검색 결과에서 `DLP: Oracle GoldenGate 23.4`를 선택한다.

![Oracle GoldenGate 검색](assets/figure-03-08-oracle-edelivery-goldengate-search.png)

`View Items`에 선택 수가 표시되면 `Continue`를 클릭한다. 앞에서 선택한
Database 항목이 남아 있으면 선택 수가 2로 보일 수 있다.

![GoldenGate 선택 항목을 Download Queue로 이동](assets/figure-03-09-oracle-edelivery-goldengate-continue.png)

### 2.2 기존 항목 해제와 installer 선택

Download Queue에서 이미 받은 Database의 상위 checkbox를 해제하고
`Oracle GoldenGate 23.4.0.0.0`만 선택한다. Platform은 `Linux x86-64`로
지정한 뒤 `Continue`를 클릭한다.

![기존 Database를 해제하고 GoldenGate 선택](assets/figure-03-10-oracle-edelivery-goldengate-download-queue.png)

라이선스 내용을 확인하고 동의한 뒤 `Continue`를 클릭한다.

![GoldenGate 라이선스 확인](assets/figure-03-11-oracle-edelivery-goldengate-license-agreement.png)

File list에서는 다음 Oracle Database용 installer만 선택한다.

```text
V1054774-01.zip
Oracle GoldenGate 23.26.1.0.0 on Linux x86-64 for Oracle
Size: 496.0 MB
```

DB2 for LUW용 `V1054817-01.zip` 등 다른 Database installer는 선택하지 않는다.
파일을 확인한 뒤 `WGET Options`를 열고 `Download wget.sh`를 클릭한다.

![GoldenGate installer의 WGET script 선택](assets/figure-03-12-oracle-edelivery-goldengate-wget-selection.png)

### 2.3 WGET script 실행

```bash
cd /mnt/c/Users/<WindowsUser>/Downloads/
mv wget.sh /home/oracle/oracle/pkg/wget_oracle_goldengate_26ai.sh
cd /home/oracle/oracle/pkg
chmod 700 wget_oracle_goldengate_26ai.sh
ls -l wget_oracle_goldengate_26ai.sh
```

```text
[root pkg]# sh wget_oracle_goldengate_26ai.sh
Please paste your access token and press Enter:
```

`Generate Token`을 눌러 GoldenGate 다운로드용 새 token을 만든다.

![GoldenGate access token 생성](assets/figure-03-13-oracle-edelivery-goldengate-authentication.png)

`Copy`를 클릭하고 터미널에 한 번만 붙여넣는다. 그림의 token과 주소창 인증
정보는 모두 마스킹되어 있다.

![GoldenGate access token 복사](assets/figure-03-14-oracle-edelivery-goldengate-copy-authentication.png)

```text
[ACCESS TOKEN MASKED]
[INFO] Download initiated (background) for: V1054774-01.zip
[INFO] All download(s) initiated in background.
[INFO] Download completed: V1054774-01.zip (saved to: ./V1054774-01.zip)
[INFO] ==== Script Finished ====
```

### 2.4 파일 검증

```bash
cd /home/oracle/oracle/pkg
ls -lh V1054774-01.zip
sha256sum V1054774-01.zip
```

```text
-rw-r--r-- 1 root root 497M Jan 29  2026 V1054774-01.zip
cd9220e74c7e3afe73bd00c40778faf8bee6cb0fb18140eee0e0ad9d4d140f96  V1054774-01.zip
```

## 3. GoldenGate for Distributed Applications and Analytics

이 제품은 예전 문서나 현장 대화에서 GoldenGate for Big Data 또는 OGG for
BigData라고 부르기도 한다. Kafka, Iceberg, Object Storage 같은 target으로
CDC event를 전달하는 실습에서 사용한다.

### 3.1 제품 검색

검색창에 `goldengate for distributed`를 입력하고 자동완성 목록의
`GoldenGate for Distributed Applications & Analytics`를 선택한다.

![GoldenGate DAA 검색](assets/figure-03-15-oracle-edelivery-goldengate-daa-search.png)

검색 결과에서 위쪽의 `DLP: Oracle GoldenGate for Distributed Applications
and Analytics 26.1.2`를 선택한다. `License Subscription` 항목은 선택하지 않는다.

![GoldenGate DAA Product Pack 선택](assets/figure-03-16-oracle-edelivery-goldengate-daa-search-result.png)

### 3.2 기존 항목 해제와 installer 선택

Download Queue에 이전 제품이 남아 있으면 모두 해제하고
`GoldenGate for Distributed Applications & Analytics 23.4.0.0.0`만
선택한다. Platform이 `Linux x86-64`이고 표시 크기가 `520.7 MB`인지
확인한다. `Oracle Transaction Manager for Microservices`는 선택하지 않는다.

![GoldenGate DAA와 Linux x86-64 선택](assets/figure-03-17-oracle-edelivery-goldengate-daa-download-queue.png)

라이선스를 확인하고 동의한 뒤 `Continue`를 클릭한다.

![GoldenGate DAA 라이선스 확인](assets/figure-03-18-oracle-edelivery-goldengate-daa-license-agreement.png)

File list에서는 다음 installer 한 개만 선택한다.

```text
V1054834-01.zip
GoldenGate for Distributed Applications and Analytics 23.26.1.0.0 on Linux x86-64
Size: 520.7 MB
```

`Total 1 distinct files`인지 확인하고 `WGET Options`를 연 뒤
`Download wget.sh`를 클릭한다.

![GoldenGate DAA installer의 WGET script 선택](assets/figure-03-19-oracle-edelivery-goldengate-daa-wget-selection.png)

### 3.3 WGET script 실행

```bash
cd /mnt/c/Users/<WindowsUser>/Downloads/
mv wget.sh /home/oracle/oracle/pkg/wget_oracle_goldengate_for_DAA_26ai.sh
cd /home/oracle/oracle/pkg
chmod 700 wget_oracle_goldengate_for_DAA_26ai.sh
ls -l wget_oracle_goldengate_for_DAA_26ai.sh
```

Linux file name은 대소문자를 구분하므로 실행할 때도 `DAA`를 대문자로
정확히 입력한다.

```text
[root pkg]# sh wget_oracle_goldengate_for_DAA_26ai.sh
Please paste your access token and press Enter:
```

이전 제품에서 사용한 token을 재사용하지 않고 `Generate Token`을 클릭한다.

![GoldenGate DAA access token 생성](assets/figure-03-20-oracle-edelivery-goldengate-daa-authentication.png)

새 창에서 `Copy`를 클릭하고 터미널에 한 번만 붙여넣는다. 그림의 실제 token은
마스킹되어 있다.

![GoldenGate DAA access token 복사](assets/figure-03-21-oracle-edelivery-goldengate-daa-copy-authentication.png)

### 3.4 파일 검증

```bash
cd /home/oracle/oracle/pkg
sha256sum V1054834-01.zip
```

```text
8971fdfeb734a30df09b486f3c49a99ff4335a0daced21a8f70783d783413c45  V1054834-01.zip
```

## 세 제품 다운로드 완료 확인

세 파일을 모두 받은 뒤 한 번에 확인한다.

```bash
cd /home/oracle/oracle/pkg

ls -lh V1054592-01.zip V1054774-01.zip V1054834-01.zip
sha256sum V1054592-01.zip V1054774-01.zip V1054834-01.zip
```

세 파일의 크기와 checksum을 확인한 뒤 도서의 Docker image 일괄 build
단계로 넘어간다.

## 다음 업데이트 대상

OSA/GGSA와 JDK를 포함한 나머지 필수 제품은 Lab Kit의 실제
`preflight_downloads.sh` 요구 사항과 대조한 뒤 이 문서에 계속 추가한다.
ZooKeeper, Kafka, Spark는 현재 Lab Kit의 Dockerfile이 Apache Archive에서
자동으로 내려받고 고정된 SHA-512 checksum으로 검증하므로 독자가 별도로
다운로드하지 않는다.
