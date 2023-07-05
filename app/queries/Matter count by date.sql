SELECT COUNT(*) FROM CRDMAIN
WHERE CRT_OPEN_DATE >= date '{{ start_date }}'
  AND CRT_OPEN_DATE <= date '{{ end_date }}'
