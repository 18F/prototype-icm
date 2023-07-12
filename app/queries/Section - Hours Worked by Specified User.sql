SELECT X.last_name,
       X.dj_number,
       X.case_name,
       X.wktp_code,
       Sum(X.hours)Hours
FROM
  (SELECT b.short_name last_name ,
          a.dj_number ,
          nvl (a.case_name ,
                 ( SELECT case_name
                  FROM crtspecialdj s
                  WHERE s.matter_no = b.other_dj_id
                    AND rownum <2 ) ) case_name ,
          b.wktp_code,
          hours ,
          b.other_dj_id
   FROM crdmain A,
        V_ICM_CHARGE_HOURS B
   WHERE b.section_code LIKE upper('{?section}')
     AND nvl(b.wktp_code,' ') NOT IN ('AWS',
                                      'LEAVE') --  and   b.wktp_code not in ('AWS','LEAVE')

     AND b.DJ_file_id = a.matter_no(+)
     AND b.staff_id = upper('{?staff_id}')
     AND b.work_date BETWEEN to_date('{?date1}','MM/DD/RRRR') AND to_date('{?date2}' ,'MM/DD/RRRR')) X
GROUP BY X.last_name,
         X.dj_number,
         X.case_name,
         X.wktp_code
ORDER BY x.dj_number
