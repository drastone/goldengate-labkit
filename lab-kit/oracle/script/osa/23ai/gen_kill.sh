sqlplus -s / as sysdba << EOF

set escape on ;
set serveroutput on;
BEGIN
    -- 결과만큼 반복할 SQL 구문을 작성하고 별칭을 CUR로 부여
    FOR CUR IN (

	SELECT --A.LOGON_TIME , A.SID , A.SERIAL# , A.USERNAME , A.SCHEMANAME , A.MACHINE , A.TERMINAL ,A.PROGRAM , A.MODULE , A.CLIENT_INFO,
	--'ALTER SYSTEM KILL SESSION '''||A.SID||','||A.SERIAL#||''';' AS KILLSCRIPT 
	'ALTER SYSTEM KILL SESSION '''||A.SID||','||A.SERIAL#||'''' AS KILLSCRIPT 
	FROM V\$SESSION A
	where a.module = 'SQL*Plus'
	ORDER BY A.LOGON_TIME
	--;  -- ; 이 없어야 한다.

    )
    LOOP
        BEGIN
            -- 조회된 구문 실행
            --EXECUTE IMMEDIATE CUR.DDL;
	    DBMS_OUTPUT.PUT_LINE('KILLSCRIPT : ' || CUR.KILLSCRIPT);
            EXECUTE IMMEDIATE CUR.KILLSCRIPT;
	    DBMS_OUTPUT.PUT_LINE('KILLSCRIPT : DONE' );
        EXCEPTION
            -- 예외 발생 시 아무작업을 하지 않음
            WHEN OTHERS THEN
      		DBMS_OUTPUT.PUT_LINE('오류가 발생했습니다');
      		DBMS_OUTPUT.PUT_LINE('SQL ERROR CODE:' || SQLCODE);
      		DBMS_OUTPUT.PUT_LINE('SQL ERROR MESSAGE:' || SQLERRM); -- 매개변수 없는 SQLERRM
      		DBMS_OUTPUT.PUT_LINE( SQLERRM(SQLCODE)); -- 매개변수 있는 SQLERRM
	    	DBMS_OUTPUT.PUT_LINE('KILLSCRIPT : FAILED' );
                NULL;
        END;  
    END LOOP;  
END;
/
EOF
