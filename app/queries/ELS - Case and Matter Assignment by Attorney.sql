SELECT DISTINCT X.statute,
                X.crtsort_dist,
                X.crtsort_distlet,
                X.sequence,
                X.DJ_NUMBER,
                X.CASE_NAME,
                X.ATTORNEY,
                X.Position,
                ICMR.Multi_Row('select RPAD(PM.last_name,15)'|| ' from PM, CRTSTAFF S2 where S2.matter_no = '||to_char(X.matter_no)|| ' and S2.parent_type = ''ICM'' '|| ' and S2.end_date is null ' || ' and S2.position IN ( ''DPRV'',''REV'') ' || ' and PM.empl_id = S2.staff_id ') REVIEWER ,
                S.Stage ,
                X.crt_next_action
FROM
  (SELECT A.statute,
          A.crtsort_dist,
          A.crtsort_distlet,
          A.sequence,
          A.district,
          A.matter_no,
          A.dj_number,
          A.case_name,
          A.crt_next_action,
          C.last_name||', '||First_name ATTORNEY,
          b.position
   FROM crdmain A,
        crtstaff B,
        PM C
   WHERE b.staff_id IS NOT NULL
     AND b.staff_id LIKE upper('{{ staff_id }}')
     AND B.end_date(+) IS NULL
     AND B.parent_type(+) = 'ICM'
     AND A.CLOSED_DT IS NULL
     AND A.CASE_MATTER IN ('C',
                           'M')
     AND A.section='ELS'
     AND A.matter_no = B.matter_no(+)
     AND b.staff_id = C.empl_id(+) ) X,
  (SELECT B.matter_no ,
          B.crt_stage_code,
          C.short_dsc Stage
   FROM crdstage B,
        CD C
   WHERE exists
       (SELECT 1
        FROM crdmain A
        WHERE A.section = 'ELS'
          AND A.CLOSED_DT IS NULL
          AND A.CASE_MATTER IN ('C','M')
          AND A.matter_no = B.matter_no)
     AND c.table_id = 'STAGE'
     AND c.style_group IN (6,
                           0)
     AND C.code_id = b.crt_stage_code
     AND NVL(B.STAGE_ID, 0) =
       (SELECT NVL(ICM_RETURN.LAST_STAGE_ID(B.MATTER_NO), 0)
        FROM LPCOL) ) S
WHERE X.MATTER_NO = S.MATTER_NO (+)
ORDER BY X.Attorney,
         X.statute,
         X.crtsort_dist,
         X.crtsort_distlet,
         X.sequence
