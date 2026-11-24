# vi 편집기 최소 사용법

GoldenGate Admin Client에서 `EDIT GLOBALS`, `EDIT PARAMS MGR`, `EDIT PARAMS C01` 같은 명령을 실행하면 parameter file을 편집하는 화면이 열린다. Lab Kit container에서는 보통 `vi` 형태의 편집기를 사용한다. 이 책의 본문에서는 GoldenGate 설정 자체에 집중하고, 편집기 사용법은 이 부록에서 짧게 정리한다.

이 부록은 vi 전체 설명서가 아니다. 실습 중 parameter file을 열고, 몇 줄을 입력하고, 필요하면 한 줄을 지운 뒤 저장하고 나오는 데 필요한 최소 명령만 다룬다.

## vi의 두 가지 상태

vi는 크게 두 상태로 동작한다.

| 상태 | 의미 |
|---|---|
| Normal mode | cursor 이동, 삭제, 저장, 종료 같은 명령을 입력하는 상태 |
| Insert mode | 실제 text를 입력하는 상태 |

처음 vi가 열리면 보통 Normal mode다. 글자를 바로 입력하려고 하면 입력되지 않거나 이상한 동작처럼 보일 수 있다. 먼저 `i` 또는 `a`를 눌러 Insert mode로 들어간다.

## 자주 쓰는 키

| 키 | 의미 |
|---|---|
| `i` | 현재 cursor 앞에서 입력 시작 |
| `a` | 현재 cursor 뒤에서 입력 시작 |
| `o` | 현재 줄 아래에 새 줄을 만들고 입력 시작 |
| `Esc` | Insert mode에서 Normal mode로 돌아감 |
| 방향키 또는 `h`, `j`, `k`, `l` | cursor 이동 |
| `x` | cursor 위치의 글자 1개 삭제 |
| `dd` | 현재 줄 전체 삭제 |
| `u` | 마지막 작업 취소 |
| `:wq` | 저장하고 종료 |
| `:q!` | 저장하지 않고 종료 |

가장 중요한 키는 `Esc`다. 저장하거나 종료하려면 먼저 `Esc`를 눌러 Normal mode로 돌아온 뒤 `:wq` 또는 `:q!`를 입력한다.

## GoldenGate parameter file 편집 예

예를 들어 Admin Client에서 Extract parameter를 편집할 때는 다음 명령을 실행한다.

```text
EDIT PARAMS C01
```

vi 화면이 열리면 다음 순서로 편집한다.

1. `i`를 눌러 Insert mode로 들어간다.
2. 필요한 parameter를 입력하거나 수정한다.
3. 입력이 끝나면 `Esc`를 누른다.
4. 저장하고 나가려면 `:wq`를 입력한 뒤 `Enter`를 누른다.

잘못 열었거나 저장하지 않고 나가고 싶으면 `Esc`를 누른 뒤 `:q!`를 입력한다.

## 한 줄을 지우는 예

잘못 입력한 한 줄을 삭제하려면 다음처럼 한다.

1. `Esc`를 눌러 Normal mode로 이동한다.
2. 방향키로 삭제할 줄에 cursor를 둔다.
3. `dd`를 누른다.
4. 계속 편집하려면 `i` 또는 `a`를 누른다.
5. 저장하고 나가려면 `Esc` 후 `:wq`를 입력한다.

## 실습에서 기억할 최소 조합

실습 중에는 아래 네 가지만 알아도 대부분 충분하다.

```text
i      입력 시작
Esc    명령 상태로 돌아가기
dd     현재 줄 삭제
:wq    저장 후 종료
```

취소하고 싶을 때는 다음을 사용한다.

```text
:q!    저장하지 않고 종료
```

vi가 낯설어도 걱정할 필요는 없다. 이 책에서 직접 편집하는 파일은 대부분 GoldenGate parameter file이고, 입력할 내용도 몇 줄 단위다. 복잡한 편집보다는 정확히 입력하고 저장하는 것이 중요하다.
