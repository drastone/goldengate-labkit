# example sh gen_base.sh 10 1

RUN_TS=$(date +%Y%m%d_%H%M%S)
LOG_DIR=/home/oracle/script/osa/23ai/logs
mkdir -p "${LOG_DIR}"

start_generator() {
  name="$1"
  shift
  log_file="${LOG_DIR}/${name}_${RUN_TS}.log"
  nohup sh "${name}.sh" "$@" > "${log_file}" 2>&1 &
  printf "Started %-16s pid=%s log=%s\n" "${name}.sh" "$!" "${log_file}"
}

printf "Starting OSA base workload generators...\n"
printf "Run timestamp: %s\n" "${RUN_TS}"
printf "Log directory: %s\n\n" "${LOG_DIR}"

# 기존 세션 정리(kill session)
KILL_LOG="${LOG_DIR}/gen_kill_${RUN_TS}.log"
sh gen_kill.sh > "${KILL_LOG}" 2>&1
printf "Cleaned existing generator sessions. log=%s\n" "${KILL_LOG}"

# 초기화
sh gen_init.sh

# 정기 납입
start_generator gen_0 3
sleep 15

# 추가 납입
start_generator gen_1 "$1" "$2"

# 중도 인출
start_generator gen_3 "$1" "$2"

# 펀드 변경
start_generator gen_4 "$1" "$2"

# 해약
start_generator gen_5 "$1" "$2"

# 신계약
start_generator gen_6 "$1" "$2"

# 업무 구분별 Transaction Status
start_generator gen_opstatus 720 12

# 업무 구분별 총 펀드 금액
start_generator gen_totamt 720 12

# heartbeat
#start_generator gen_heartbeat 720 12

# heartbeat period
start_generator gen_heartbp 720 12

printf "\nOSA base workload generators started.\n"
