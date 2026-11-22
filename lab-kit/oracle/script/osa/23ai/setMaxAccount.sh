sqlplus -s soe/soe@orclpdb1 << EOF
update soe.cust_info 
set email = 'yong.seok.choi@oracle.com',
    cust_nm = '방수현'
where cust_id = 
    (
        select cust_id
        from
        (
            select rownum id, cust_id
            from
            (
                select a.*
                from 
                (
                    select cust_id, count(distinct op_gubun) cnt
                    from soe.cfund_dt
                    group by cust_id
                ) a
                order by cnt desc
            )
        )
        where id = 1
    )
;
commit;
EOF
