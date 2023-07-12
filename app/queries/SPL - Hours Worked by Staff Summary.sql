SELECT X.last_name,
       X.dj_number,
       X.case_name,
       X.wktp_code,
       Sum(X.hours)Hours
FROM
  (SELECT b.short_name last_name ,
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
   WHERE b.section_code = 'SPL' --and   b.wktp_code not in ('LEAVE','AWS')

     AND nvl(b.wktp_code, ' ') NOT IN ('LEAVE',
                                       'AWS')
     AND b.DJ_file_id = a.matter_no(+)
     AND b.staff_id LIKE upper('{?staff_id}')
     AND b.work_date BETWEEN to_date('{?date1}','MM/DD/RRRR') AND to_date('{?date2}' ,'MM/DD/RRRR') ) X
GROUP BY X.last_name,
         X.dj_number,
         X.case_name,
         X.wktp_code
