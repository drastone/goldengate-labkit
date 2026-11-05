# 12장 APEX/ORDS 완전 초기화

이 절차는 12장의 일반적인 실습 순서가 아니다. troubleshooting으로 복구되지
않는 부분 설치, 손상된 구성, 또는 완전한 재설치 검증이 필요한 경우에만
사용한다.

초기화 script는 `ORCLPDB1`에서 ORDS를 먼저 제거하고 APEX를 나중에 제거한다.
ORDS database schema와 proxy user를 제거하고, Oracle 공식 `apxremov.sql`을
실행해 APEX component registry, schema, 관련 사용자, synonym, application과
workspace를 정리한다. 기존 ORDS configuration directory는 timestamp가 붙은
이름으로 보존한다.

유지해야 할 APEX application이나 workspace가 있는 환경에서는 실행하지 않는다.
필요한 항목을 먼저 export하거나 별도로 백업한 뒤 진행한다.

Base Linux의 12장 디렉터리로 이동한 뒤, 실행하기 전에 reset script의 내용을
먼저 확인한다.

```bash
cd /home/oracle/labs/lab12
cat lab12_reset.sh
```

script가 `RESET-LAB12-ORCLPDB1` 확인 문자열을 요구하는지, `remove_ords.sh`를
`remove_apex.sh`보다 먼저 호출하는지 확인한다. 경고와 대상 PDB를 확인한 뒤
별도의 단계로 초기화를 실행한다.

```bash
bash lab12_reset.sh --confirm RESET-LAB12-ORCLPDB1
```

`RESET-LAB12-ORCLPDB1`은 실수로 삭제 명령을 실행하지 못하게 하는 고정 확인
문자열이다. password가 아니다. 확인 문자열을 생략하거나 정확히 일치하지 않으면
아무것도 제거하지 않고 종료한다.

제거가 시작된 뒤에는 명령을 중단하지 않는다. 정상적으로 초기화되면 마지막에
다음과 같은 메시지가 출력된다.

```text
OK: ORDS database schemas and proxy users are absent from ORCLPDB1.
OK: Oracle APEX and APEX-related schemas are absent from ORCLPDB1.
OK: lab12-reset completed.
```

log는 `/home/oracle/logs/lab12`에 기록된다. `ERROR`가 출력되면 임의로
`DROP USER`를 실행하지 말고 안내된 log를 먼저 확인한다.

초기화가 완료되면 12장 환경을 다시 설치하고 검증한다.

```bash
bash lab12_init.sh
```
