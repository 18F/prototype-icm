
SELECT X.last_name,
       X.type,
       X.dj_number,
       X.case_name,
       X.wktp_code,
       Sum(X.hours)
FROM
  (SELECT b.short_name last_name ,
          b.pos_code TYPE ,
                     decode(a.dj_number, NULL,
                              (SELECT dj_number
                               FROM crtspecialdj
                               WHERE matter_no = B.Other_DJ_id
                                 AND rownum = 1), a.dj_number) DJ_number ,
                     decode(a.case_name, NULL,
                              (SELECT case_name
                               FROM crtspecialdj
                               WHERE matter_no = B.Other_DJ_id
                                 AND rownum = 1), a.case_name) case_name ,
                     wktp_code,
                     hours
   FROM crdmain A,
        V_ICM_CHARGE_HOURS B
   WHERE B.section_code LIKE '{?section}' --and   b.wktp_code not in ('AWS','LEAVE')

     AND nvl(b.wktp_code, ' ') NOT IN ('LEAVE',
                                       'AWS')
     AND b.DJ_file_id = a.matter_no(+)
     AND b.work_date BETWEEN to_date('{?date1}','MM/DD/RRRR') AND to_date('{?date2}' ,'MM/DD/RRRR')) X
WHERE X.dj_number = upper('{?dj_number}')
GROUP BY X.last_name,
         X.TYPE,
         X.dj_number,
         X.case_name,
         X.wktp_code
ORDER BY x. TYPE,
         X.LAST_NAME,
         X.WKTP_CODE
