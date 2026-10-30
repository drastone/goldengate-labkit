# GoldenGate Lab Kit WSL 호환성 안내

이 페이지는 책에 인쇄되는 고정 안내 주소다. Microsoft WSL online catalog가 바뀌면 이 페이지와 `wsl-compatibility.json`에 현재 Lab Kit으로 검증된 배포판을 공지한다.

## 현재 검증 기준

| 항목 | 검증 값 |
|---|---|
| WSL | WSL2 |
| 배포판 | `OracleLinux_8_10` |
| OS | Oracle Linux 8.10 |
| Lab Kit | v0.30 |
| 확인일 | 2026-10-30 |

## 자동 확인 및 설치

일반 PowerShell에서 짧은 이름의 설치 스크립트를 내려받는다.

```powershell
curl.exe -fLO https://raw.githubusercontent.com/drastone/goldengate-labkit/main/setup.ps1
```

내용을 먼저 확인한다.

```powershell
type .\setup.ps1
```

확인한 스크립트를 실행한다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

스크립트는 GitHub에 공지된 검증 배포판과 실제 설치 명령을 화면에 보여 준다. `Y` 또는 `YES`를 입력한 경우에만 Windows의 `wsl.exe`에 설치를 요청하며, Enter 또는 `N`을 입력하면 설치하지 않는다. 해당 배포판이 Microsoft WSL catalog에 없으면 `wsl.exe`가 설치하지 않고 오류를 반환한다.

정상적인 확인 화면은 다음과 같다.

```text
Validated distribution: OracleLinux_8_10
Validated OS version: 8.10
Command to run: wsl.exe --install -d OracleLinux_8_10
Run this command? [Y/N]:
```

`Y`를 입력하면 Oracle Linux 설치가 시작된다. 최초 실행에서 기본 UNIX 사용자 이름을 묻는 경우 `oracle`을 입력하고 password를 두 번 지정한다. Password를 입력하는 동안 화면에 문자나 별표가 나타나지 않는 것은 정상이다. 설치가 끝나면 다음 prompt가 표시된다.

```text
Installation successful!
[oracle@DESKTOP-XXXX ~]$
```

이 설치 흐름에서는 `oracle` 사용자가 이미 만들어지므로 이후에 `useradd oracle`을 다시 실행하지 않는다. System package와 group 설정에 root 권한이 필요할 때는 `oracle` shell에서 `sudo -i`를 실행한다. 첫 실행에서는 `We trust you have received the usual lecture...`로 시작하는 표준 안내문과 `[sudo] password for oracle:` prompt가 표시될 수 있다. 안내문은 오류가 아니며, 설치 때 지정한 `oracle` password를 입력한 뒤 prompt가 `[root@DESKTOP-XXXX ~]#`로 바뀌면 정상이다.

## 직접 설치

`wsl --list --online` 결과에 `OracleLinux_8_10`이 있다면 다음 명령으로 직접 설치해도 된다.

```powershell
wsl --install -d OracleLinux_8_10
```

목록에 해당 이름이 없으면 다른 major version을 임의로 대신 설치하지 않는다.
