# WSL 저장 공간 점검과 VHDX 회수

이 문서는 GoldenGate Lab Kit을 실행하는 Windows/WSL2 환경에서 저장 공간
부족 메시지가 나타났을 때 사용하는 유지보수 절차다. 일반적인 Lab 시작
절차가 아니며, 먼저 불필요한 실제 데이터를 정리한 뒤에도 Windows drive의
공간이 충분히 회수되지 않을 때만 VHDX compact를 검토한다.

## 1. 현재 상태 확인

Oracle Linux WSL에서 Lab을 종료하고 사용 현황을 확인한다.

```bash
cd /home/oracle
bash stopOSA.sh
bash stopDocker.sh
docker ps
docker system df
df -h /mnt/d
```

`docker system df`는 확인 명령이다. 결과를 확인하지 않은 채
`docker volume prune`을 실행하지 않는다. Source/Target Database volume과
GoldenGate trail에는 실습 상태가 들어 있을 수 있다.

Windows에서는 중복으로 내려받은 Oracle product media, 오래된 압축 파일과
화면 캡처를 먼저 확인한다. WSL에서는 dangling image와 다시 생성할 수 있는
build cache처럼 삭제 대상을 명확히 설명할 수 있는 항목부터 정리한다.

## 2. Linux의 미사용 block 알리기

실제 파일 정리가 끝나면 WSL root filesystem의 사용하지 않는 block을
discard 대상으로 표시한다.

```bash
sync
fstrim -v /
exit
```

`fstrim`이 표시하는 값은 filesystem이 비어 있다고 알린 논리적 block
범위다. 이 숫자만큼 Windows drive의 여유 공간이 즉시 증가한다는 뜻이
아니며, 이 명령만으로 `ext4.vhdx`의 물리 파일 크기가 줄어드는 것도 아니다.

## 3. 정확한 VHDX 경로 확인

일반 PowerShell에서 대상 배포판과 실제 VHDX 경로를 확인한다.

```powershell
wsl --list -v
$distro = "OracleLinux_8_10"
$vhdx = (Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | Where-Object { $_.GetValue("DistributionName") -eq $distro }).GetValue("BasePath") + "\ext4.vhdx"
$vhdx
Get-Item $vhdx | Select-Object FullName, Length
```

출력된 경로가 실제 Lab 배포판의 `ext4.vhdx`인지 확인한다. 경로가 비어
있거나 예상과 다르면 다음 단계로 진행하지 않는다. 중요한 Lab script와
설정은 별도 위치에 백업하고, Windows Terminal과 VS Code처럼 WSL을 사용할
수 있는 application을 모두 닫는다.

## 4. WSL 종료와 관리자 PowerShell 실행

일반 PowerShell에서 WSL을 완전히 종료한다.

```powershell
wsl --shutdown
```

`diskpart`에는 관리자 권한이 필요하다. 일반 PowerShell에서 관리자
PowerShell을 열고 사용자 계정 컨트롤 창에서 `예`를 선택한다.

```powershell
Start-Process PowerShell -Verb RunAs
```

새 창 제목에 `관리자` 또는 `Administrator`가 표시되는지 확인한다. 조직
정책으로 권한 상승이 차단되어 있으면 우회하지 말고 PC 관리자에게 문의한다.

## 5. VHDX compact

새로 열린 관리자 PowerShell에서 `diskpart`를 실행한다. 아래 예시 경로를
그대로 복사하지 말고, 앞 단계에서 확인한 실제 `$vhdx` 경로를 사용한다.

```text
PS C:\WINDOWS\system32> diskpart

DISKPART> select vdisk file="D:\WSL\OracleLinux_8_10\ext4.vhdx"
DISKPART> attach vdisk readonly
DISKPART> compact vdisk
DISKPART> detach vdisk
DISKPART> exit
```

`compact vdisk`는 동적으로 증가하는 VHDX에서 사용하지 않는 block을 제거해
Windows가 사용하는 물리 파일 크기를 줄인다. 대상 VHDX는 분리되어 있거나
read-only로 연결된 상태여야 한다.

완료 후 일반 PowerShell에서 WSL을 다시 시작한다.

```powershell
wsl -d OracleLinux_8_10
```

Oracle Linux에서 Windows drive의 여유 공간을 다시 확인한다.

```bash
df -h /mnt/d
```

## 주의

- VHDX compact는 일반적인 Lab 시작 절차가 아니다.
- WSL 배포판이 실행 중일 때 `ext4.vhdx`를 직접 이동하거나 편집하지 않는다.
- registry에서 확인한 경로가 예상과 다르거나 backup이 없으면 중단한다.
- Source/Target Database volume과 GoldenGate trail을 공간 확보 목적으로
  임의 삭제하지 않는다.

최신 WSL disk 관리 방식은 Microsoft의
[WSL disk space 안내](https://learn.microsoft.com/windows/wsl/disk-space)를
확인한다. `compact vdisk`의 실행 조건은
[Microsoft DiskPart 문서](https://learn.microsoft.com/windows-server/administration/windows-commands/compact-vdisk)를
기준으로 한다.
