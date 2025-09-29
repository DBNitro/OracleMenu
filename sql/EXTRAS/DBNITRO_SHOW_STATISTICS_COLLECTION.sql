-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.3"
-- DateCreation.....: 10/04/2024
-- DateModification.: 02/09/2025
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'

col object_name for a30
col object_type for a20
col owner for a20
col job_name for a40
col program_name for a50
col last_start_date for a30
col next_run_date for a30
col log_date for a20
col actual_start_date for a20
col duration for a20
col CLIENT_NAME for a40
COL REPEAT_INTERVAL FOR A72
COL ENABLED FOR A10
COL WINDOW_NAME FOR A20
COL WINDOW_DURATION FOR A35 
COL JOB_NAME FOR A30 
COL WINDOW_START_TIME FOR A20 
COL JOB_DURATION FOR A23
COL JOB_INFO FOR A2 
COL JOB_STATUS FOR A10
COL JOB_START_TIME FOR A20
COL CONSUMER_GROUP FOR A25
COL WINDOW_GROUP FOR A15 
COL STATUS FOR A10 

prompt #######################################################################
prompt # VERIFY THE STATUS OF STATISTICS JOBS
prompt #######################################################################
prompt
prompt #######################################################################
prompt # PROGRAM STATISTICS COLLECTION - STANDARD, STALE and FULL CUSTOM
prompt #######################################################################
SELECT owner
  , program_name
  , enabled
FROM DBA_SCHEDULER_PROGRAMS 
WHERE program_name like 'GATHER_%'
order by 1,2,3;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS COLLECTION - STANDARD, STALE and FULL
prompt #######################################################################
SELECT j.owner
  , j.job_name
  , j.state
  , j.run_count
  , TO_CHAR(j.last_start_date, 'YYYY-MM-DD HH24:MI:SS') AS last_start_date
  , TO_CHAR(j.next_run_date, 'YYYY-MM-DD HH24:MI:SS') AS next_run_date
  , CASE WHEN rd.actual_start_date IS NOT NULL AND rd.run_duration IS NOT NULL THEN TRIM(TO_CHAR(EXTRACT(HOUR FROM rd.run_duration), 'FM00')) || ':' || TRIM(TO_CHAR(EXTRACT(MINUTE FROM rd.run_duration), 'FM00')) || ' (HH:MM)' ELSE 'N/A' END AS duration
FROM DBA_SCHEDULER_JOBS j
LEFT JOIN (SELECT job_name, owner, actual_start_date, run_duration FROM DBA_SCHEDULER_JOB_RUN_DETAILS WHERE (owner, job_name, log_date) 
       IN (SELECT owner, job_name, MAX(log_date) FROM DBA_SCHEDULER_JOB_RUN_DETAILS GROUP BY owner, job_name)) rd 
ON j.owner = rd.owner 
AND j.job_name = rd.job_name
WHERE j.job_name LIKE 'GATHER_%'
ORDER BY j.owner, j.job_name, j.state;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS COLLECTION - STANDARD, STALE and FULL - DETAILS I
prompt #######################################################################
SELECT owner
  , job_name
  , TO_CHAR(actual_start_date, 'YYYY-MM-DD hh24:mi:ss') AS actual_start_date
  , LPAD(EXTRACT(HOUR FROM RUN_DURATION), 2, '0') || ':' || LPAD(EXTRACT(MINUTE FROM RUN_DURATION), 2, '0') || ':' || LPAD(EXTRACT(SECOND FROM RUN_DURATION), 2, '0') AS run_duration
  , status
  , error#
FROM DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE job_name LIKE 'GATHER_%'
AND actual_start_date >= SYSTIMESTAMP - INTERVAL '7' DAY
ORDER BY owner, job_name, actual_start_date;

prompt
prompt #######################################################################
prompt # SCHEDULER JOB STATISTICS WINDOW DURATION
prompt #######################################################################
SELECT WINDOW_NAME
  , REPEAT_INTERVAL
  , TO_CHAR(EXTRACT(DAY FROM DURATION),'90') || ' Days ' || TO_CHAR(EXTRACT(HOUR FROM DURATION),'90') || ' Hours ' || TO_CHAR(EXTRACT(MINUTE FROM DURATION),'90') || ' Minutes ' WINDOW_DURATION
  , ENABLED
FROM DBA_SCHEDULER_WINDOWS
order by 1,2,3;

prompt
prompt #######################################################################
prompt # AUTOTASL Jobs History
prompt #######################################################################
SELECT * FROM (SELECT JOB_NAME
                 , CLIENT_NAME
                 , WINDOW_NAME
                 , TO_CHAR(WINDOW_START_TIME,'YYYY-MM-DD HH24:MI:SS') WINDOW_START_TIME
                 , TO_CHAR(EXTRACT(DAY FROM WINDOW_DURATION),'00') || ' Days ' || TO_CHAR(EXTRACT(HOUR FROM WINDOW_DURATION),'00') || ' Hours ' || TO_CHAR(EXTRACT(MINUTE FROM WINDOW_DURATION),'00') || ' Minutes ' WINDOW_DURATION
                 , JOB_STATUS
                 , TO_CHAR(JOB_START_TIME,'YYYY-MM-DD HH24:MI:SS') JOB_START_TIME
                 , TO_CHAR(EXTRACT(DAY FROM JOB_DURATION),'90') || ' D' || TO_CHAR(EXTRACT(HOUR FROM JOB_DURATION),'90') || ' H' || TO_CHAR(EXTRACT(MINUTE FROM JOB_DURATION),'90') || ' M' || TO_CHAR(EXTRACT(SECOND FROM JOB_DURATION),'90') || ' S' JOB_DURATION
                 , JOB_ERROR 
              FROM DBA_AUTOTASK_JOB_HISTORY 
              -- WHERE CLIENT_NAME='auto optimizer stats collection' 
              ORDER BY JOB_START_TIME DESC) 
WHERE ROWNUM < '50'
order by 1,2,3;
