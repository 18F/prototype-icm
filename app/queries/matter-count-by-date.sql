SELECT COUNT(*) FROM "CRDMAIN"
WHERE "CRT_OPEN_DATE" >= '{{ start_date }}'
  AND "CRT_OPEN_DATE" <= '{{ end_date }}'
;
