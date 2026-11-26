#!/bin/bash

set -euo pipefail

SCOPE="${1:-full}"
case "${SCOPE}" in
  full|--core-only) ;;
  *)
    echo "Usage: $0 [--core-only]" >&2
    exit 2
    ;;
esac

START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
START_SEC=$(date +%s)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "${SCRIPT_DIR}"
for seed_file in cfund_ratio.sql call_center_log_inserts.sql; do
  if [ ! -r "${seed_file}" ]; then
    echo "ERROR: missing Source seed file: ${SCRIPT_DIR}/${seed_file}" >&2
    exit 1
  fi
done
LOG_DIR=${SCRIPT_DIR}/logs
mkdir -p "${LOG_DIR}"
LOG_FILE=${LOG_DIR}/prepare_osa_source_objects_$(date '+%Y%m%d_%H%M%S').log

echo "Preparing OSA source objects..."
echo "Start time: ${START_TIME}"
echo "Log file: ${LOG_FILE}"
sqlplus -L -s soe/soe@orclpdb1 >> "${LOG_FILE}" 2>&1 << EOF
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set termout off;
set echo off;
set feedback off;
set heading off;
begin
  execute immediate 'drop table soe.fundm purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.fundm (
fund_code varchar2(20) not null primary key,
fund_name varchar2(100), 
fund_description varchar2(4000) -- 상품설명서
);

insert into soe.fundm values ('FUND0','FUNDA0 주식형펀드01','FUND0 상품설명서');
insert into soe.fundm values ('FUND1','FUNDA1 혼합형펀드01','FUND1 상품설명서');
insert into soe.fundm values ('FUND2','FUNDA2 채권형펀드01','FUND2 상품설명서');
insert into soe.fundm values ('FUND3','FUNDA3 이머징펀드01','FUND3 상품설명서');
insert into soe.fundm values ('FUND4','FUNDA4 선진국펀드01','FUND4 상품설명서');
insert into soe.fundm values ('FUND5','FUNDA5 섹터펀드01','FUND5 상품설명서');
insert into soe.fundm values ('FUND6','FUNDA6 개인연금저축펀드01','FUND6 상품설명서');
insert into soe.fundm values ('FUND7','FUNDA7 퇴직연금펀드01','FUND7 상품설명서');
insert into soe.fundm values ('FUND8','FUNDA8 TDF01','FUND8 상품설명서');
insert into soe.fundm values ('FUND9','FUNDA9 TIF01','FUND9 상품설명서');
commit;


begin
  execute immediate 'drop table soe.fund_price purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.fund_price (
dt varchar2(8),
fund_code varchar2(20) ,
price number
);

insert into soe.fund_price values ('20220101','FUND0',1000.7);
insert into soe.fund_price values ('20220101','FUND1',1019.2);
insert into soe.fund_price values ('20220101','FUND2',518.3);
insert into soe.fund_price values ('20220101','FUND3',777.5);
insert into soe.fund_price values ('20220101','FUND4',978.4);
insert into soe.fund_price values ('20220101','FUND5',649.2);
insert into soe.fund_price values ('20220101','FUND6',992);
insert into soe.fund_price values ('20220101','FUND7',940.5);
insert into soe.fund_price values ('20220101','FUND8',997.2);
insert into soe.fund_price values ('20220101','FUND9',1191.3);
insert into soe.fund_price values ('20220102','FUND0',990.7);
insert into soe.fund_price values ('20220102','FUND1',1009.2);
insert into soe.fund_price values ('20220102','FUND2',508.3);
insert into soe.fund_price values ('20220102','FUND3',767.5);
insert into soe.fund_price values ('20220102','FUND4',968.4);
insert into soe.fund_price values ('20220102','FUND5',639.2);
insert into soe.fund_price values ('20220102','FUND6',982);
insert into soe.fund_price values ('20220102','FUND7',930.5);
insert into soe.fund_price values ('20220102','FUND8',987.2);
insert into soe.fund_price values ('20220102','FUND9',1181.3);
insert into soe.fund_price values ('20220103','FUND0',980.7);
insert into soe.fund_price values ('20220103','FUND1',999.2);
insert into soe.fund_price values ('20220103','FUND2',498.3);
insert into soe.fund_price values ('20220103','FUND3',757.5);
insert into soe.fund_price values ('20220103','FUND4',958.4);
insert into soe.fund_price values ('20220103','FUND5',629.2);
insert into soe.fund_price values ('20220103','FUND6',972);
insert into soe.fund_price values ('20220103','FUND7',920.5);
insert into soe.fund_price values ('20220103','FUND8',977.2);
insert into soe.fund_price values ('20220103','FUND9',1171.3);
insert into soe.fund_price values ('20220104','FUND0',970.7);
insert into soe.fund_price values ('20220104','FUND1',989.2);
insert into soe.fund_price values ('20220104','FUND2',488.3);
insert into soe.fund_price values ('20220104','FUND3',747.5);
insert into soe.fund_price values ('20220104','FUND4',948.4);
insert into soe.fund_price values ('20220104','FUND5',619.2);
insert into soe.fund_price values ('20220104','FUND6',962);
insert into soe.fund_price values ('20220104','FUND7',910.5);
insert into soe.fund_price values ('20220104','FUND8',967.2);
insert into soe.fund_price values ('20220104','FUND9',1161.3);
insert into soe.fund_price values ('20220105','FUND0',960.7);
insert into soe.fund_price values ('20220105','FUND1',979.2);
insert into soe.fund_price values ('20220105','FUND2',478.3);
insert into soe.fund_price values ('20220105','FUND3',737.5);
insert into soe.fund_price values ('20220105','FUND4',938.4);
insert into soe.fund_price values ('20220105','FUND5',609.2);
insert into soe.fund_price values ('20220105','FUND6',952);
insert into soe.fund_price values ('20220105','FUND7',900.5);
insert into soe.fund_price values ('20220105','FUND8',957.2);
insert into soe.fund_price values ('20220105','FUND9',1151.3);
insert into soe.fund_price values ('20220106','FUND0',950.7);
insert into soe.fund_price values ('20220106','FUND1',969.2);
insert into soe.fund_price values ('20220106','FUND2',468.3);
insert into soe.fund_price values ('20220106','FUND3',727.5);
insert into soe.fund_price values ('20220106','FUND4',928.4);
insert into soe.fund_price values ('20220106','FUND5',599.2);
insert into soe.fund_price values ('20220106','FUND6',942);
insert into soe.fund_price values ('20220106','FUND7',890.5);
insert into soe.fund_price values ('20220106','FUND8',947.2);
insert into soe.fund_price values ('20220106','FUND9',1141.3);
insert into soe.fund_price values ('20220107','FUND0',940.7);
insert into soe.fund_price values ('20220107','FUND1',959.2);
insert into soe.fund_price values ('20220107','FUND2',458.3);
insert into soe.fund_price values ('20220107','FUND3',717.5);
insert into soe.fund_price values ('20220107','FUND4',918.4);
insert into soe.fund_price values ('20220107','FUND5',589.2);
insert into soe.fund_price values ('20220107','FUND6',932);
insert into soe.fund_price values ('20220107','FUND7',880.5);
insert into soe.fund_price values ('20220107','FUND8',937.2);
insert into soe.fund_price values ('20220107','FUND9',1131.3);
insert into soe.fund_price values ('20220108','FUND0',930.7);
insert into soe.fund_price values ('20220108','FUND1',949.2);
insert into soe.fund_price values ('20220108','FUND2',448.3);
insert into soe.fund_price values ('20220108','FUND3',707.5);
insert into soe.fund_price values ('20220108','FUND4',908.4);
insert into soe.fund_price values ('20220108','FUND5',579.2);
insert into soe.fund_price values ('20220108','FUND6',922);
insert into soe.fund_price values ('20220108','FUND7',870.5);
insert into soe.fund_price values ('20220108','FUND8',927.2);
insert into soe.fund_price values ('20220108','FUND9',1121.3);
insert into soe.fund_price values ('20220109','FUND0',920.7);
insert into soe.fund_price values ('20220109','FUND1',939.2);
insert into soe.fund_price values ('20220109','FUND2',438.3);
insert into soe.fund_price values ('20220109','FUND3',697.5);
insert into soe.fund_price values ('20220109','FUND4',898.4);
insert into soe.fund_price values ('20220109','FUND5',569.2);
insert into soe.fund_price values ('20220109','FUND6',912);
insert into soe.fund_price values ('20220109','FUND7',860.5);
insert into soe.fund_price values ('20220109','FUND8',917.2);
insert into soe.fund_price values ('20220109','FUND9',1111.3);
insert into soe.fund_price values ('20220110','FUND0',910.7);
insert into soe.fund_price values ('20220110','FUND1',929.2);
insert into soe.fund_price values ('20220110','FUND2',428.3);
insert into soe.fund_price values ('20220110','FUND3',687.5);
insert into soe.fund_price values ('20220110','FUND4',888.4);
insert into soe.fund_price values ('20220110','FUND5',559.2);
insert into soe.fund_price values ('20220110','FUND6',902);
insert into soe.fund_price values ('20220110','FUND7',850.5);
insert into soe.fund_price values ('20220110','FUND8',907.2);
insert into soe.fund_price values ('20220110','FUND9',1101.3);
insert into soe.fund_price values ('20220111','FUND0',999.8);
insert into soe.fund_price values ('20220111','FUND1',1018.3);
insert into soe.fund_price values ('20220111','FUND2',517.4);
insert into soe.fund_price values ('20220111','FUND3',776.6);
insert into soe.fund_price values ('20220111','FUND4',977.5);
insert into soe.fund_price values ('20220111','FUND5',648.3);
insert into soe.fund_price values ('20220111','FUND6',991.1);
insert into soe.fund_price values ('20220111','FUND7',939.6);
insert into soe.fund_price values ('20220111','FUND8',996.3);
insert into soe.fund_price values ('20220111','FUND9',1190.4);
insert into soe.fund_price values ('20220112','FUND0',989.8);
insert into soe.fund_price values ('20220112','FUND1',1008.3);
insert into soe.fund_price values ('20220112','FUND2',507.4);
insert into soe.fund_price values ('20220112','FUND3',766.6);
insert into soe.fund_price values ('20220112','FUND4',967.5);
insert into soe.fund_price values ('20220112','FUND5',638.3);
insert into soe.fund_price values ('20220112','FUND6',981.1);
insert into soe.fund_price values ('20220112','FUND7',929.6);
insert into soe.fund_price values ('20220112','FUND8',986.3);
insert into soe.fund_price values ('20220112','FUND9',1180.4);
insert into soe.fund_price values ('20220113','FUND0',979.8);
insert into soe.fund_price values ('20220113','FUND1',998.3);
insert into soe.fund_price values ('20220113','FUND2',497.4);
insert into soe.fund_price values ('20220113','FUND3',756.6);
insert into soe.fund_price values ('20220113','FUND4',957.5);
insert into soe.fund_price values ('20220113','FUND5',628.3);
insert into soe.fund_price values ('20220113','FUND6',971.1);
insert into soe.fund_price values ('20220113','FUND7',919.6);
insert into soe.fund_price values ('20220113','FUND8',976.3);
insert into soe.fund_price values ('20220113','FUND9',1170.4);
insert into soe.fund_price values ('20220114','FUND0',969.8);
insert into soe.fund_price values ('20220114','FUND1',988.3);
insert into soe.fund_price values ('20220114','FUND2',487.4);
insert into soe.fund_price values ('20220114','FUND3',746.6);
insert into soe.fund_price values ('20220114','FUND4',947.5);
insert into soe.fund_price values ('20220114','FUND5',618.3);
insert into soe.fund_price values ('20220114','FUND6',961.1);
insert into soe.fund_price values ('20220114','FUND7',909.6);
insert into soe.fund_price values ('20220114','FUND8',966.3);
insert into soe.fund_price values ('20220114','FUND9',1160.4);
insert into soe.fund_price values ('20220115','FUND0',959.8);
insert into soe.fund_price values ('20220115','FUND1',978.3);
insert into soe.fund_price values ('20220115','FUND2',477.4);
insert into soe.fund_price values ('20220115','FUND3',736.6);
insert into soe.fund_price values ('20220115','FUND4',937.5);
insert into soe.fund_price values ('20220115','FUND5',608.3);
insert into soe.fund_price values ('20220115','FUND6',951.1);
insert into soe.fund_price values ('20220115','FUND7',899.6);
insert into soe.fund_price values ('20220115','FUND8',956.3);
insert into soe.fund_price values ('20220115','FUND9',1150.4);
insert into soe.fund_price values ('20220116','FUND0',949.8);
insert into soe.fund_price values ('20220116','FUND1',968.3);
insert into soe.fund_price values ('20220116','FUND2',467.4);
insert into soe.fund_price values ('20220116','FUND3',726.6);
insert into soe.fund_price values ('20220116','FUND4',927.5);
insert into soe.fund_price values ('20220116','FUND5',598.3);
insert into soe.fund_price values ('20220116','FUND6',941.1);
insert into soe.fund_price values ('20220116','FUND7',889.6);
insert into soe.fund_price values ('20220116','FUND8',946.3);
insert into soe.fund_price values ('20220116','FUND9',1140.4);
insert into soe.fund_price values ('20220117','FUND0',939.8);
insert into soe.fund_price values ('20220117','FUND1',958.3);
insert into soe.fund_price values ('20220117','FUND2',457.4);
insert into soe.fund_price values ('20220117','FUND3',716.6);
insert into soe.fund_price values ('20220117','FUND4',917.5);
insert into soe.fund_price values ('20220117','FUND5',588.3);
insert into soe.fund_price values ('20220117','FUND6',931.1);
insert into soe.fund_price values ('20220117','FUND7',879.6);
insert into soe.fund_price values ('20220117','FUND8',936.3);
insert into soe.fund_price values ('20220117','FUND9',1130.4);
insert into soe.fund_price values ('20220118','FUND0',929.8);
insert into soe.fund_price values ('20220118','FUND1',948.3);
insert into soe.fund_price values ('20220118','FUND2',447.4);
insert into soe.fund_price values ('20220118','FUND3',706.6);
insert into soe.fund_price values ('20220118','FUND4',907.5);
insert into soe.fund_price values ('20220118','FUND5',578.3);
insert into soe.fund_price values ('20220118','FUND6',921.1);
insert into soe.fund_price values ('20220118','FUND7',869.6);
insert into soe.fund_price values ('20220118','FUND8',926.3);
insert into soe.fund_price values ('20220118','FUND9',1120.4);
insert into soe.fund_price values ('20220119','FUND0',919.8);
insert into soe.fund_price values ('20220119','FUND1',938.3);
insert into soe.fund_price values ('20220119','FUND2',437.4);
insert into soe.fund_price values ('20220119','FUND3',696.6);
insert into soe.fund_price values ('20220119','FUND4',897.5);
insert into soe.fund_price values ('20220119','FUND5',568.3);
insert into soe.fund_price values ('20220119','FUND6',911.1);
insert into soe.fund_price values ('20220119','FUND7',859.6);
insert into soe.fund_price values ('20220119','FUND8',916.3);
insert into soe.fund_price values ('20220119','FUND9',1110.4);
insert into soe.fund_price values ('20220120','FUND0',909.8);
insert into soe.fund_price values ('20220120','FUND1',928.3);
insert into soe.fund_price values ('20220120','FUND2',427.4);
insert into soe.fund_price values ('20220120','FUND3',686.6);
insert into soe.fund_price values ('20220120','FUND4',887.5);
insert into soe.fund_price values ('20220120','FUND5',558.3);
insert into soe.fund_price values ('20220120','FUND6',901.1);
insert into soe.fund_price values ('20220120','FUND7',849.6);
insert into soe.fund_price values ('20220120','FUND8',906.3);
insert into soe.fund_price values ('20220120','FUND9',1100.4);
insert into soe.fund_price values ('20220121','FUND0',1001.1);
insert into soe.fund_price values ('20220121','FUND1',1019.6);
insert into soe.fund_price values ('20220121','FUND2',518.7);
insert into soe.fund_price values ('20220121','FUND3',777.9);
insert into soe.fund_price values ('20220121','FUND4',978.8);
insert into soe.fund_price values ('20220121','FUND5',649.6);
insert into soe.fund_price values ('20220121','FUND6',992.4);
insert into soe.fund_price values ('20220121','FUND7',940.9);
insert into soe.fund_price values ('20220121','FUND8',997.6);
insert into soe.fund_price values ('20220121','FUND9',1191.7);
insert into soe.fund_price values ('20220122','FUND0',991.1);
insert into soe.fund_price values ('20220122','FUND1',1009.6);
insert into soe.fund_price values ('20220122','FUND2',508.7);
insert into soe.fund_price values ('20220122','FUND3',767.9);
insert into soe.fund_price values ('20220122','FUND4',968.8);
insert into soe.fund_price values ('20220122','FUND5',639.6);
insert into soe.fund_price values ('20220122','FUND6',982.4);
insert into soe.fund_price values ('20220122','FUND7',930.9);
insert into soe.fund_price values ('20220122','FUND8',987.6);
insert into soe.fund_price values ('20220122','FUND9',1181.7);
insert into soe.fund_price values ('20220123','FUND0',981.1);
insert into soe.fund_price values ('20220123','FUND1',999.6);
insert into soe.fund_price values ('20220123','FUND2',498.7);
insert into soe.fund_price values ('20220123','FUND3',757.9);
insert into soe.fund_price values ('20220123','FUND4',958.8);
insert into soe.fund_price values ('20220123','FUND5',629.6);
insert into soe.fund_price values ('20220123','FUND6',972.4);
insert into soe.fund_price values ('20220123','FUND7',920.9);
insert into soe.fund_price values ('20220123','FUND8',977.6);
insert into soe.fund_price values ('20220123','FUND9',1171.7);
insert into soe.fund_price values ('20220124','FUND0',971.1);
insert into soe.fund_price values ('20220124','FUND1',989.6);
insert into soe.fund_price values ('20220124','FUND2',488.7);
insert into soe.fund_price values ('20220124','FUND3',747.9);
insert into soe.fund_price values ('20220124','FUND4',948.8);
insert into soe.fund_price values ('20220124','FUND5',619.6);
insert into soe.fund_price values ('20220124','FUND6',962.4);
insert into soe.fund_price values ('20220124','FUND7',910.9);
insert into soe.fund_price values ('20220124','FUND8',967.6);
insert into soe.fund_price values ('20220124','FUND9',1161.7);
insert into soe.fund_price values ('20220125','FUND0',961.1);
insert into soe.fund_price values ('20220125','FUND1',979.6);
insert into soe.fund_price values ('20220125','FUND2',478.7);
insert into soe.fund_price values ('20220125','FUND3',737.9);
insert into soe.fund_price values ('20220125','FUND4',938.8);
insert into soe.fund_price values ('20220125','FUND5',609.6);
insert into soe.fund_price values ('20220125','FUND6',952.4);
insert into soe.fund_price values ('20220125','FUND7',900.9);
insert into soe.fund_price values ('20220125','FUND8',957.6);
insert into soe.fund_price values ('20220125','FUND9',1151.7);
insert into soe.fund_price values ('20220126','FUND0',951.1);
insert into soe.fund_price values ('20220126','FUND1',969.6);
insert into soe.fund_price values ('20220126','FUND2',468.7);
insert into soe.fund_price values ('20220126','FUND3',727.9);
insert into soe.fund_price values ('20220126','FUND4',928.8);
insert into soe.fund_price values ('20220126','FUND5',599.6);
insert into soe.fund_price values ('20220126','FUND6',942.4);
insert into soe.fund_price values ('20220126','FUND7',890.9);
insert into soe.fund_price values ('20220126','FUND8',947.6);
insert into soe.fund_price values ('20220126','FUND9',1141.7);
insert into soe.fund_price values ('20220127','FUND0',941.1);
insert into soe.fund_price values ('20220127','FUND1',959.6);
insert into soe.fund_price values ('20220127','FUND2',458.7);
insert into soe.fund_price values ('20220127','FUND3',717.9);
insert into soe.fund_price values ('20220127','FUND4',918.8);
insert into soe.fund_price values ('20220127','FUND5',589.6);
insert into soe.fund_price values ('20220127','FUND6',932.4);
insert into soe.fund_price values ('20220127','FUND7',880.9);
insert into soe.fund_price values ('20220127','FUND8',937.6);
insert into soe.fund_price values ('20220127','FUND9',1131.7);
insert into soe.fund_price values ('20220128','FUND0',931.1);
insert into soe.fund_price values ('20220128','FUND1',949.6);
insert into soe.fund_price values ('20220128','FUND2',448.7);
insert into soe.fund_price values ('20220128','FUND3',707.9);
insert into soe.fund_price values ('20220128','FUND4',908.8);
insert into soe.fund_price values ('20220128','FUND5',579.6);
insert into soe.fund_price values ('20220128','FUND6',922.4);
insert into soe.fund_price values ('20220128','FUND7',870.9);
insert into soe.fund_price values ('20220128','FUND8',927.6);
insert into soe.fund_price values ('20220128','FUND9',1121.7);
insert into soe.fund_price values ('20220129','FUND0',921.1);
insert into soe.fund_price values ('20220129','FUND1',939.6);
insert into soe.fund_price values ('20220129','FUND2',438.7);
insert into soe.fund_price values ('20220129','FUND3',697.9);
insert into soe.fund_price values ('20220129','FUND4',898.8);
insert into soe.fund_price values ('20220129','FUND5',569.6);
insert into soe.fund_price values ('20220129','FUND6',912.4);
insert into soe.fund_price values ('20220129','FUND7',860.9);
insert into soe.fund_price values ('20220129','FUND8',917.6);
insert into soe.fund_price values ('20220129','FUND9',1111.7);
insert into soe.fund_price values ('20220130','FUND0',911.1);
insert into soe.fund_price values ('20220130','FUND1',929.6);
insert into soe.fund_price values ('20220130','FUND2',428.7);
insert into soe.fund_price values ('20220130','FUND3',687.9);
insert into soe.fund_price values ('20220130','FUND4',888.8);
insert into soe.fund_price values ('20220130','FUND5',559.6);
insert into soe.fund_price values ('20220130','FUND6',902.4);
insert into soe.fund_price values ('20220130','FUND7',850.9);
insert into soe.fund_price values ('20220130','FUND8',907.6);
insert into soe.fund_price values ('20220130','FUND9',1101.7);
insert into soe.fund_price values ('20220131','FUND0',731.1);
insert into soe.fund_price values ('20220131','FUND1',899.6);
insert into soe.fund_price values ('20220131','FUND2',528.7);
insert into soe.fund_price values ('20220131','FUND3',787.9);
insert into soe.fund_price values ('20220131','FUND4',738.8);
insert into soe.fund_price values ('20220131','FUND5',669.6);
insert into soe.fund_price values ('20220131','FUND6',982.4);
insert into soe.fund_price values ('20220131','FUND7',890.9);
insert into soe.fund_price values ('20220131','FUND8',987.6);
insert into soe.fund_price values ('20220131','FUND9',1201.7);

commit;

--1월 데이터 해당년도로 update
update soe.fund_price
set dt = to_char(sysdate,'YYYY') || substr(dt,5,4)
;
commit;


declare 
    k number;
begin 
    k:= 1;
	
	-- 올해 1년치
    for i in 1..11 loop
        insert into soe.fund_price
        select to_char(add_months(to_date(dt,'YYYYMMDD'),i),'YYYYMMDD'),fund_code,price + i*20 - TRUNC(DBMS_RANDOM.VALUE(10,250))/10
        from soe.fund_price
        where substr(dt,1,6) = to_char(sysdate,'YYYY') || '01'
        ;
    end loop;
	
	-- 과거 5년치
    for i in 1..60 loop
        insert into soe.fund_price
        select to_char(add_months(to_date(dt,'YYYYMMDD'),-i),'YYYYMMDD'),fund_code,price - i*10 - TRUNC(DBMS_RANDOM.VALUE(10,250))/10
        from soe.fund_price
        where substr(dt,1,6) = to_char(sysdate,'YYYY') || '01'
        ;
    end loop; 	
    commit;
end;
/
 
--중복데이터 제거 
DELETE 
FROM soe.fund_price
WHERE ROWID IN (
    SELECT ROWID FROM (
        SELECT * FROM (
            SELECT ROW_NUMBER() OVER(PARTITION BY dt,fund_code ORDER BY dt,fund_code) AS num
            FROM soe.fund_price
        )
        WHERE num > 1 
    )
);

commit;

--향후 10년치 데이터 생성
declare 
    vs_year number;
begin
    select to_char(sysdate,'YYYY') vs_year into vs_year from dual;
    
    for i in 1..10 loop
        vs_year := vs_year + 1;
        insert into soe.fund_price select vs_year || substr(dt,5,4), fund_code, price 
        from soe.fund_price 
        where substr(dt,1,4) = to_char(sysdate,'YYYY')
        ;
        
    end loop;
end;
/

alter table soe.fund_price add constraint fundp_pk primary key (dt,fund_code);
EOF
sqlplus -L -s soe/soe@orclpdb1 >> "${LOG_FILE}" 2>&1 << EOF
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set term off;
set feedback off;
@cfund_ratio.sql
EOF
sqlplus -L -s soe/soe@orclpdb1 >> "${LOG_FILE}" 2>&1 << EOF
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback
set term off;
set feedback off;
-- ##### 고객별 fund 투입비율 설정 마스터 테이블
begin
  execute immediate 'drop table soe.cfund_rat purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cfund_rat (
cust_id number,
fund_code varchar2(20),
fund_rat number,
dt varchar2(14),      -- 펀드 변경이 일어난 경우 이력 관리
chg_gubun varchar2(5), -- 펀드 변경이 일어난 경우 'Y' flag로 생성됨
inum number,
cancel_yn varchar2(2)
);



insert into soe.cfund_rat 
select cust_id, fund_code1,fund_rat1,to_char(sysdate-1,'YYYYMMDDHH24MISS'),'N',0,'N'
from soe.cfund_ratio
where fund_code1 is not null
union all
select cust_id, fund_code2,fund_rat2,to_char(sysdate-1,'YYYYMMDDHH24MISS'),'N',0,'N'
from soe.cfund_ratio
where fund_code2 is not null
;
commit;

alter table soe.cfund_rat add constraint cfund_rat primary key (cust_id,fund_code,fund_rat,dt);


begin
  execute immediate 'drop table SOE.ADDRESS purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table SOE.ADDRESS 
(	
CUST_ID NUMBER, 
FP_ID NUMBER,
CATEGORY VARCHAR2(20 BYTE), 
GUNMUL VARCHAR2(50 BYTE), 
JUNGDON VARCHAR2(20 BYTE), 
JUSO VARCHAR2(60 BYTE), 
CNT NUMBER, 
LAT NUMBER, 
LON NUMBER
) ;

alter table SOE.ADDRESS add constraint address_pk primary key (cust_id);


commit;


-- ##### 고객별 월별 납입금액 설정 마스터
begin
  execute immediate 'drop table soe.cfund_deposit purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cfund_deposit (
cust_id number,
deposit_date varchar2(8),
deposit_amt number,
deposit_cnt number,
silhyo_yn varchar2(10),
non_deposit_cnt number);

insert into soe.cfund_deposit
select cust_id, 
    deposit_date,
    deposit_amt,
    deposit_cnt,
    silhyo_yn,
    case when silhyo_base <= 20 then 1
         when silhyo_base > 20 and silhyo_base <= 25 then 2
         else 0 end as non_deposit_cnt
from
(
    select cust_id,
        to_char(sysdate,'YYYYMMDD') deposit_date,
        ROUND(TRUNC(DBMS_RANDOM.VALUE(10,250))/100,1)*100 *10000 deposit_amt,
        TRUNC(DBMS_RANDOM.VALUE(10,100)) deposit_cnt,
        'N' silhyo_yn,
        TRUNC(DBMS_RANDOM.VALUE(10,100)) silhyo_base,
        0 non_deposit_cnt --TRUNC(DBMS_RANDOM.VALUE(1,2))
    from soe.cfund_ratio
)
;

commit;

alter table soe.cfund_deposit add constraint cfund_deposit primary key (cust_id);


--##### 적립금 배치용 (잔고 좌수를 확인하여 중도인출 가능한 범위인지 확인할 수 있음) 
begin
  execute immediate 'drop table soe.reserves_amt purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.reserves_amt (
dt varchar2(8),
cust_id number,
fund_code varchar2(20),
fund_name varchar2(50),
op_gubun varchar2(5),
fund_cnt number,
fund_price number,
tot_cnt number,
tot_amt number
);
alter table soe.reserves_amt add constraint reserves_amt_pk primary key (dt,cust_id,fund_code,op_gubun);

--## OpGubun master 
begin
  execute immediate 'drop table soe.opm purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.opm (
op_gubun varchar2(5),
op_name varchar2(20)
);

insert into soe.opm values ('0','신규계약');
insert into soe.opm values ('1','정기납입');
insert into soe.opm values ('2','추가납입');
insert into soe.opm values ('3','중도인출');
insert into soe.opm values ('4','펀드변경');
insert into soe.opm values ('5','해약');
commit;

alter table soe.opm add constraint opm_pk primary key (op_gubun);


-- ## OpGubun 별 transaction 현황
begin
  execute immediate 'drop table soe.OpStatus purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.OpStatus (
op_gubun varchar2(5),
op_name varchar2(30),
op_cnt number );

alter table soe.OpStatus add constraint OpStatusPk primary key (op_gubun);



begin
  execute immediate 'drop table soe.tot_amt purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.tot_amt (
op_gubun varchar2(10),
gubun varchar2(20),
heartbt varchar2(20),
tot_amt number,
start_dt varchar2(30));
alter table soe.tot_amt add constraint tot_amt_pk primary key (op_gubun,gubun);


begin
  execute immediate 'drop table soe.cancelamt purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cancelamt (
dt varchar2(8),
cust_id number,
op_gubun varchar2(10),
tot_amt varchar2(20),
start_dt varchar2(30), 
cnt number,  
call_dt varchar2(8),
call_dt_ts varchar2(30), 
log_id varchar2(20),  
fund_code varchar2(20), 
fund_name varchar2(30), 
call_cnt_3m number,  
late_pmt_cnt number,  
consult_text varchar2(200)
);
alter table soe.cancelamt add constraint cancelamt_pk primary key (dt,cust_id,op_gubun,call_dt,log_id);

begin
  execute immediate 'drop table soe.cust_gen_amt purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cust_gen_amt (
dt varchar2(8),
cust_id number,
op_gubun varchar2(10),
tot_amt number,
start_dt varchar2(30),
cnt number,
call_dt varchar2(8),
call_dt_ts varchar2(30),
log_id varchar2(20),
fund_code varchar2(20),
fund_name varchar2(30),
call_cnt_3m number,
late_pmt_cnt number,
consult_text varchar2(200)
);
alter table soe.cust_gen_amt add constraint cust_gen_amt_pk primary key (dt,cust_id,op_gubun,call_dt,log_id);


begin
  execute immediate 'drop table soe.heartbp purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.heartbp (
dt varchar2(8),
keys number,
period_start varchar2(15),
start_dt varchar2(30))
;
alter table soe.heartbp add constraint heartbp_pk primary key (dt,keys);

begin
  execute immediate 'drop table soe.employee purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.employee (
	id number not null primary key,
	name varchar2(100),
	email varchar2(100),
	age number,
	phonenumber varchar2(20),
	designation varchar2(100),
	created date
);

insert into soe.employee values (1, 'Alicia','Alicia@gmail.com',31,'010-1024-2706','FP',sysdate);
insert into soe.employee values (2, 'Sienna','Sienna@gmail.com',32,'010-1324-2605','FP',sysdate);
insert into soe.employee values (3, 'Marcie','Marcie@gmail.com',33,'010-1024-2665','FP',sysdate);
insert into soe.employee values (4, 'Hyobin','Hyobin@gmail.com',34,'010-3424-2786','FP',sysdate);
insert into soe.employee values (5, 'Eileen','Eileen@gmail.com',35,'010-1824-2345','FP',sysdate);
insert into soe.employee values (6, 'Lucien','Lucien@gmail.com',36,'010-1624-2605','FP',sysdate);
insert into soe.employee values (7, 'Selena','Selena@gmail.com',37,'010-9024-1776','FP',sysdate);
insert into soe.employee values (8, 'Hyejin','Hyejin@gmail.com',38,'010-1067-2675','FP',sysdate);
insert into soe.employee values (9, 'Sandra','Sandra@gmail.com',39,'010-1028-2675','FP',sysdate);
insert into soe.employee values (10,'Yeonju','Yeonju@gmail.com',31,'010-1023-2676','FP',sysdate);
insert into soe.employee values (11,'Esther','Esther@gmail.com',32,'010-1043-2675','FP',sysdate);
insert into soe.employee values (12,'Margad','Margad@gmail.com',33,'010-1020-1706','FP',sysdate);
insert into soe.employee values (13,'Vivian','Vivian@gmail.com',34,'010-1054-2675','FP',sysdate);
insert into soe.employee values (14,'Selina','Selina@gmail.com',35,'010-1424-1606','FP',sysdate);
insert into soe.employee values (15,'Serena','Serena@gmail.com',36,'010-1524-2705','FP',sysdate);
insert into soe.employee values (16,'Ashley','Ashley@gmail.com',37,'010-1026-1675','FP',sysdate);
insert into soe.employee values (17,'Janice','Janice@gmail.com',38,'010-1028-2704','FP',sysdate);

commit;

--##### target only
begin
  execute immediate 'drop table soe.cancelfp purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cancelfp (
	start_dt varchar2(30) ,
	cust_id number,
	tot_amt varchar2(20),
	FP_ID NUMBER,
	phonenumber varchar2(20),
	CATEGORY VARCHAR2(20 BYTE), 
	GUNMUL VARCHAR2(50 BYTE), 
	JUNGDON VARCHAR2(20 BYTE), 
	JUSO VARCHAR2(60 BYTE),
	SMS VARCHAR2(100)
);

alter table soe.cancelfp add constraint cancelfp_pk primary key (start_dt,cust_id);



--##### job 관리 테이블
begin
  execute immediate 'drop table soe.msg purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
Create table soe.msg (job_name varchar2(30), start_dt varchar2(30), end_dt varchar2(30),finished varchar2(5));

--####### CDC BMT 측정용도
--Source, Target 양쪽 모두
begin
  execute immediate 'drop table soe.CFUND_DT purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.CFUND_DT (
dt varchar2(8),
keys number, 
cust_id number,
fund_code varchar2(20), -- 펀드 코드
fund_name varchar2(100),
fund_price varchar2(20), -- 펀드 당일 기준가
fund_cnt number, -- 펀드 보유 좌수
fund_amt number, -- 펀드 당일 평가액
fund_description clob, -- 펀드 상품 설명서 
op_gubun varchar2(5), -- op 구분, 1 : 입금, 2: 해약, 3: 중도인출
op_gubun2 varchar2(5),
cnt number,
start_dt varchar2(30));

--Source, Target 양쪽 모두
alter table soe.CFUND_DT add constraint CFUND_DT_pk primary key (dt,keys,cust_id,op_gubun);


begin
  execute immediate 'drop table soe.cust_info purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cust_info (
CUST_ID  NUMBER                   ,
CUST_NM           VARCHAR2(100)   ,
JUMIN_NO          VARCHAR2(100)   ,
GENDER            VARCHAR2(10)    ,
AGE               NUMBER          ,
EDU               VARCHAR2(100)   ,
JOB               VARCHAR2(100)   ,
child             number          ,
created           varchar2(8)     ,
EMAIL             VARCHAR2(200)   ,
HP_NO             VARCHAR2(100)   ,
GUNMUL            VARCHAR2(200)   ,
JUNGDONG          VARCHAR2(200)   ,
JUSO              VARCHAR2(200)   ,
LAT               NUMBER          ,
LON               NUMBER          )
;

alter table soe.cust_info add constraint cust_info_pk primary key (cust_id);



begin
  execute immediate 'drop table soe.product purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.product (
category varchar2(100),
product_code varchar2(200),
product varchar2(200),
des varchar2(1000),
gubun varchar2(10),
gubun2 varchar2(100),
resciss1 varchar2(5),
resciss2 varchar2(5),
resciss3 varchar2(5),
resciss4 varchar2(5),
resciss5 varchar2(5),
resciss6 varchar2(5),
resciss7 varchar2(5),
resciss8 varchar2(5),
resv1 varchar2(10),
resv2  varchar2(10),
resv3  varchar2(10),
resv4  varchar2(10),
resv5  varchar2(10),
resv6  varchar2(10),
resv7  varchar2(10),
resv8 varchar2(10),
resv9  varchar2(10),
resv10  varchar2(10),
images varchar2(100),
created varchar2(8)
);

alter table soe.product add constraints product_pk primary key (category,product_code,product);

comment on column soe.product.resv1  is '계약체결비용10년이내_매월	   ';
comment on column soe.product.resv2  is '계약체결비용10년이후_매월	   ';
comment on column soe.product.resv3  is '계약관리비용납입기간이내_매월'	;
comment on column soe.product.resv4  is '계약관리비용납입기간이후_매월'	;
comment on column soe.product.resv5  is '위험보혐료_매월	           ';
comment on column soe.product.resv6  is '특별계정운용보수_연	       ';
comment on column soe.product.resv7  is '기타비용_연	               ';
comment on column soe.product.resv8  is '기초펀드보수지용_연	       ';
comment on column soe.product.resv9  is '최저사망지급금_연	       ';
comment on column soe.product.resv10 is '사망보험금비율_연           ';


begin
  execute immediate 'drop table soe.cust_pr purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cust_pr (
cust_id number,
stock_no number,
seq_no number,
product_code varchar2(200),
product varchar2(200),
amt number,
rat number,
debenefit number,
payment_date varchar2(8),
overdue number,
overdue_resc number,
silhyo_cnt number,
status varchar2(100),
created varchar2(8),
modified varchar2(8)
);
alter table soe.cust_pr add constraint cust_pr_pk primary key (cust_id, stock_no,seq_no);

comment on column soe.cust_pr.overdue is '총 연체 횟수	   ';
comment on column soe.cust_pr.overdue_resc is '최근 연속 연체 횟수	   ';
comment on column soe.cust_pr.silhyo_cnt is '실효 횟수	   ';


begin
  execute immediate 'drop table soe.cust_dep_dt purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cust_dep_dt (
dt varchar2(8),
cust_id number,
stock_no number,
seq_no number,
product_code varchar2(200),
product varchar2(200),
amt number,
payment_date varchar2(8),
status varchar2(100)
);
alter table soe.cust_dep_dt add constraint cust_dep_dt_pk primary key (dt,cust_id, stock_no,seq_no);

comment on table soe.cust_dep_dt is '고객 납입 내역 ';

begin
  execute immediate 'drop table soe.cfund_rat_tmp purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.cfund_rat_tmp (
cust_id number,
fund_code varchar2(200),
fund_name varchar2(200),
before number,
after number);


begin
  execute immediate 'drop table soe.product purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
create table soe.product (
category varchar2(100),
product_code varchar2(200),
product varchar2(200),
des varchar2(1000),
gubun varchar2(10),
gubun2 varchar2(100),
resciss1 varchar2(5),
resciss2 varchar2(5),
resciss3 varchar2(5),
resciss4 varchar2(5),
resciss5 varchar2(5),
resciss6 varchar2(5),
resciss7 varchar2(5),
resciss8 varchar2(5),
resv1 varchar2(10),
resv2  varchar2(10),
resv3  varchar2(10),
resv4  varchar2(10),
resv5  varchar2(10),
resv6  varchar2(10),
resv7  varchar2(10),
resv8 varchar2(10),
resv9  varchar2(10),
resv10  varchar2(10),
images varchar2(100),
created varchar2(8)
);

alter table soe.product add constraints product_pk primary key (category,product_code,product);

comment on column soe.product.resv1  is '계약체결비용10년이내_매월	   ';
comment on column soe.product.resv2  is '계약체결비용10년이후_매월	   ';
comment on column soe.product.resv3  is '계약관리비용납입기간이내_매월'	;
comment on column soe.product.resv4  is '계약관리비용납입기간이후_매월'	;
comment on column soe.product.resv5  is '위험보혐료_매월	           ';
comment on column soe.product.resv6  is '특별계정운용보수_연	       ';
comment on column soe.product.resv7  is '기타비용_연	               ';
comment on column soe.product.resv8  is '기초펀드보수지용_연	       ';
comment on column soe.product.resv9  is '최저사망지급금_연	       ';
comment on column soe.product.resv10 is '사망보험금비율_연           ';



insert into soe.product values ('종신보험','A01','(무) 100년 더 드림 플러스 유니버셜 간편종신보험(보증비용부과형)(2404)','우리가족 행복파트너!','D','','','','','','','','','','','','','','','','','','','','product/p01.jpg','19991220');
insert into soe.product values ('종신보험','A02','(무) 100년 더 드림 플러스 유니버셜 종신보험(보증비용부과형)(2404)','나와 내 가족을 위한 종신보험!','D','','','','','','','','','','','','','','','','','','','','product/p02.jpg','19991220');
insert into soe.product values ('종신보험','A03','(무) 간편한(365) 뉴-암종신보험(2404)','하나의 상품으로 사망보장과 암진단자금을 동시에!','D','','','','','','','','','','','','','','','','','','','','product/p03.jpg','19991220');
insert into soe.product values ('종신보험','A04','(무) 간편한(365) 뉴-올케어 암종신보험(해약환급금 일부지급형)(2408)','3가지 간편심사 고지항목으로 간편하게 가입 OK!','D','','','','','','','','','','','','','','','','','','','','product/p04.jpg','19991220');
insert into soe.product values ('종신보험','A05','(무) 뉴-암종신보험(2404)','납입완료보너스 가산','D','','','','','','','','','','','','','','','','','','','','product/p05.jpg','19991220');
insert into soe.product values ('종신보험','A06','(무) 뉴케어 암종신보험(해약환급금 일부지급형)(2408)','나와 내가족을 위해 사망보장과 암진단자금을 한번에 준비하세요!','D','','','','','','','','','','','','','','','','','','','','product/p06.jpg','19991220');
insert into soe.product values ('종신보험','A07','(무) 천년친구 700 종신보험(해약환급금 일부지급형III)(2403)','평생 지켜주고 싶은 가족을 위해','D','','','','','','','','','','','','','','','','','','','','product/p07.jpg','19991220');
insert into soe.product values ('종신보험','A08','(무) 천년친구 713 종신보험(해약환급금 일부지급형Ⅲ)(2410)','나와 내 가족을 위해 준비하는 든든한 보장자산!','D','','','','','','','','','','','','','','','','','','','','product/p08.jpg','19991220');
insert into soe.product values ('종신보험','A09','(무) 천년친구 간편한 700 종신보험 (해약환급금 일부지급형Ⅲ)(2404)','평생 지켜주고 싶은 가족을 위해','D','','','','','','','','','','','','','','','','','','','','product/p09.jpg','19991220');
insert into soe.product values ('종신보험','A10','(무) 천년친구 간편한 713 종신보험(해약환급금 일부지급형Ⅲ)(2411)','나와 내 가족을 위해 준비하는 든든한 보장자산!','D','','','','','','','','','','','','','','','','','','','','product/p10.jpg','19991220');
insert into soe.product values ('종신보험','A11','(무) 천년친구 뉴-알차고 행복한 Plus 종신보험(해약환급금일부지급형)(2412)','우리가족 행복파트너!','D','','','','','','','','','','','','','','','','','','','','product/p11.jpg','19991220');
insert into soe.product values ('종신보험','A12','(무)DS 안심+ 프라임 종신보험(해약환급급50% 지급형)','어떠한 경우에도 가장의 책임을 다 할 수 있도록 사망위험을 종신토록 보장','A','','','','','','','','','','','','','','','','','','','','product/p12.jpg','19991220');
insert into soe.product values ('건강·상해보험','B01','(무) DS 기본형 급여 실손의료비보장보험(갱신형)(2211)','부담되는 의료비 실속있게 대비 하세요!','D','','','','','','','','','','','','','','','','','','','','product/p13.jpg','20210301');
insert into soe.product values ('건강·상해보험','B02','(무) 천년친구 New 간편N 내가고른 건강보험(2404)','나만의 건강맞춤 PICK!','D','','','','','','','','','','','','','','','','','','','','product/p14.jpg','20210301');
insert into soe.product values ('건강·상해보험','B03','(무) 천년친구 New 내가고른 건강보험(2404)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p15.jpg','20210301');
insert into soe.product values ('건강·상해보험','B04','(무) 천년친구 New 내가고른 건강보험(갱신형)(2404)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p16.jpg','20210301');
insert into soe.product values ('건강·상해보험','B05','(무) 천년친구 간편한(335) 내가고른 건강보험(갱신형)(2407)','우리가족 행복지킴이','D','','','','','','','','','','','','','','','','','','','','product/p17.jpg','20210301');
insert into soe.product values ('건강·상해보험','B06','(무) 천년친구 건강보험(2405)','천년친구 건강보험의 장점을 확인해보세요','D','','','','','','','','','','','','','','','','','','','','product/p18.jpg','20210301');
insert into soe.product values ('건강·상해보험','B07','(무) 천년친구 당신곁에 치매간병보험(2405)','우리가족 행복지킴이','D','','','','','','','','','','','','','','','','','','','','product/p19.jpg','20210301');
insert into soe.product values ('건강·상해보험','B08','(무) 천년친구 든든보험(2407)','소중한 우리 아이를 위한 보험','D','','','','','','','','','','','','','','','','','','','','product/p20.jpg','20210301');
insert into soe.product values ('건강·상해보험','B09','(무) 천년친구 생활비보험(2407)','우리가족 행복지킴이','D','','','','','','','','','','','','','','','','','','','','product/p21.jpg','20210301');
insert into soe.product values ('건강·상해보험','B10','(무) 천년친구 암걱정말아요 간편(335) 암보험(2404)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p22.jpg','20210301');
insert into soe.product values ('건강·상해보험','B11','(무) 천년친구 암걱정말아요 간편(335) 암보험(갱신형)(2404)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p23.jpg','20210301');
insert into soe.product values ('건강·상해보험','B12','(무) 천년친구 암걱정말아요 암보험(2403)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p24.jpg','20210301');
insert into soe.product values ('건강·상해보험','B13','(무) 천년친구 암걱정말아요 암보험(갱신형)(2403)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p25.jpg','20210301');
insert into soe.product values ('건강·상해보험','B14','(무) 올우리 미래 든든건강보험(2404)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p26.jpg','20210301');
insert into soe.product values ('건강·상해보험','B15','(무) 이로운 치아보험(갱신형)(2411)','내가 만드는 나만의 보험','D','','','','','','','','','','','','','','','','','','','','product/p27.jpg','20210301');
insert into soe.product values ('건강·상해보험','B16','(무)DS 치과비 걱정없는 치아보험','충치치료 개수 무제한 보장','A','','','','','','','','','','','','','','','','','','','','product/p28.jpg','20210301');
insert into soe.product values ('건강·상해보험','B17','DS건강+ 암보험','일반암도 고액암도 진단금 최대보장','A','','','','','','','','','','','','','','','','','','','','product/p29.jpg','20210301');
insert into soe.product values ('건강·상해보험','B18','(무)DS 100세 든든 슈퍼암보험(갱신형)','일반암 3억원으로 든든하게 보장(주계약+특약)','A','','','','','','','','','','','','','','','','','','','','product/p30.jpg','20210301');
insert into soe.product values ('건강·상해보험','B19','(무)용종 뚝딱 보험','용종 걱정 간편하게 대비','A','','','','','','','','','','','','','','','','','','','','product/p31.jpg','20210301');
insert into soe.product values ('건강·상해보험','B20','(무) 뉴 정말 좋은 치아보험(갱신형)','지금 나에게 꼭 필요한 보장만 딱! 골라서 보험료를 낮추세요','A','','','','','','','','','','','','','','','','','','','','product/p32.jpg','20210301');
insert into soe.product values ('건강·상해보험','B21','(무)백세시대 뉴 하나 건강 보험(갱신형)','내가 원하는 보장만 선택가능한 나에게 딱 맞춘 보험','A','','','','','','','','','','','','','','','','','','','','product/p33.jpg','20210301');
insert into soe.product values ('연금보험','C01','(무) 천년친구 내생애든든연금보험(2404)','연금에 대한 새로운 생각을 담다','D','','','','','','','','','','','','','','','','','','','','product/p34.jpg','20050601');
insert into soe.product values ('연금보험','C02','(무)DS 달러로 받는 연금보험(20년 이율 확정형)','가입시점 금리로 20년간 확정지급하는 달러연금보험','A','','','','','','','','','','','','','','','','','','','','product/p35.jpg','20050601');
insert into soe.product values ('다이렉트','D01','(무) ALL e로운 암보험(갱신형)(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p36.jpg','20050601');
insert into soe.product values ('다이렉트','D02','(무) ALL e로운 암보험(해약환급금 미지급형)(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p37.jpg','20050601');
insert into soe.product values ('다이렉트','D03','(무) ALL e로운 뇌혈관질환보장보험(해약환급금 미지급형)(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p38.jpg','20050601');
insert into soe.product values ('다이렉트','D04','(무) ALL e로운 허혈성심장질환보장보험(해약환급금 미지급형)(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p39.jpg','20050601');
insert into soe.product values ('다이렉트','D05','(무) ALL e로운 장해Plus정기보험(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p40.jpg','20050601');
insert into soe.product values ('다이렉트','D06','(무) ALL e로운 건강검진 주요폴립 수술보험(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p41.jpg','20050601');
insert into soe.product values ('다이렉트','D07','(무) ALL e로운 DB저축보험(2404)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p42.jpg','20050601');
insert into soe.product values ('다이렉트','D08','(무) ALL 기후건강 보장보험(2407)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p43.jpg','20050601');
insert into soe.product values ('다이렉트','D09','(무) ALL e로운 간병입원수술보험(2410)','나의 월 보험료는 과연 얼마','D','','','','','','','','','','','','','','','','','','','','product/p44.jpg','20050601');
insert into soe.product values ('변액보험','E01','(무) 평생친구 변액유니버셜 간편종신보험(2107)','무배당 평생친구','D','변액종신보험','0.28','0.12','0.06','0.04','0.02','0.01','0','0','','','','','','','','','','0.1','product/p45.jpg','20210701');
insert into soe.product values ('변액보험','E02','(무) 평생친구 변액유니버셜 종신보험(2107)','무배당 평생친구','D','변액종신보험','0.28','0.12','0.06','0.04','0.02','0.01','0','0','','','','','','','','','','0.1','product/p46.jpg','20220401');
insert into soe.product values ('변액보험','E03','(무) DS Vitality 여유+ 변액연금보험','수준이 다른 고객님의 자산을 위한 품격 있는 변액연금보험','A','변액연금보험','0.28','0.12','0.06','0.04','0.02','0.01','0','0','6.12','0','2.34','2','0.062','0.2','0','0.11','0.05','0.03','product/p471.jpg','20230401');
insert into soe.product values ('변액보험','E04','(무) 평생 든든 변액연금보험','연금보험으로 나의 소중한 미래를 대비하세요','S','변액유니버셜보험','0.28','0.12','0.06','0.04','0.02','0.01','0','0','','','','','','','','','','0.01','product/p48.jpg','20210401');



commit;

begin
  execute immediate q'[create table soe.call_center_log (
    work_dt varchar2(8),
    work_dt_ts varchar2(19),
    log_id number,
    cust_id number,
    fund_code varchar2(20),
    fund_name varchar2(100),
    call_cnt_3m number,
    late_pmt_cnt number,
    consult_text varchar2(1000)
  )]';
exception
  when others then
    if sqlcode != -955 then
      raise;
    end if;
end;
/
truncate table soe.call_center_log;
@call_center_log_inserts.sql
commit;

EOF

if [ "${SCOPE}" = "--core-only" ]; then
  END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  END_SEC=$(date +%s)
  ELAPSED_SEC=$((END_SEC - START_SEC))

  echo "End time: ${END_TIME}"
  echo "Elapsed time: ${ELAPSED_SEC} seconds"
  echo "Core source business objects prepared."
  exit 0
fi

sqlplus -s soe/soe@orclpdb1 >> "${LOG_FILE}" 2>&1 << EOF

begin
  execute immediate 'drop TABLE soe.OSA_CANCEL_PREDICTION ';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
CREATE TABLE soe.OSA_CANCEL_PREDICTION (
    -- PRED_ID: DB에서 1부터 자동으로 증가하며 생성됨 (매핑 제외)
    PRED_ID          NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, 
    -- EVENT_TIME: YYYY-MM-DD HH24:MI:SS 형식 (OSA의 work_dt_ts 매핑)
    EVENT_TIME       VARCHAR2(19),                       
    CUST_ID          NUMBER,                             
    -- WORK_DT: YYYYMMDD 형식 (OSA의 work_dt 매핑)
    WORK_DT          VARCHAR2(8),                        
    FUND_CODE        VARCHAR2(20),                       
    FUND_NAME        VARCHAR2(100),                      
    CALL_CNT_3M      NUMBER,                             
    LATE_PMT_CNT     NUMBER,                             
    CONSULT_TEXT     VARCHAR2(1000),                     
    -- CONSULT_VECTOR: 23ai 전용 벡터 컬럼 (나중에 AI 검색 시 활용)
    CONSULT_VECTOR   VECTOR(384, FLOAT32)               
);


begin
  execute immediate 'drop TABLE soe.OSA_CANCEL_PREDICTION_GEN ';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
CREATE TABLE soe.OSA_CANCEL_PREDICTION_GEN (
    -- PRED_ID: DB에서 1부터 자동으로 증가하며 생성됨 (매핑 제외)
    PRED_ID          NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    -- EVENT_TIME: YYYY-MM-DD HH24:MI:SS 형식 (OSA의 work_dt_ts 매핑)
    EVENT_TIME       VARCHAR2(19),
    CUST_ID          NUMBER,
    -- WORK_DT: YYYYMMDD 형식 (OSA의 work_dt 매핑)
    WORK_DT          VARCHAR2(8),
    FUND_CODE        VARCHAR2(20),
    FUND_NAME        VARCHAR2(100),
    CALL_CNT_3M      NUMBER,
    LATE_PMT_CNT     NUMBER,
    CONSULT_TEXT     VARCHAR2(1000),
    -- CONSULT_VECTOR: 23ai 전용 벡터 컬럼 (나중에 AI 검색 시 활용)
    RESERVES_AMT            NUMBER,
    CONSULT_VECTOR   VECTOR(384, FLOAT32)
);



begin
  execute immediate q'[create table soe.tmp_trigger (
    msg varchar2(1000),
    dt timestamp
  )]';
exception
  when others then
    if sqlcode != -955 then
      raise;
    end if;
end;
/
CREATE OR REPLACE TRIGGER TRG_AUTO_VECTORIZE_CHURN
BEFORE INSERT ON soe.OSA_CANCEL_PREDICTION
FOR EACH ROW
DECLARE
    -- 에러 메시지를 담을 변수
    v_err_msg VARCHAR2(1000);
BEGIN
    -- 1. 벡터화 시도
    :NEW.CONSULT_VECTOR := DBMS_VECTOR.UTL_TO_EMBEDDING(
                               :NEW.CONSULT_TEXT, 
                               JSON('{"model":"GGADMIN.CHURN_MODEL"}')
                           );
EXCEPTION
    WHEN OTHERS THEN
        -- 2. 에러 메시지 생성
        v_err_msg := 'TRG_AUTO_VECTORIZE_CHURN ' || SQLERRM;
        
        -- 3. 로그 테이블에 자율 트랜잭션으로 기록 (권장)
        -- 트리거가 실패해도 로그는 남아야 하므로 일반 INSERT를 시도합니다.
        INSERT INTO soe.tmp_trigger (MSG, DT)
        VALUES (v_err_msg, CURRENT_TIMESTAMP);
        
        -- 4. 실패 시 NULL 처리
        :NEW.CONSULT_VECTOR := NULL;
END;
/
CREATE OR REPLACE TRIGGER TRG_AUTO_VECTORIZE_CHURN_gen
BEFORE INSERT ON soe.OSA_CANCEL_PREDICTION_gen
FOR EACH ROW
DECLARE
    -- 에러 메시지를 안전하게 저장할 변수
    v_err_msg VARCHAR2(1000);
BEGIN
    -- DBMS_VECTOR 패키지를 이용한 임베딩 생성
    :NEW.CONSULT_VECTOR := DBMS_VECTOR.UTL_TO_EMBEDDING(
                               :NEW.CONSULT_TEXT, 
                               JSON('{"model":"GGADMIN.CHURN_MODEL"}')
                           );
EXCEPTION
    WHEN OTHERS THEN
        -- 에러 메시지 구성 (트리거명 포함)
        v_err_msg := 'TRG_AUTO_VECTORIZE_CHURN_gen: ' || SQLERRM;
        
        -- 로그 테이블에 에러 기록
        INSERT INTO soe.tmp_trigger (MSG, DT)
        VALUES (v_err_msg, CURRENT_TIMESTAMP);
        
        -- 실패 시 해당 행의 벡터 컬럼은 NULL로 처리하여 Insert는 성공시킴
        :NEW.CONSULT_VECTOR := NULL;
END;
/

-- 1. 테이블 생성
begin
  execute immediate 'DROP TABLE soe.SUCCESS_CASE_KNOWLEDGE purge';
exception
  when others then
    if sqlcode != -942 then
      raise;
    end if;
end;
/
CREATE TABLE soe.SUCCESS_CASE_KNOWLEDGE (
    CASE_ID        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    SITUATION      VARCHAR2(1000) NOT NULL,
    SOLUTION       VARCHAR2(2000),
    SUCCESS_STORY  CLOB,
    KNOWLEDGE_VECTOR VECTOR,
    REG_DATE       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 자동 벡터화 트리거 생성
CREATE OR REPLACE TRIGGER TRG_VECTORIZE_KNOWLEDGE
BEFORE INSERT ON soe.SUCCESS_CASE_KNOWLEDGE
FOR EACH ROW
BEGIN
    :NEW.KNOWLEDGE_VECTOR := DBMS_VECTOR.UTL_TO_EMBEDDING(
                                :NEW.SITUATION, 
                                JSON('{"model":"GGADMIN.CHURN_MODEL"}')
                             );
EXCEPTION
    WHEN OTHERS THEN
        :NEW.KNOWLEDGE_VECTOR := NULL;
END;
/


TRUNCATE TABLE soe.SUCCESS_CASE_KNOWLEDGE;

-- 1. 가격 불만 (저가 상품 비교)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('타사 다이렉트 보험료가 20% 저렴하다며 해약 요청', '단순 가격이 아닌 보장 범위와 지급 제한 사항의 차이점 강조', '고객님, 싼 게 비지떡일 수 있습니다. 면책 기간과 갱신 시 인상 폭을 비교해 드려 현 유지가 유리함을 입증함');

-- 2. 상담원 불친절 (감정 케어)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('콜센터 응대 태도에 화가 나서 홧김에 해약하겠다는 상황', '담당 FP가 즉시 해피콜을 통해 본사 대리 사과 및 VIP 전담 관리 약속', '진심 어린 사과와 함께 향후 모든 업무는 제가 직접 밀착 관리해 드리겠다고 약속하여 마음을 돌림');

-- 3. 상품 이해 부족 (설명 필요)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('보장 내용이 너무 어렵고 혜택을 못 받는 것 같아 불신이 생김', '증권 분석 리포트를 시각화하여 대면 설명 및 숨은 보험금 찾아주기', '어려운 약관 대신 한눈에 들어오는 그래프로 보장 내용을 설명하니 고객의 만족도와 신뢰가 수직 상승함');

-- 4. 경제적 어려움 (제도 안내)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('실직이나 가계 부채로 월 보험료 납입이 도저히 불가능한 상황', '해약 대신 감액완납 또는 보험료 납입 일시중지 기능 안내', '당장 해약하면 손실이 크니, 납입은 멈추되 보장은 유지하는 제도를 안내하여 계약을 살려냄');

-- 5. 타사 신상품 유혹 (트렌드 대응)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('유튜브나 지인을 통해 타사의 최신 건강보험(신특약) 가입 희망', '기존 계약 유지하며 부족한 부분만 미니보험으로 보완하는 전략', '기존의 좋은 이율 계약은 깨지 마시고, 원하는 특약만 저렴하게 추가 설계해 드려 해약을 방어함');

-- 6. 가족 간 갈등 (의사결정권자 공략)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('배우자가 보험료가 아깝다며 정리를 요구하는 경우', '가족 전체 보장 분석을 통해 가장의 부재 시 위험 시나리오 공유', '배우자분과 함께 상담하여 이 보험이 가족의 최후 보루임을 인식시키고 가족 패키지 할인 혜택 추가');

-- 7. 보상금 불만 (사후 관리)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('최근 청구한 보험금이 예상보다 적게 나와서 실망함', '미지급 사유 재검토 및 추가 보상 가능한 타 담보 발굴', '약관상 누락된 서류를 찾아내어 추가 보험금을 받게 해드림으로써 회사의 진정성을 증명함');

-- 8. 단순 변심 (리마인드)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('가입한 지 오래되어 필요성을 못 느끼고 잊고 지낸 상황', '그동안의 보장 혜택 요약과 향후 발생 가능한 생애 주기별 위험 안내', '고객님이 잊고 계셨던 훌륭한 특약들을 다시 상기시켜 드려 유지의 가치를 부여함');

-- 9. 모바일/디지털 불편 (편의성 강화)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('앱 사용이 어렵고 본인 인증 등이 복잡해서 해지하고 싶음', 'FP가 직접 방문하여 앱 설치 및 간편 인증 대행 서비스 제공', '디지털 소외감을 느끼지 않도록 직접 조작법을 알려드리고 수기 청구 서비스 지원 약속');

-- 10. 경쟁사 FP의 유혹 (의리 강조)
INSERT INTO soe.SUCCESS_CASE_KNOWLEDGE (SITUATION, SOLUTION, SUCCESS_STORY) 
VALUES ('지인이 타 보험사로 이직하면서 계약 이전을 종용받는 상황', '오랜 관계 유지의 가치와 기존 상품의 예정이율 이점 강조', '지인과의 관계도 중요하지만, 지금 해약 시 발생하는 확정 손실액을 제시하여 합리적 판단 유도');





commit;



EOF

if [ -f "${SCRIPT_DIR}/seed_osa_address.sql" ]; then
  echo "Seeding OSA address data..."
  sqlplus -s soe/soe@orclpdb1 @"${SCRIPT_DIR}/seed_osa_address.sql" >> "${LOG_FILE}" 2>&1
else
  echo "seed_osa_address.sql not found." >&2
  exit 1
fi

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
END_SEC=$(date +%s)
ELAPSED_SEC=$((END_SEC - START_SEC))

echo "End time: ${END_TIME}"
echo "Elapsed time: ${ELAPSED_SEC} seconds"
echo "OSA source objects prepared."
