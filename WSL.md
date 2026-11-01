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

이 설치 흐름에서는 `oracle` 사용자와 `/home/oracle`이 이미 만들어지므로 이후에 `useradd oracle`을 다시 실행하지 않는다. System 설정에 root 권한이 필요할 때는 `oracle` shell에서 `sudo -i`를 실행한다. 첫 실행에서는 `We trust you have received the usual lecture...`로 시작하는 표준 안내문과 `[sudo] password for oracle:` prompt가 표시될 수 있다. 안내문은 오류가 아니며, 설치 때 지정한 `oracle` password를 입력한 뒤 prompt가 `[root@DESKTOP-XXXX ~]#`로 바뀌면 정상이다.

GoldenGate Lab Kit의 Base Linux는 Docker 설치와 image build를 root로 수행하므로 `/etc/wsl.conf`에서 systemd와 기본 root 로그인을 사용한다. `oracle` account와 `/home/oracle`은 삭제하지 않으며, Base Linux의 소유권은 `oracle:oracle`을 사용한다. `oinstall`과 `dba`는 Oracle 관련 container 내부에서 별도로 관리한다.

```ini
[boot]
systemd=true

[user]
default=root
```

설정 파일을 저장한 뒤 Linux shell에서 빠져나와 PowerShell에서 WSL을 완전히 종료하고 다시 실행한다. Terminal 창만 닫아서는 설정이 적용되지 않는다.

```powershell
wsl --shutdown
wsl -d OracleLinux_8_10
```

재실행된 Linux shell에서 다음 결과가 각각 `root`, `systemd`인지 확인한 뒤 SSH Server와 Docker 설치를 진행한다.

```bash
whoami
ps -p 1 -o comm=
```

systemd 적용 전에 `systemctl`을 실행하면 `System has not been booted with systemd as init system (PID 1). Can't operate.` 오류가 발생한다.

최초 사용자 생성이 중단되어 `id oracle`이 실패하면 아래 `WSL 오류 문제 해결`의 `oracle 계정 복구` 절을 따른다. `oracle`이 이미 존재하면 복구 명령을 실행하지 않는다.

## 직접 설치

`wsl --list --online` 결과에 `OracleLinux_8_10`이 있다면 다음 명령으로 직접 설치해도 된다.

```powershell
wsl --install -d OracleLinux_8_10
```

목록에 해당 이름이 없으면 다른 major version을 임의로 대신 설치하지 않는다.

## WSL 오류 문제 해결

### `oracle` 계정 복구

이 절은 `id oracle`을 실행했을 때 `id: 'oracle': no such user`가 표시되는 경우에만 수행한다. `uid=... (oracle)`이 정상적으로 표시되면 `useradd`와 `passwd`를 실행하지 않는다.

일반 PowerShell에서 Oracle Linux를 root 사용자로 실행하고 계정이 실제로 없는지 다시 확인한다.

```text
PS C:\Users\reader> wsl -d OracleLinux_8_10 -u root
[root@DESKTOP-XXXX ~]# id oracle
id: 'oracle': no such user
```

위와 같이 계정이 없을 때만 `oracle` 사용자와 home directory를 만들고 공통 실습용 password를 지정한다. `New password:`와 `Retype new password:`에는 모두 **WElcome1234##**를 입력한다. 입력 중에는 화면에 문자나 별표가 표시되지 않는다.

```text
[root@DESKTOP-XXXX ~]# useradd -m -U -G wheel oracle

[root@DESKTOP-XXXX ~]# passwd oracle
Changing password for user oracle.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

[root@DESKTOP-XXXX ~]# id oracle
uid=<UID>(oracle) gid=<GID>(oracle) groups=<GID>(oracle),<wheel GID>(wheel)
```

마지막 `id oracle` 결과에 사용자와 primary group이 모두 `oracle`로 표시되면 복구가 완료된 것이다. `/etc/wsl.conf`의 `[user] default=root` 설정은 그대로 유지하며, Base Linux에 `oinstall`이나 `dba` group을 별도로 만들지 않는다.

### `0x80370102`가 반복될 때

이 절은 정상 설치 과정에서 따라 하는 필수 단계가 아니다. `wsl --list -v`에서 배포판이 `VERSION 2`로 보이고 Linux shell이 정상적으로 열리면 아래 명령을 실행하지 않는다.

WSL2 설치 또는 시작 시 `0x80370102`가 발생하면 다음 순서로 확인한다.

1. 작업 관리자의 `성능 > CPU`에서 `가상화: 사용`인지 확인한다.
2. BIOS/UEFI에서 Intel VT-x, AMD-V 또는 SVM이 활성화되어 있는지 확인한다.
3. Windows의 `Windows Subsystem for Linux`와 `Virtual Machine Platform` 기능을 활성화하고 Windows를 재부팅한다.
4. 위 조건을 모두 확인하고 재부팅했는데도 같은 오류가 반복될 때만 `hypervisorlaunchtype`을 확인한다.

`bcdedit`는 Windows Boot Configuration Data 저장소를 조회하거나 변경하므로 관리자 권한이 필요하다. 일반 PowerShell에서 다음 명령으로 관리자 PowerShell을 연다.

```powershell
PS C:\Users\reader> Start-Process PowerShell -Verb RunAs
```

사용자 계정 컨트롤 창에서 `예`를 선택하고, 새 창 제목에 `관리자: Windows PowerShell` 또는 `Administrator: Windows PowerShell`이 표시되는지 확인한다. 새 관리자 창의 prompt는 일반적으로 `PS C:\WINDOWS\system32>`로 시작한다.

관리자 PowerShell에서 현재 값을 확인한다.

```powershell
PS C:\WINDOWS\system32> bcdedit /enum | findstr -i hypervisorlaunchtype
hypervisorlaunchtype    Off
```

결과가 `Off`일 때만 `Auto`로 변경하고 재부팅한다.

```powershell
PS C:\WINDOWS\system32> bcdedit /set hypervisorlaunchtype Auto
The operation completed successfully.

PS C:\WINDOWS\system32> shutdown /r /t 0
```

값이 이미 `Auto`라면 변경 명령을 실행하지 않는다. 항목이 표시되지 않으면 값을 임의로 추가하지 말고 BIOS/UEFI 가상화와 두 Windows 기능의 활성화 여부부터 다시 확인한다. 일반 PowerShell에서 `bcdedit`를 실행하면 액세스가 거부될 수 있다.

Microsoft의 [WSL 문제 해결 문서](https://learn.microsoft.com/windows/wsl/troubleshooting)와 [Windows 가상화 활성화 안내](https://support.microsoft.com/windows/experience/enable-virtualization-on-windows)도 함께 확인한다. 오류가 해결되지 않으면 표시된 오류 코드와 Windows version을 기록한 뒤 Lab Kit 저장소의 issue로 문의한다.
