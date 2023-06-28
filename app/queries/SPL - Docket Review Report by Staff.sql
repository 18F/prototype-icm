/*-------------------------------------------------------------------------------------------------------*/ /*   Report Name Used In ICM: CRTSPL006BYUSER                                                            */ /*   Name: Docket Review Report by Staff                                                                 */ /*   Description:  This query is used to generate Attornerys and Lead Attorneys assignments to           */ /*   case and matters.   Also it shows other staff assigned to the case or matter.                       */ /*  Last Modified: April 18, 2003                                                                        */ /*-------------------------------------------------------------------------------------------------------*/

SELECT DISTINCT
X.DJ_NUMBER ,
X.CASE_NAME ,
X.ATTORNEY ,
ICMR.Multi_Row('SELECT A.protected_class'|| '||dECODE(  A.protected_class_dep,NULL, A.protected_class_dep,  '' - ''|| A.protected_class_dep) '|| ' from crtprclass A where parent_type = ''ICM'''|| ' and victim_id is null '|| ' and matter_no ='||to_char(X.matter_no)) PROTECTED_CLASS ,
S.Crt_Stage_code ,
S.Docket_no ,
ICMR.Multi_Row('SELECT A.case_type_code  from crtcasetypes A where matter_no ='||to_char(X.matter_no)) cs_ty ,
ICMR.Multi_Row('SELECT A.CLAIM_OUTCOME from CRDCLAIMS A where matter_no ='||to_char(X.matter_no)) OUTCOME ,
ICMR.Multi_Row('SELECT A.subject_type from crdcssubject A where matter_no ='||to_char(X.matter_no)) Issues ,
ICMR.Multi_Row('SELECT Distinct A2.ACTIVITY_CODE FROM CRTACT A2, CRDSTAGE S2 where S2.matter_no='||to_char(X.matter_no)|| ' and A2.stage_id = S2.stage_id and S2.stage_id = '||to_char(S.stage_id) ) ACTIVITIES ,
ICMR.Multi_Row('select PM.last_name '|| '||'' - ''|| s2.position ' || ' from PM, CRTSTAFF S2 where S2.matter_no = '||to_char(X.matter_no)|| ' and S2.parent_type = ''ICM'' '|| ' and S2.end_date is null ' || /*	' and S2.position <> ''ATTY'' '   || */ ' and PM.empl_id = S2.staff_id ') Staff
FROM
(SELECT A.statute,
        A.crtsort_dist,
        A.crtsort_distlet,
        A.sequence,
        A.district,
        A.matter_no,
        A.dj_number,
        A.case_name,
        A.Case_Status,
        C.last_name ATTORNEY
 FROM crdmain A,
      crtstaff B,
      PM C
 WHERE /*		decode(B.position(+),'ATTY', 'Y', 'LA', 'Y', 'N') = 'Y' and */ B.end_date(+) IS NULL
   AND B.parent_type(+) = 'ICM'
   AND A.CLOSED_DT IS NULL
   AND A.CASE_MATTER <> 'D'
   AND A.section='SPL'
   AND B.staff_id = upper('{?staff_id}')
   AND A.matter_no = B.matter_no(+)
   AND b.staff_id = C.empl_id(+) ) X,
(SELECT B.matter_no ,
        B.stage_id,
        B.crt_stage_code,
        B.Docket_no
 FROM crdstage B
 WHERE exists
     (SELECT 1
      FROM crdmain A
      WHERE A.section = 'SPL'
        AND A.CLOSED_DT IS NULL
        AND A.CASE_MATTER <> 'D'
        AND A.matter_no = B.matter_no)
   AND NVL(B.STAGE_ID, 0) =
     (SELECT NVL(ICM_RETURN.LAST_STAGE_ID(B.MATTER_NO), 0)
      FROM LPCOL) ) S
WHERE X.MATTER_NO = S.MATTER_NO (+)
ORDER BY 3,
         to_number(substr(X.dj_number, 1 ,instr(X.dj_number , '-')-1)) ,
         TO_NUMBER(TRANSLATE(substr(X.dj_number, instr(X.dj_number , '-')+1, instr(X.dj_number, '-',1,2)-instr(X.dj_number , '-')-1), 'CEMNS',' ')) ,
         ltrim(translate(substr(X.dj_number, instr(X.dj_number , '-')+1, instr(X.dj_number, '-',1,2)-instr(X.dj_number , '-')-1),'0123456789',' ')) ,
         LPAD(substr(X.dj_number, instr(X.dj_number, '-',1,2)+1),3,'0')
