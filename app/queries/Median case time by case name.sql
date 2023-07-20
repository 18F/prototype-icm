WITH matter_hours AS (
  SELECT
    matters.matter_no,
    matters.closed_dt,
    matters.crt_open_date,
    matters.closed_dt - matters.crt_open_date total_days,
    SUM(hours.hours) total_hours
  FROM
    crdmain matters,
    V_ICM_CHARGE_HOURS hours
  WHERE
    -- Searches for cases by name
    matters.case_name LIKE '%{? case_name_search }%' AND
    hours.dj_file_id = matters.matter_no(+) AND
    matters.matter_no IS NOT NULL AND
    hours.dj_file_id IS NOT NULL
  GROUP BY
    matters.matter_no,
    matters.closed_dt,
    matters.crt_open_date
  ORDER BY total_hours
)
SELECT
  ROUND(AVG(matter_hours.total_hours)) "Average hours",
  ROUND(MEDIAN(matter_hours.total_hours)) "Median hours",
  ROUND(AVG(matter_hours.total_days)) "Average days",
  ROUND(MEDIAN(matter_hours.total_days)) "Median days"
FROM
  matter_hours
WHERE
  -- Only looks for cases with more than 80 hours billed
  --   and more than 14 days between open and closed.
  matter_hours.total_hours > 80 AND
  matter_hours.total_days > 14
