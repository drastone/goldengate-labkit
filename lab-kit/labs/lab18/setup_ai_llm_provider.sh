#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_FILE="${1:-${LAB_DIR}/ai_llm_provider.conf}"
TEMPLATE_FILE="${LAB_DIR}/ai_llm_provider.conf.template"
TARGET_CONTAINER="${TARGET_CONTAINER:-demo_otrg_23ai}"
PDB_NAME="${PDB_NAME:-ORCLPDB1}"
CONFIG_SQL="${LAB_DIR}/app340/configure_churn_openai_compatible_llm.sql"
ENHANCE_SQL="${LAB_DIR}/app340/enhance_churn_llm_result_page_70_id7.sql"
CONTAINER_LAB_DIR="/home/oracle/labs/lab18"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

if [ ! -f "${CONF_FILE}" ]; then
  echo "Configuration file not found: ${CONF_FILE}"
  echo "Create it first:"
  echo "  cp ${TEMPLATE_FILE} ${CONF_FILE}"
  echo "  vi ${CONF_FILE}"
  exit 1
fi

if [ ! -f "${CONFIG_SQL}" ]; then
  fail "Missing SQL file: ${CONFIG_SQL}"
fi

if [ ! -f "${ENHANCE_SQL}" ]; then
  fail "Missing SQL file: ${ENHANCE_SQL}"
fi

# shellcheck disable=SC1090
source "${CONF_FILE}"

: "${AI_PROVIDER:?AI_PROVIDER is required in ${CONF_FILE}}"
: "${AI_BASE_URL:?AI_BASE_URL is required in ${CONF_FILE}}"
: "${AI_MODEL:?AI_MODEL is required in ${CONF_FILE}}"
: "${AI_API_KEY:?AI_API_KEY is required in ${CONF_FILE}}"

[ "${AI_PROVIDER}" = "openai_compatible" ] || fail "Only AI_PROVIDER=openai_compatible is supported by this lab."
[ "${AI_API_KEY}" != "<YOUR_PROVIDER_API_KEY>" ] || fail "Replace AI_API_KEY in ${CONF_FILE} before running this script."

AI_HOST="$(printf '%s\n' "${AI_BASE_URL}" | sed -E 's#^https?://([^/:]+).*#\1#')"
[ -n "${AI_HOST}" ] || fail "Could not parse host from AI_BASE_URL=${AI_BASE_URL}"

echo "Configure Chapter 18 real LLM provider"
echo "Container : ${TARGET_CONTAINER}"
echo "PDB       : ${PDB_NAME}"
echo "Provider  : ${AI_PROVIDER}"
echo "Endpoint  : ${AI_BASE_URL}"
echo "Host ACL  : ${AI_HOST}:443"
echo "Model     : ${AI_MODEL}"
echo "API key   : ********"
echo

docker cp "${CONFIG_SQL}" "${TARGET_CONTAINER}:/tmp/configure_churn_openai_compatible_llm.sql"
docker cp "${ENHANCE_SQL}" "${TARGET_CONTAINER}:/tmp/enhance_churn_llm_result_page_70.sql"
docker exec -u 0 "${TARGET_CONTAINER}" chmod 644 /tmp/configure_churn_openai_compatible_llm.sql
docker exec -u 0 "${TARGET_CONTAINER}" chmod 644 /tmp/enhance_churn_llm_result_page_70.sql
docker exec -u 0 "${TARGET_CONTAINER}" mkdir -p "${CONTAINER_LAB_DIR}"

for helper_sql in show_ai_llm_smoke_test.sql show_ai_llm_job_status.sql generate_ai_llm_comments.sql; do
  if [ -f "${LAB_DIR}/${helper_sql}" ]; then
    docker cp "${LAB_DIR}/${helper_sql}" "${TARGET_CONTAINER}:${CONTAINER_LAB_DIR}/${helper_sql}"
    docker exec -u 0 "${TARGET_CONTAINER}" chmod 644 "${CONTAINER_LAB_DIR}/${helper_sql}"
  fi
done

docker exec -i "${TARGET_CONTAINER}" bash -lc 'cat > /tmp/grant_ai_llm_acl.sql && sqlplus -s / as sysdba @/tmp/grant_ai_llm_acl.sql' <<SQL
alter session set container=${PDB_NAME};
set serveroutput on
begin
  dbms_network_acl_admin.append_host_ace(
    host       => '${AI_HOST}',
    lower_port => 443,
    upper_port => 443,
    ace        => xs\$ace_type(
      privilege_list => xs\$name_list('http'),
      principal_name => 'SOE',
      principal_type => xs_acl.ptype_db
    )
  );
  dbms_output.put_line('ACL added for SOE -> ${AI_HOST}:443');
exception
  when others then
    if sqlcode in (-24243, -31011) or instr(sqlerrm, 'ACE') > 0 then
      dbms_output.put_line('ACL already exists or compatible ACE is present.');
    else
      raise;
    end if;
end;
/
commit;
SQL

docker exec -i "${TARGET_CONTAINER}" bash -lc 'sqlplus -s / as sysdba' <<SQL
@/tmp/configure_churn_openai_compatible_llm.sql ${PDB_NAME} "${AI_API_KEY}" "${AI_BASE_URL}" "${AI_MODEL}"
SQL

docker exec -i "${TARGET_CONTAINER}" bash -lc \
  'sqlplus -s / as sysdba @/tmp/enhance_churn_llm_result_page_70.sql'

echo
echo "OpenAI-compatible LLM provider configured."
echo "App 340 Page 70 now includes the real external LLM comment cards."
echo "Scheduler job:"
echo "  SOE.INS2_CHURN_LLM_COMMENT_JOB runs every 1 minute."
echo "Next smoke test:"
echo "  select dbms_lob.substr(soe.ins2_churn_llm_pkg.smoke_test, 500, 1) response from dual;"
echo "Next job/status check:"
echo "  @/home/oracle/labs/lab18/show_ai_llm_job_status.sql"
