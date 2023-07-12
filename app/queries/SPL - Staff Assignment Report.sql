SELECT dj_number ,
       statute ,
       crtsort_dist ,
       crtsort_distlet ,
       sequence ,
       district ,
       dt_initiated ,
       closed_dt ,
       end_date ,
       max(crt_starting_date) crt_starting_date ,
       stage_desc ,
       case_name ,
       staff
FROM
  (SELECT DISTINCT A.statute, A.crtsort_dist, A.crtsort_distlet, A.sequence, A.district, A.matter_no, A.dj_number, A.case_name, A.dt_initiated, A.Closed_dt, C.short_name Staff, B.end_date ,
     (SELECT short_dsc
      FROM cd
      WHERE table_id='STAGE'
        AND code_id = S.crt_stage_code
        AND style_group in(2,0)) STAGE_desc ,
                                 s.crt_starting_date
   FROM crdmain A,
        crtstaff B,
        PM C,
        Crdstage S
   WHERE A.section='SPL'
     AND A.case_matter <> 'D'
     AND B.Staff_id LIKE UPPER('{?staff_id}')
     AND B.end_date(+) IS NULL
     AND B.parent_type(+) = 'ICM'
     AND a.CLOSED_DT IS NULL
     AND A.matter_no = B.matter_no(+)
     AND b.staff_id = C.empl_id(+)
     AND A.matter_no = S.matter_no(+)
     AND S.STAGE_ID(+) = ICM_RETURN.LAST_STAGE_ID(A.MATTER_NO))X
GROUP BY matter_no ,
         dj_number ,
         statute ,
         crtsort_dist ,
         crtsort_distlet ,
         sequence ,
         district ,
         dt_initiated ,
         closed_dt ,
         stage_desc ,
         case_name ,
         staff ,
         End_date
ORDER BY dj_number /*      Modified report to print max Stage Staring date for as of date instead of   */ /*     initial date as per Glynis Raval  - 09/19/2008 Kiram                        */
