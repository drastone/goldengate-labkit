import time
import oracledb

from prometheus_client import start_http_server, Counter
from prometheus_client.core import GaugeMetricFamily, CounterMetricFamily, REGISTRY

c = Counter(
        #name="counter_test2",
        name="extract",
        documentation="extrace process for capture",
        labelnames=["call_time", "process_name", "status", "lag", "sincelagreported", "out_prefix", "out_seq", "out_rba", "br_state_size", "br_total_size"])

d = Counter(
        #name="counter_test2",
        name="xstreams",
        documentation="xstreams information for integrated capture",
        labelnames=["extract_name", "state", "total_messages_captured", "sga_used", "sga_allocated", "last_send_message_number"])

e = Counter(
        #name="counter_test2",
        name="replicat",
        documentation="replicat process for apply",
        labelnames=["call_time","process_name","status","lag","sincelagreported","in_prefix","in_seq","in_rba"])

#f = Counter(
        #name="counter_test2",
        #name="sga_source",
        #documentation="sga_used information for source side",
        #labelnames=["process_name", "name", "value", "colors"])
        #labelnames=["sga_used"])

f = CounterMetricFamily("sga_source", "sga used information for source side", labels=["sga_used"])

i = Counter(
        name="distpath",
        documentation="dist path information",
        labelnames=["call_time", "process_name","status","lag","sincelagreported","in_prefix","in_seq","in_rba","out_prefix","out_seq","out_rba"])

class getInfoSgaSource(object):
    def __init__(self):
        pass

    def collect(self):
        g = GaugeMetricFamily("sga_used_source", "sga used informatino for source side", labels=["sga_used"])
        con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
        cursor = con.cursor()

        cursor.execute(" select round(sum(sga_used) /sum(sga_allocated),2)*100  sga_used from soe.moncap ")
        out_data = cursor.fetchall()
        for row in out_data:
            g.add_metric("sga_used",row[0])


        cursor.close()
        con.close()

        yield g

class getInfoSgaTarget(object):
    def __init__(self):
        pass

    def collect(self):
        h = GaugeMetricFamily("sga_used_target", "sga used informatino for source side", labels=["sga_used"])
        con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
        cursor = con.cursor()

        sql = " select round(value,2) sga_used " \
                " from " \
                " ( " \
                "     select apply_name,sga_used/(1024*1024) as used_MB, sga_allocated/(1024*1024) as allocated_MB, (sga_used/sga_allocated)*100 as value, " \
                "            total_messages_dequeued as msgs_dequeued  " \
                "     from sys.gg_apply_reader  " \
                "     order by apply_name " \
                " ) " \

        cursor.execute(sql)
        out_data = cursor.fetchall()
        for row in out_data:
            h.add_metric("sga_used",row[0])


        cursor.close()
        con.close()

        yield h

class getInfoCacheMgr(object):
    def __init__(self):
        pass

    def collect(self):
        #j = GaugeMetricFamily("cachemgr_bar", "sga used informatino for source side", labels=["name", "value"])
        j = GaugeMetricFamily("cachemgr_bar", "sga used information for source side", labels=["name"])
        con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
        cursor = con.cursor()

        sql = " select name, value                                                                                  " \
                    " from                                                                                                               " \
                    " (                                                                                                                  " \
                    "     select process_name,'1. CACHESIZE' name, cachesize /1024/1024 value, 1 id                                         " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    "     union all                                                                                                      " \
                    "     select process_name,'2. Max Memory Used', maxvmused /1024/1024 value, 2 id                                        " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    "     union all                                                                                                      " \
                    "     select process_name,'3. Current Memory Used', currentvmused /1024/1024 value, 3 id                                " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    "     union all                                                                                                      " \
                    "     select process_name,'4. ANON Memory', currentmmapanon /1024/1024 value, 4 id                                      " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    "     union all                                                                                                      " \
                    "     select process_name,'5. Free Memory', currentmmaprecycles /1024/1024 value, 5 id                                  " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    "     union all                                                                                                      " \
                    "     select process_name,'6. Bytes To Disk',bytestodisk /1024/1024 value, 6 id                                         " \
                    "     from soe.restmon a                                                                                             " \
                    "     where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT' and gubun2 = 'CACHEMONITOR')     " \
                    "     and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                " \
                    " )                                                                                                                  " \

        cursor.execute(sql)
        out_data = cursor.fetchall()
        for row in out_data:
            #j.add_metric("name",row[1])
            j.add_metric([row[0]],row[1])


        cursor.close()
        con.close()

        yield j

class getInfoDMLs(object):
    def __init__(self):
        pass

    def collect(self):
        #j = GaugeMetricFamily("cachemgr_bar", "sga used informatino for source side", labels=["name", "value"])
        k = GaugeMetricFamily("DMLs", "DML Operation information", labels=["gubun"])
        con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
        cursor = con.cursor()

        sql = " select 'insert' gubun, sum(substr(val3,0,instr(val3,':')-1))    val                                              " \
                " from soe.monres                                                                                                  " \
                " where keya = 'replicat'                                                                                          " \
                " and keyb = 'Replicat Stats'                                                                                      " \
                " and call_time = (select call_time from soe.monres where keya = 'replicat' and keyb = 'BASE_TIMESTAMP')           " \
                " union all                                                                                                        " \
                " select 'update' ,sum(substr(val,0,instr(val,':')-1))                                                             " \
                " from                                                                                                             " \
                " (                                                                                                                " \
                "     select val3, substr(val3,0,instr(val3,':')-1) \"insert\",substr(val3,instr(val3,':')+1) val                    " \
                "     from soe.monres                                                                                              " \
                "     where keya = 'replicat'                                                                                      " \
                "     and keyb = 'Replicat Stats'                                                                                  " \
                "     and call_time = (select call_time from soe.monres where keya = 'replicat' and keyb = 'BASE_TIMESTAMP')       " \
                " )                                                                                                                " \
                " union all                                                                                                        " \
                " select 'delete',sum(substr(val,instr(val,':')+1) )                                                               " \
                " from                                                                                                             " \
                " (                                                                                                                " \
                "     select val3, substr(val3,0,instr(val3,':')-1) \"insert\",substr(val3,instr(val3,':')+1) val                    " \
                "     from soe.monres                                                                                              " \
                "     where keya = 'replicat'                                                                                      " \
                "     and keyb = 'Replicat Stats'                                                                                  " \
                "     and call_time = (select call_time from soe.monres where keya = 'replicat' and keyb = 'BASE_TIMESTAMP')       " \
                " )                                                                                                                " \

        cursor.execute(sql)
        out_data = cursor.fetchall()
        for row in out_data:
            #j.add_metric("name",row[1])
            k.add_metric([row[0]],row[1])


        cursor.close()
        con.close()

        yield k

class getInfoHeartBeat(object):
    def __init__(self):
        pass

    def collect(self):
        h = GaugeMetricFamily("heartbeat", "heartbeat information", labels=["sga_used"])
        con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
        cursor = con.cursor()

        sql = " select                                                                                                                                                                " \
                "         routing,                                                                                                                                                      " \
                "         round(total_lag,2) total_lag                                                                                                                                  " \
                " from                                                                                                                                                                  " \
                " (                                                                                                                                                                     " \
                "   select incoming_extract ||'_'||incoming_routing_path||'_'|| incoming_replicat routing,to_char(incoming_heartbeat_ts, 'DD-MON-YY HH24:MI:SSxFF') Source_HB_Ts ,      " \
                "          incoming_extract Extract ,                                                                                                                                   " \
                "          extract (day                                                                                                                                                 " \
                "             from (incoming_extract_ts - incoming_heartbeat_ts))*24*60*60+ extract (hour                                                                               " \
                "             from (incoming_extract_ts - incoming_heartbeat_ts))*60*60+ extract (minute                                                                                " \
                "             from (incoming_extract_ts - incoming_heartbeat_ts))*60+ extract (second                                                                                   " \
                "             from (incoming_extract_ts - incoming_heartbeat_ts)) Extract_Lag ,                                                                                         " \
                "          incoming_routing_path Data_Pump ,                                                                                                                            " \
                "          extract (day                                                                                                                                                 " \
                "             from (incoming_routing_ts - incoming_extract_ts))*24*60*60+ extract (hour                                                                                 " \
                "             from (incoming_routing_ts - incoming_extract_ts))*60*60+ extract (minute                                                                                  " \
                "             from (incoming_routing_ts - incoming_extract_ts))*60+ extract (second                                                                                     " \
                "             from (incoming_routing_ts - incoming_extract_ts)) Data_Pump_Read_Lag ,                                                                                    " \
                "          incoming_replicat Replicat ,                                                                                                                                 " \
                "          extract (day                                                                                                                                                 " \
                "             from (incoming_replicat_ts - incoming_routing_ts))*24*60*60+ extract (hour                                                                                " \
                "             from (incoming_replicat_ts - incoming_routing_ts))*60*60+ extract (minute                                                                                 " \
                "             from (incoming_replicat_ts - incoming_routing_ts))*60+ extract (second                                                                                    " \
                "             from (incoming_replicat_ts - incoming_routing_ts)) Replicat_Read_Lag ,                                                                                    " \
                "          extract (day                                                                                                                                                 " \
                "             from (heartbeat_received_ts - incoming_replicat_ts))*24*60*60+ extract (hour                                                                              " \
                "             from (heartbeat_received_ts - incoming_replicat_ts))*60*60+ extract (minute                                                                               " \
                "             from (heartbeat_received_ts - incoming_replicat_ts))*60+ extract (second                                                                                  " \
                "             from (heartbeat_received_ts - incoming_replicat_ts)) Replicat_Apply_Lag ,                                                                                 " \
                "          extract (day                                                                                                                                                 " \
                "             from (heartbeat_received_ts - incoming_heartbeat_ts))*24*60*60+ extract (hour                                                                             " \
                "             from (heartbeat_received_ts - incoming_heartbeat_ts))*60*60+ extract (minute                                                                              " \
                "             from (heartbeat_received_ts - incoming_heartbeat_ts))*60+ extract (second                                                                                 " \
                "             from (heartbeat_received_ts - incoming_heartbeat_ts)) Total_Lag                                                                                           " \
                "     from c##ogg.gg_heartbeat_history                                                                                                                                  " \
                "    order by heartbeat_received_ts desc                                                                                                                                " \
                " )                                                                                                                                                                     " \
                " where rownum <= 1                                                                                                                                                    " \

        cursor.execute(sql)
        out_data = cursor.fetchall()
        for row in out_data:
            h.add_metric("hearbeat",row[1])


        cursor.close()
        con.close()

        yield h

if __name__ == "__main__":

        port = 9000
        #frequency = 1
        frequency = 5

        start_http_server(port)

        REGISTRY.register(getInfoSgaSource())
        REGISTRY.register(getInfoSgaTarget())
        REGISTRY.register(getInfoCacheMgr())
        REGISTRY.register(getInfoDMLs())
        REGISTRY.register(getInfoHeartBeat())

        while True:
            con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
            cursor = con.cursor()

            sql = "select call_time,process_name,status,lag,sincelagreported,out_prefix,out_seq,out_rba,brtotstatesize BR_State_Size,brtotdatasize BR_Total_Size " \
                " from soe.restmon a " \
                " where process_name in (select gubun1 from soe.ogg_conf where keya = 'EXTRACT') " \
                " and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP') " \


            #cursor.execute("select process_name,status from soe.restmon where rownum < 3")
            cursor.execute(sql)
            #out_data = cursor.fetchone()
            out_data = cursor.fetchall()


            for row in out_data:
                #b.add_metric("",row[0])
                #c.labels(first='1', second='3', extract=row[0], status=row[1]).inc(1)
                c.labels(call_time=row[0], process_name=row[1], status=row[2], lag=row[3], sincelagreported=row[4], out_prefix=row[5], out_seq=row[6], out_rba=row[7], br_state_size=row[8], br_total_size=row[9]).inc(1)

            cursor.close()
            con.close()

            con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
            cursor = con.cursor()

            sql = " select extract_name, state, TOTAL_MESSAGES_CAPTURED, sga_used,sga_allocated,last_send_message_number  " \
                " from soe.moncap " \
                " where call_time = (select call_time from soe.moncap where capture_name = 'DUMMY_BASE_TIMESTAMP') " \
                " and capture_name <> 'DUMMY_BASE_TIMESTAMP' " \


            cursor.execute(sql)
            out_data = cursor.fetchall()

            for row in out_data:
                d.labels(extract_name=row[0], state=row[1], total_messages_captured=row[2], sga_used=row[3], sga_allocated=row[4], last_send_message_number=row[5]).inc(1)

            cursor.close()
            con.close()

            con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
            cursor = con.cursor()

            #sql = " select process_name, name, value,                                                                                  " \
            sql = " select call_time,process_name,status,lag,sincelagreported,in_prefix,in_seq,in_rba                                    " \
                    " from soe.restmon a                                                                                                 " \
                    " where process_name in (select gubun1 from soe.ogg_conf where keya = 'REPLICAT')                                    " \
                    " and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP')                    " \

            cursor.execute(sql)
            out_data = cursor.fetchall()

            for row in out_data:
                #e.labels(process_name=row[0], name=row[1], value=row[2], colors=row[3]).inc(1)
                e.labels(call_time=row[0], process_name=row[1], status=row[2], lag=row[3], sincelagreported=row[4], in_prefix=row[5], in_seq=row[6], in_rba=row[7]).inc(1)

            cursor.close()
            con.close()

            con = oracledb.connect(user="soe", password="soe", dsn="192.168.56.191:1521/PDB01")
            cursor = con.cursor()

            sql = " select call_time,process_name,status,lag,sincelagreported,in_prefix,in_seq,in_rba,out_prefix,out_seq,out_rba  " \
                    " from soe.restmon a " \
                    " where process_name in (select gubun1 from soe.ogg_conf where keya = 'DISTPATH') " \
                    " and call_time = (select call_time from soe.restmon where process_name = 'DUMMY_BASE_TIMESTAMP') " \


            cursor.execute(sql)
            out_data = cursor.fetchall()

            for row in out_data:
            #    #f.labels(sga_used=row[0]).inc(1)
                i.labels(call_time=row[0], process_name=row[1] , status=row[2], lag=row[3], sincelagreported=row[4], in_prefix=row[5], in_seq=row[6], in_rba=row[7], out_prefix=row[8], out_seq=row[9], out_rba=row[10]).inc(1)

            time.sleep(frequency)

