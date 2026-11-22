-- Flink SQL Job: Kafka CFUND_DT → Iceberg (MinIO S3 저장)

-- Iceberg REST Catalog (MinIO 백엔드)
CREATE CATALOG iceberg_catalog WITH (
  'type'                    = 'iceberg',
  'catalog-type'            = 'rest',
  'uri'                     = 'http://172.28.0.36:8181',
  'io-impl'                 = 'org.apache.iceberg.aws.s3.S3FileIO',
  's3.endpoint'             = 'http://172.28.0.38:9000',
  's3.access-key-id'        = 'admin',
  's3.secret-access-key'    = 'WElcome1234##',
  's3.path-style-access'    = 'true',
  'client.region'           = 'us-east-1'
);

CREATE DATABASE IF NOT EXISTS iceberg_catalog.insurance;

-- Iceberg 테이블 (op_gubun으로 파티셔닝)
CREATE TABLE IF NOT EXISTS iceberg_catalog.insurance.cfund_transactions (
  ingestion_time TIMESTAMP(6),
  op_type        STRING,
  op_ts          STRING,
  cust_id        BIGINT,
  fund_code      STRING,
  fund_name      STRING,
  fund_amt       BIGINT,
  op_gubun       STRING,
  op_label       STRING,
  op_gubun2      STRING,
  dt             STRING
) PARTITIONED BY (op_gubun)
WITH (
  'format-version'               = '2',
  'write.target-file-size-bytes' = '67108864'
);

-- Kafka Source (별도 consumer group)
CREATE TABLE cfund_iceberg_source (
  `table`   STRING,
  op_type   STRING,
  op_ts     STRING,
  pos       STRING,
  `after`   ROW<
    DT       STRING,
    CUST_ID  BIGINT,
    FUND_CODE STRING,
    FUND_NAME STRING,
    FUND_AMT  BIGINT,
    OP_GUBUN  STRING,
    OP_GUBUN2 STRING,
    CNT       BIGINT
  >,
  proc_time AS PROCTIME()
) WITH (
  'connector'                    = 'kafka',
  'topic'                        = 'FREEPDB1.SOE.CFUND_DT',
  'properties.bootstrap.servers' = '172.28.0.11:9092',
  'properties.group.id'          = 'flink-iceberg-consumer',
  'scan.startup.mode'            = 'latest-offset',
  'format'                       = 'json',
  'json.ignore-parse-errors'     = 'true'
);

-- Kafka → Iceberg 스트리밍 적재
INSERT INTO iceberg_catalog.insurance.cfund_transactions
SELECT
  PROCTIME()          AS ingestion_time,
  op_type,
  op_ts,
  `after`.CUST_ID     AS cust_id,
  `after`.FUND_CODE   AS fund_code,
  `after`.FUND_NAME   AS fund_name,
  `after`.FUND_AMT    AS fund_amt,
  `after`.OP_GUBUN    AS op_gubun,
  CASE `after`.OP_GUBUN
    WHEN '1' THEN '정기납입'
    WHEN '2' THEN '추가납입'
    WHEN '3' THEN '중도인출'
    WHEN '4' THEN '펀드변경'
    WHEN '5' THEN '해약'
    WHEN '6' THEN '신계약'
    ELSE '기타'
  END                 AS op_label,
  `after`.OP_GUBUN2   AS op_gubun2,
  `after`.DT          AS dt
FROM cfund_iceberg_source
WHERE op_type = 'I' AND `after` IS NOT NULL;
