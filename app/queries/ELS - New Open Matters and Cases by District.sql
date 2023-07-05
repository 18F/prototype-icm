SELECT DISTINCT
  CRDMAIN.DJ_NUMBER,
  CRDMAIN.MATTER_NO,
  CRDMAIN.CASE_NAME,
  CRDMAIN.DT_INITIATED,
  CRDMAIN.DISTRICT,
  CRDMAIN.CRT_NEXT_ACTION,
  CRDMAIN.STATUTE,
  CRDMAIN.CRTSORT_DIST,
  CRDMAIN.CRTSORT_DISTLET,
  CRDMAIN.SEQUENCE,
  (SELECT CRT_STAGE_CODE
   FROM CRDSTAGE
   WHERE STAGE_ID = ICM_RETURN.LAST_STAGE_ID(CRDMAIN.MATTER_NO)) STAGE_CODE,
  (SELECT SHORT_DSC
   FROM CD
   WHERE TABLE_ID = 'DIST'
     AND CODE_ID = CRDMAIN.DISTRICT) DISTRICT_DESC,
                                     SF_STATUTE(CRDMAIN.MATTER_NO,'N',6) STATUTE_CODE,
                                     ICMR.Multi_Row('select PM.last_name'|| '||'' - ''||s2.position' || ' from PM, CRTSTAFF S2 where S2.matter_no = '||to_char(crdmain.matter_no)|| ' and S2.parent_type(+) = ''ICM'' '|| ' and S2.end_date is null ' || ' and PM.empl_id(+) = S2.staff_id ') Staff_data
FROM CRDMAIN
WHERE CRDMAIN.DT_INITIATED <= TO_DATE('{{ date }}','MM/DD/YYYY')
  AND CRDMAIN.CASE_MATTER <> 'D'
  AND CRDMAIN.SECTION = 'ELS'
  AND CRDMAIN.CLOSED_DT IS NULL
