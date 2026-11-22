set define on
set serveroutput on size unlimited
set feedback on
set verify off

--
-- Optional Chapter 18 lab:
-- Configure an OCI Generative AI profile for DBMS_CLOUD_AI.
--
-- This file is a template. Do not run it as-is.
-- Replace the values below with your own OCI tenancy/user/key values.
-- For the DBMS_CLOUD_AI OCI provider path, this means the OCI API signing key
-- values used by DBMS_CLOUD.CREATE_CREDENTIAL: user OCID, tenancy OCID,
-- private key, and fingerprint.
--
-- This optional path is not required for the key-less sample AI result lab.
--

define credential_name = 'OCI_GENAI_CRED'
define profile_name    = 'OCI_GENAI_FP_CARE'
define oci_region      = 'ap-osaka-1'

define user_ocid       = '<YOUR_OCI_USER_OCID>'
define tenancy_ocid    = '<YOUR_OCI_TENANCY_OCID>'
define fingerprint     = '<YOUR_OCI_API_KEY_FINGERPRINT>'

-- OCI private keys are usually longer than SQL*Plus DEFINE can safely handle.
-- Paste the key text between q'[ and ]' below. Do not add quotes around it.
define compartment_id  = '<YOUR_OCI_COMPARTMENT_OCID>'
define model_name      = 'meta.llama-3.3-70b-instruct'

prompt
prompt This template creates a DBMS_CLOUD credential and a DBMS_CLOUD_AI profile.
prompt It uses OCI provider credentials for DBMS_CLOUD_AI, not the key-less demo provider.
prompt

begin
  dbms_cloud.drop_credential(
    credential_name => upper('&credential_name')
  );
exception
  when others then
    if sqlcode not in (-20000, -20001) then
      null;
    end if;
end;
/

declare
  l_private_key varchar2(32767) := q'[
<YOUR_OCI_API_PRIVATE_KEY_TEXT>
]';
begin
  dbms_cloud.create_credential(
    credential_name => upper('&credential_name'),
    user_ocid       => '&user_ocid',
    tenancy_ocid    => '&tenancy_ocid',
    private_key     => l_private_key,
    fingerprint     => '&fingerprint'
  );
end;
/

begin
  dbms_cloud_ai.drop_profile(
    profile_name => upper('&profile_name')
  );
exception
  when others then
    if sqlcode not in (-20000, -20001) then
      null;
    end if;
end;
/

begin
  dbms_cloud_ai.create_profile(
    profile_name => upper('&profile_name'),
    attributes   => json_object(
      'provider'           value 'oci',
      'credential_name'    value upper('&credential_name'),
      'region'             value '&oci_region',
      'model'              value '&model_name',
      'oci_compartment_id' value '&compartment_id',
      'comments'           value 'true'
    )
  );
end;
/

begin
  dbms_cloud_ai.set_profile(upper('&profile_name'));
  dbms_output.put_line('DBMS_CLOUD_AI profile is ready: ' || upper('&profile_name'));
end;
/

prompt
prompt Smoke test:
prompt select dbms_cloud_ai.generate(
prompt          prompt       => '한국어로 한 문장만 답하세요. Oracle GoldenGate CDC 이벤트를 AI 대응 메시지로 연결합니다.',
prompt          profile_name => upper('&profile_name'),
prompt          action       => 'chat'
prompt        ) as response
prompt from dual;
prompt

exit
