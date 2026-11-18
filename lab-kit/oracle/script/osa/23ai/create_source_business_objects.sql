-- Source SOE business objects. Run this file only in demo_osrc_23ai.
-- GoldenGate applies the captured DDL and DML to the Target SOE schema.
drop table soe.fundm purge;
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


drop table soe.fund_price purge;
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
        select to_char(add_months(to_date(dt,'YYYYMMDD'),i),'YYYYMMDD'),fund_code,price - TRUNC(DBMS_RANDOM.VALUE(10,250))/10
        from soe.fund_price
        where substr(dt,1,6) = to_char(sysdate,'YYYY') || '01'
        ;
    end loop;
	
	-- 과거 5년치
    for i in 1..60 loop
        insert into soe.fund_price
        select to_char(add_months(to_date(dt,'YYYYMMDD'),-i),'YYYYMMDD'),fund_code,price - TRUNC(DBMS_RANDOM.VALUE(10,250))/10
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
    select to_char(sysdate,'YYYY') vs_year into year from dual;
    
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

@cfund_ratio.sql

-- ##### 고객별 fund 투입비율 설정 마스터 테이블
drop table soe.cfund_rat purge;
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


drop table SOE.ADDRESS purge;
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

Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (70,1,'아파트','삼성','사당동(동작동)','서울특별시 동작구 동작대로35아길 14',113,37.49310413,126.9799582);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (71,1,'아파트','이수교KCC스위첸','동작동','서울특별시 동작구 동작대로45길 22',178,37.49759149,126.9815355);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (72,1,'아파트','이수 힐스테이트','동작동','서울특별시 동작구 동작대로39길 22',680,37.49463598,126.981966);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (73,1,'아파트','사당유니드','사당2동','서울특별시 동작구 동작대로29길 195',151,37.49328761,126.9749856);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (74,1,'아파트','대림','사당3동','서울특별시 동작구 사당로17길 52',1152,37.48742742,126.973148);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (75,1,'아파트','롯데캐슬샤인','사당3동','서울특별시 동작구 사당로27길 190',444,37.49095711,126.9715874);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (76,1,'아파트','사당현대','사당3동','서울특별시 동작구 사당로17길 111',265,37.48772967,126.9707248);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (77,1,'아파트','사당현대2차','사당3동','서울특별시 동작구 사당로17길 111',81,37.48772967,126.9707248);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (78,1,'아파트','경남아너스빌','사당3동','서울특별시 동작구 사당로9가길 82',340,37.4882815,126.9671339);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (79,1,'아파트','대아2차','사당3동','서울특별시 동작구 사당로 165',120,37.48741228,126.9677489);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (80,1,'아파트','동작삼성래미안(1차)','사당3동','서울특별시 동작구 사당로23바길 9',896,37.48960968,126.9691902);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (81,2,'아파트','사당롯데캐슬솔레','사당3동','서울특별시 동작구 사당로27길 181',223,37.49055149,126.9716261);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (82,2,'아파트','사당대창센시티','사당3동','서울특별시 동작구 사당로9가길 55',76,37.48690798,126.9683943);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (83,2,'아파트','남성두산위브 트레지움','사당3동','서울특별시 동작구 사당로13길 31',451,37.485803,126.9712548);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (84,2,'아파트','이너스내안에','사당3동','서울특별시 동작구 사당로13길 40',42,37.48609883,126.9721489);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (85,2,'아파트','이수역 리가','사당3동','서울특별시 동작구 사당로27길 130',452,37.48982944,126.9728808);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (87,2,'아파트','삼익그린뷰','사당4동','서울특별시 동작구 남부순환로255길 21',183,37.47737607,126.9688912);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (88,2,'아파트','진흥','사당4동','서울특별시 동작구 사당로16아길 43',140,37.48056197,126.9693294);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (89,2,'아파트','KCC아파트','사당4동','서울특별시 동작구 사당로20나길 57',111,37.48159582,126.9739598);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (90,2,'아파트','사당휴먼시아','사당4동','서울특별시 동작구 사당로16길 96',480,37.47949611,126.9701405);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (91,3,'아파트','제일','사당5동','서울특별시 동작구 사당로16다길 57',296,37.48268743,126.9692541);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (92,3,'아파트','인정','사당5동','서울특별시 동작구 사당로2길 72',55,37.48995661,126.9648256);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (93,3,'아파트','삼호그린','사당5동','서울특별시 동작구 사당로2가길 188',211,37.48644352,126.9655243);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (94,3,'아파트','사당자이','사당5동','서울특별시 동작구 사당로2가길 102',719,37.48837303,126.9634174);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (95,3,'아파트','남해오네뜨','사당5동','서울특별시 동작구 사당로2가길 173',131,37.48701062,126.9655288);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (96,3,'아파트','장은해그린','사당5동','서울특별시 동작구 사당로2길 40',79,37.49191768,126.9634132);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (97,3,'아파트','사당갑을명가','사당5동','서울특별시 동작구 솔밭로 65',63,37.48227428,126.966441);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (98,3,'아파트','관악푸르지오 102동','사당5동','서울특별시 동작구 관악로30길 27',40,37.48593701,126.9618215);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (99,3,'아파트','반석블레스','사당5동','서울특별시 동작구 사당로2길 76',49,37.48949863,126.9654155);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (100,3,'아파트','대방주공1차(영구임대)','대방동','서울특별시 동작구 여의대방로44길 47',925,37.50992631,126.9304253);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (101,4,'아파트','대방대림','대방동','서울특별시 동작구 여의대방로44길 10',1628,37.50736122,126.9260908);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (102,4,'아파트','대방성원','대방동','서울특별시 동작구 여의대방로44길 9',487,37.50973084,126.9259178);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (103,4,'아파트','대방현대1차','대방동','서울특별시 동작구 등용로 127',514,37.51301522,126.930271);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (104,4,'아파트','대방2단지주공','대방동','서울특별시 동작구 여의대방로44길 47',798,37.50992631,126.9304253);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (105,4,'아파트','대방한국개나리','대방동','서울특별시 동작구 여의대방로62길 15',90,37.51417479,126.9285779);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (106,4,'아파트','신한토탈','대방동','서울특별시 동작구 등용로14길 34',134,37.51179644,126.9330894);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (107,4,'아파트','우정','대방동','서울특별시 동작구 여의대방로62길 23',206,37.51428026,126.9294056);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (108,4,'아파트','대방2차현대','대방동','서울특별시 동작구 알마타길 58',278,37.51081665,126.9311465);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (109,4,'아파트','대방1차e-편한세상','대방동','서울특별시 동작구 알마타길 37',609,37.51265989,126.9295526);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (110,4,'아파트','대방2차e-편한세상','대방동','서울특별시 동작구 알마타길 53',100,37.51203051,126.931342);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (111,5,'아파트','보라매코오롱하늘채','대방동','서울특별시 동작구 여의대방로24다길 40',200,37.49851534,126.9228776);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (113,5,'아파트','대방동경남아너스빌','대방동','서울특별시 동작구 여의대방로54길 6',163,37.51155229,126.9253078);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (114,5,'아파트','신대방우성1차','신대방1동','서울특별시 동작구 여의대방로 22',1335,37.49106174,126.9116424);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (115,5,'아파트','신대방2차우성','신대방1동','서울특별시 동작구 여의대방로 8',174,37.49310363,126.9106015);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (116,5,'아파트','신대방현대','신대방1동','서울특별시 동작구 여의대방로 28',880,37.49527344,126.9116905);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (117,5,'아파트','경남교수','신대방1동','서울특별시 동작구 여의대방로10길 14',295,37.49632776,126.9139635);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (118,5,'아파트','신대방경남','신대방1동','서울특별시 동작구 신대방길 85',427,37.49005342,126.9083379);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (119,5,'아파트','롯데낙천대','신대방1동','서울특별시 동작구 여의대방로10길 38',734,37.49540996,126.9125665);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (120,5,'아파트','현진에버빌','신대방1동','서울특별시 동작구 신대방1나길 45',135,37.48588021,126.9070485);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (121,6,'아파트','숲속마을신동아파밀리에','신대방1동','서울특별시 동작구 여의대방로10길 100',105,37.49157807,126.9145347);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (122,6,'아파트','펭귄대방','신대방2동','서울특별시 동작구 여의대방로22나길 47',60,37.49620293,126.9227728);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (123,6,'아파트','신대방신동아','신대방2동','서울특별시 동작구 여의대방로22아길 22',171,37.49660641,126.9240309);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (124,6,'아파트','신대방한성','신대방2동','서울특별시 동작구 여의대방로10길 13',272,37.49574265,126.9152118);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (125,6,'아파트','신대방(분양 60, 임대48)','신대방2동','서울특별시 동작구 보라매로 83',108,37.49665868,126.9273398);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (126,6,'아파트','보라매우성','신대방2동','서울특별시 동작구 보라매로5길 5',199,37.49238847,126.925359);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (127,6,'아파트','신대방벽산','신대방2동','서울특별시 동작구 여의대방로22길 24',132,37.49744995,126.9215728);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (128,6,'아파트','보라매파크빌','신대방2동','서울특별시 동작구 여의대방로10길 59',423,37.49511473,126.9150796);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (130,6,'아파트','보라매 e편한세상','신대방2동','서울특별시 동작구 보라매로 70',386,37.49577317,126.9289798);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (131,7,'아파트','흑석아크로리버하임(분양911,임대162)','흑석동','서울특별시 동작구 현충로 52',1073,37.5096318,126.9622042);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (132,7,'아파트','흑석롯데캐슬에듀포레(분양451,임대94)','흑석동','서울특별시 동작구 서달로 123',545,37.50421186,126.9596731);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (134,7,'아파트','사당롯데캐슬골든포레','사당5동','서울특별시 동작구 사당로 90',959,37.49083312,126.9633456);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (135,7,'아파트','상도역롯데캐슬파크엘','상도2동','서울틀별시 동작구 양녕로 220',950,37.49989893,126.9454762);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (139,7,'주상복합','상도휴엔하임(도시형)','상도2동','서울특별시 동작구 상도로15길 131',298,37.5049676,126.9379704);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (140,7,'주상복합','이랜드해가든','흑석동','서울특별시 동작구 서달로 150',154,37.50662658,126.9621838);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (141,8,'주상복합','이수자이','사당2동','서울특별시 동작구 사당로 300',140,37.48437909,126.9802816);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (142,8,'주상복합','동작상떼빌','신대방1동','서울특별시 동작구 신대방1가길 38',545,37.487901,126.9069396);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (143,8,'주상복합','삼성보라매옴니타워','신대방2동','서울특별시 동작구 보라매로5길 23',72,37.49257855,126.9236102);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (144,8,'주상복합','보라매현대(한국컴퓨터)','신대방2동','서울특별시 동작구 보라매로5길 35',82,37.49209014,126.9235081);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (145,8,'주상복합','보라매삼성쉐르빌','신대방2동','서울특별시 동작구 보라매로5길 43',246,37.49143108,126.923417);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (146,8,'주상복합','롯데타워','신대방2동','서울특별시 동작구 보라매로5길 51',90,37.49094201,126.9232712);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (147,8,'주상복합','보라매나산스위트','신대방2동','서울특별시 동작구 보라매로5가길 24',99,37.49069953,126.9239441);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (148,8,'주상복합','보라매아카데미타워','신대방2동','서울특별시 동작구 보라매로5가길 16',225,37.4912751,126.9240947);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (149,8,'주상복합','캐릭터그린빌','신대방2동','서울특별시 동작구 보라매로5가길 7',96,37.49189234,126.9251557);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (150,8,'연립주택','은하맨션','노량진1동','서울특별시 동작구 장승배기로28길36',32,37.51221007,126.9424498);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (151,9,'연립주택','삼원','본동 ','서울특별시 동작구 매봉로 149',35,37.51100575,126.9507461);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (152,9,'연립주택','우성아파트','노량진2동','서울특별시 동작구 노량진로6길 29',37,37.51151191,126.9360396);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (153,9,'연립주택','태건','상도2동 ','서울특별시 동작구 상도로34길 59',24,37.50231766,126.9456743);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (154,9,'연립주택','동도','상도3동 ','서울특별시 동작구 상도로13나길 37',48,37.5032199,126.9286912);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (155,9,'연립주택','대광','상도4동 ','서울특별시 동작구 양녕로 216',48,37.50001145,126.9452981);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (156,9,'연립주택','청학','상도4동 ','서울특별시 동작구 양녕로 212',23,37.49990772,126.9450452);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (157,9,'연립주택','현진','상도4동 ','서울특별시 동작구 양녕로 177',42,37.49715225,126.9429326);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (158,9,'연립주택','성대','상도4동 ','서울특별시 동작구 성대로 31',30,37.49914529,126.9338146);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (159,9,'연립주택','정경맨션','상도4동','서울특별시 동작구 성대로19길 24',24,37.49933413,126.9365788);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (160,9,'연립주택','경운','사당1동 ','서울특별시 동작구 동작대로7길 64',39,37.47866901,126.9785783);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (161,10,'연립주택','칠성연립','사당1동','서울특별시 동작구 사당로 20길 109',30,37.47869239,126.9746775);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (163,10,'연립주택','동작연립','동작동','서울특별시 동작구 동작대로43길 22',32,37.49700121,126.9813339);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (164,10,'연립주택','성락','사당3동 ','서울특별시 동작구 사당로27길 247',42,37.49249907,126.968981);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (165,10,'연립주택','신아','사당4동 ','서울특별시 동작구 사당로16길 137-1',30,37.47763298,126.9704117);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (166,10,'연립주택','유성','사당5동 ','서울특별시 동작구 사당로10길 1',24,37.48481451,126.9701924);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (167,10,'연립주택','신남성연립','사당5동','서울특별시 동작구 사당로2가길 131',36,37.48933248,126.9641933);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (168,10,'연립주택','연우연립','사당5동','서울특별시 동작구 사당로8길 68',21,37.4827902,126.9671122);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (169,10,'연립주택','능내연립','사당5동','서울특별시 동작구 사당로8길 39',22,37.48359946,126.9686725);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (170,10,'연립주택','천록','대방동 ','서울특별시 동작구 등용로 43',29,37.50547501,126.9334342);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (1,11,'아파트','노량진우성','노량진1동','서울특별시 동작구 만양로8길 50',901,37.51030426,126.9468658);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (2,11,'아파트','노량진삼익','노량진1동','서울특별시 동작구 만양로 84',175,37.51136715,126.9452257);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (3,11,'아파트','신동아리버파크 (분양 1,696,임대 925) ','노량진1동','서울특별시 동작구 만양로 19',2621,37.50707255,126.9457185);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (4,11,'아파트','노량진쌍용예가','노량진1동','서울특별시 동작구 장승배기로16길 134',299,37.5102653,126.9436765);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (5,11,'아파트','형인한강','노량진1동','서울특별시 동작구 만양로 36',73,37.50766447,126.9482347);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (6,11,'아파트','노량진','노량진2동','서울특별시 동작구 장승배기로18길 27',49,37.50770883,126.9417167);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (7,11,'아파트','극동강변','본동','서울특별시 동작구 매봉로 158',123,37.51144533,126.9515736);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (8,11,'아파트','본동신동아','본동','서울특별시 동작구 매봉로 134',765,37.51014704,126.9514909);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (9,11,'아파트','한강쌍용','본동','서울특별시 동작구 노량진로24길 2',161,37.51238829,126.9530502);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (10,11,'아파트','유원강변','본동','서울특별시 동작구 노량진로23가길 16',306,37.51426247,126.9517146);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (11,12,'아파트','경동윈츠리버','본동','서울특별시 동작구 노량진로32길 156',272,37.50939598,126.9544859);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (12,12,'아파트','한신휴플러스 (분양247,임대 134)','본동','서울특별시 동작구 매봉로 99',381,37.5092063,126.9491302);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (13,12,'아파트','삼성래미안','본동','서울특별시 동작구 매봉로 123',477,37.51014312,126.9498666);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (14,12,'아파트','본동SH빌(임대)','본동','서울특별시 동작구 노량진로22길 60',176,37.51078906,126.9496893);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (15,12,'아파트','래미안 트윈파크(분양 432, 임대 91) ','본동','서울특별시 동작구 노량진로23가길 23',523,37.51330347,126.9517825);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (16,12,'아파트','대우유로카운티','상도1동','서울특별시 동작구 양녕로 287',78,37.50540243,126.9493142);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (17,12,'아파트','중앙하이츠빌','상도1동','서울특별시 동작구 상도로 320',544,37.49980716,126.9499021);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (18,12,'아파트','강남상가','상도1동','서울특별시 동작구 상도로 357',69,37.49693976,126.9535408);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (20,12,'아파트','상도삼호(분양 461, 임대 221) ','상도1동','서울특별시 동작구 상도로 407',682,37.49391739,126.9577733);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (22,13,'아파트','상도1동대림','상도1동','서울특별시 동작구 상도로60길 20',279,37.49318623,126.9532605);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (23,13,'아파트','상도현대','상도1동','서울특별시 동작구 사당로2길 2-32',194,37.49419913,126.9595703);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (24,13,'아파트','래미안상도2차','상도1동','서울특별시 동작구 상도로55길 47',431,37.49834009,126.9588505);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (25,13,'아파트','래미안상도3차','상도1동','서울특별시 동작구 상도로53길 8',1656,37.50086276,126.9540532);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (28,13,'아파트','상도SH빌(임대)','상도1동','서울특별시 동작구 상도로53길 70',953,37.50253458,126.954541);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (29,13,'아파트','상도페리스','상도1동','서울특별시 동작구 상도로47바길 40',80,37.50337631,126.9541113);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (30,13,'아파트','삼환나우빌','상도1동','서울특별시 동작구 상도로55길 25',91,37.49840405,126.9568206);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (31,14,'아파트','상도건영(분양 824, 임대 552) ','상도2동','서울특별시 동작구 만양로 26',1376,37.50763053,126.9495436);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (32,14,'아파트','상도래미안1차 (분양 517, 임대 164) ','상도2동','서울특별시 동작구 등용로 37',681,37.50523976,126.9331339);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (33,14,'아파트','I PARK상도동','상도2동','서울특별시 동작구 장승배기로 26',400,37.50066424,126.943415);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (34,14,'아파트','상도더샵','상도2동','서울특별시 동작구 장승배기로4길 9',1122,37.5014493,126.9438142);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (35,14,'아파트','상도더샵2차','상도2동','서울특별시 동작구 장승배기로10길 100',138,37.50286848,126.9434526);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (36,14,'아파트','브라운스톤상도','상도2동','서울특별시 동작구 상도로31길 19',415,37.50623587,126.9445418);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (37,14,'아파트','상도동동원베네스트','상도2동','서울특별시 동작구 상도로34길 42',162,37.50301195,126.944659);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (38,14,'아파트','상도 두산위브','상도2동','서울특별시 동작구 상도로30길 39',190,37.50479562,126.9422973);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (41,15,'아파트','상도파크자이(분양387, 임대84)','상도2동','서울특별시 동작구 장승배기로11가길 11',471,37.50556599,126.9389112);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (42,15,'아파트','상도쌍용스윗닷홈(분양389, 임대65)','상도3동','서울특별시 동작구 상도로 107',454,37.5024023,126.9310692);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (43,15,'아파트','상도1차갑을명가','상도3동','서울특별시 동작구 국사봉길 178',123,37.49374752,126.9340893);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (44,15,'아파트','상도2차갑을명가','상도3동','서울특별시 동작구 국사봉길 175',118,37.49347327,126.9350964);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (45,15,'아파트','약수맨션','상도4동','서울특별시 동작구 양녕로26길 15',130,37.49757689,126.9446235);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (46,15,'아파트','롯데캐슬비엔','상도4동','서울특별시 동작구 양녕로 170',141,37.49700194,126.9436426);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (47,15,'아파트','동아','상도4동','서울특별시 동작구 양녕로23길 43',75,37.4961816,126.9400389);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (48,15,'아파트','상도삼익','상도4동','서울특별시 동작구 양녕로26나길 8',61,37.49736485,126.9445589);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (49,15,'아파트','경향렉스빌','상도4동','서울특별시 동작구 양녕로23길 9',197,37.49532415,126.9417295);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (50,15,'아파트','우리유앤미','흑석동','서울특별시 동작구 서달로 83',206,37.50042906,126.9598634);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (51,16,'아파트','흑석동양','흑석동','서울특별시 동작구 서달로1길 17',423,37.50073517,126.9586697);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (52,16,'아파트','명수대현대','흑석동','서울특별시 동작구 현충로 119',660,37.50827135,126.9672582);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (53,16,'아파트','한강현대','흑석동','서울특별시 동작구 현충로 151',960,37.50677865,126.9689342);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (54,16,'아파트','명수대한양','흑석동','서울특별시 동작구 현충로10길 42',90,37.50476273,126.9665613);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (55,16,'아파트','명수대','흑석동','서울특별시 동작구 서달로 158',51,37.50705325,126.9623219);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (56,16,'아파트','흑석동청호(분양176, 임대170)','흑석동','서울특별시 동작구 서달로2길 29',346,37.50190323,126.9627348);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (57,16,'아파트','흑석한강센트레빌(분양541, 임대114)','흑석동','서울특별시 동작구 흑석한강로 12',655,37.50517984,126.9645125);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (58,16,'아파트','흑석한강푸르지오(분양716, 임대147)','흑석동','서울특별시 동작구 흑석한강로 27',863,37.50409942,126.9662844);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (59,16,'아파트','흑석한강센트레빌Ⅱ(분양798, 임대165)','흑석동','서울특별시 동작구 서달로 91',963,37.50316562,126.958891);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (60,16,'아파트','르메이에르타운','사당1동','서울특별시 동작구 사당로20길 119',140,37.4784341,126.973616);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (61,17,'아파트','삼성','사당1동','서울특별시 동작구 사당로26길 130-6',60,37.4780357,126.9776457);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (62,17,'아파트','극동','사당2동','서울특별시 동작구 동작대로29길 119',1550,37.49088863,126.9760567);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (63,17,'아파트','사당우성2단지','사당2동','서울특별시 동작구 동작대로29길 91',1080,37.48801987,126.9762953);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (64,17,'아파트','사당우성3단지','사당2동','서울특별시 동작구 동작대로29길 115',855,37.49041718,126.9758253);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (65,17,'아파트','대아','사당2동','서울특별시 동작구 동작대로29길 81',90,37.48883128,126.9774513);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (66,17,'아파트','사당신동아4단지','사당동(동작동)','서울특별시 동작구 동작대로29길 110',912,37.48984069,126.9779944);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (67,17,'아파트','사당5단지신동아(분양223, 임대110)','사당동(동작동)','서울특별시 동작구 동작대로29길 118',333,37.49104148,126.9771482);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (68,17,'아파트','동작동금강KCC','동작동','서울특별시 동작구 동작대로39가길 55',276,37.49351407,126.9788425);
Insert into SOE.ADDRESS (CUST_ID,FP_ID,CATEGORY,GUNMUL,JUNGDON,JUSO,CNT,LAT,LON) values (69,17,'아파트','신동아갯마을','동작동','서울특별시 동작구 동작대로43길 36',44,37.49710602,126.9809603);

commit;


-- ##### 고객별 월별 납입금액 설정 마스터
drop table soe.cfund_deposit purge;
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
drop table soe.reserves_amt purge;
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
drop table soe.opm purge;
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
drop table soe.OpStatus purge;
create table soe.OpStatus (
op_gubun varchar2(5),
op_name varchar2(30),
op_cnt number );

alter table soe.OpStatus add constraint OpStatusPk primary key (op_gubun);



drop table soe.tot_amt purge;
create table soe.tot_amt (
op_gubun varchar2(10),
gubun varchar2(20),
heartbt varchar2(20),
tot_amt number,
start_dt varchar2(30));
alter table soe.tot_amt add constraint tot_amt_pk primary key (op_gubun,gubun);


drop table soe.cancelamt purge;
create table soe.cancelamt (
dt varchar2(8),
cust_id number,
op_gubun varchar2(10),
--tot_amt number,
tot_amt varchar2(20),
start_dt varchar2(30));
alter table soe.cancelamt add constraint cancelamt_pk primary key (dt,cust_id,op_gubun);


drop table soe.heartbp purge;
create table soe.heartbp (
dt varchar2(8),
keys number,
period_start varchar2(15),
start_dt varchar2(30))
;
alter table soe.heartbp add constraint heartbp_pk primary key (dt,keys);

drop table soe.employee purge;
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
drop table soe.cancelfp purge;
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
drop table soe.msg purge;
Create table soe.msg (job_name varchar2(30), start_dt varchar2(30), end_dt varchar2(30),finished varchar2(5));

--####### CDC BMT 측정용도
--Source, Target 양쪽 모두
drop table soe.CFUND_DT purge;
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



exit
