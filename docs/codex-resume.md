# Codex CLI에서 기존 세션 이어서 작업하기

GoldenGate 작업에 사용하던 Codex 세션을 찾아 대화 기록을 이어가고, 다음 요청부터 GPT-6.2 Sol과 Extra High를 사용하는 방법입니다. 명령은 Linux 또는 WSL의 Bash 기준입니다.

## 1. 기존 세션 찾기

이전에 세션을 실행했던 호스트와 OS 사용자로 접속한 뒤, 작업하던 디렉터리에서 실행합니다. 원격 Linux 서버에서 시작한 세션이라면 해당 서버의 터미널에서 실행합니다.

```bash
codex resume
```

세션 선택 목록에서 작업 제목과 최근 활동 시간을 확인합니다. 작업 디렉터리 필터 때문에 목록에 보이지 않으면 `codex resume --all`로 다시 찾습니다. 세션을 연 상태에서 `/status`로 세션 ID와 작업 디렉터리를 확인할 수 있습니다.

## 2. GPT-6.2 Sol과 Extra High로 재개하기

아래 UUID는 예시입니다. 실제로 이어갈 세션의 ID로 바꿔 실행하세요.

```bash
codex resume 11111111-2222-4333-8444-555555555555 \
  -m gpt-6.2-sol -c 'model_reasoning_effort="xhigh"'
```

세션 ID를 모르면 같은 옵션을 붙여 선택 목록을 열 수 있습니다.

```bash
codex resume -m gpt-6.2-sol -c 'model_reasoning_effort="xhigh"'
```

`-m`은 모델을 지정하고, `xhigh`는 Extra High 추론 수준입니다. 이 옵션은 해당 실행에 적용됩니다. `--last`도 사용할 수 있지만, 저서나 실습처럼 여러 작업을 병행한다면 세션 ID나 선택 목록으로 의도한 대화를 고르세요.

## 3. 재개한 세션 확인하기

- 다음 작업을 보내기 전에 `/status`로 세션 ID와 작업 디렉터리가 맞는지 확인합니다. CLI에 표시된 모델과 추론 수준도 확인합니다.
- CLI에서 이미 해당 세션이 열려 있다면 `/model`에서 GPT-6.2 Sol과 Extra High를 선택할 수 있습니다.
- 세션을 찾을 수 없다면 기존 호스트, OS 사용자, Codex 설정·기록 디렉터리(`CODEX_HOME`을 따로 지정했다면 해당 경로)가 같은지 확인합니다.
- 원하는 옵션이 보이지 않거나 요청이 거절되면 `codex --version`, `codex resume --help`, `codex login status`를 확인합니다. 모델 사용 가능 여부는 CLI 버전과 로그인 계정의 권한에 따라 달라질 수 있습니다.
- `resume`은 Codex 대화 기록을 다시 엽니다. Git 브랜치와 파일 변경 상태는 터미널에서 `git status --short --branch`로 따로 확인합니다.

참고: [Codex CLI 명령](https://developers.openai.com/codex/cli/reference), [Codex 설정](https://developers.openai.com/codex/config-reference), [GPT-6.2 Sol 모델](https://developers.openai.com/api/docs/models/gpt-6.2-sol)
