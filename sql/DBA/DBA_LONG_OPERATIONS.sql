-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 12/08/2025
-- DateModification.: 12/08/2025
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net


-- Oracle SQL Script to Monitor Top 10 Performance Metrics:
-- 1. Long-Running Operations
-- 2. SQL Statement Performance
-- 3. I/O Performance
-- 4. Network Usage
-- 5. Execution Plans for Top SQL
-- 6. CPU Usage
-- 7. Memory Utilization (SGA and PGA)
-- 8. Wait Events
-- 9. Locking and Contention
-- 10. Buffer Cache and Redo Log Performance
-- 11. Script to Monitor Current Long-Running Operations with Details

set feedback off timing off
ALTER SESSION SET nls_date_format='YYYY-MM-DD hh24:mi:ss';
set pages 2000 lines 2000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on SERVEROUTPUT ON SIZE UNLIMITED colsep '|'
prompt ##############################################################
prompt # Oracle SQL Script to Monitor Long Operations
prompt # Top 10 Worst Statements, Top 10 Worst IO, and Execution Plans for Top 10 Worst SQL IDs
prompt ##############################################################

-- Section 1: Long-Running Operations
PROMPT 
PROMPT ##############################################################
PROMPT # 1. Long-Running Operations
PROMPT ##############################################################
SELECT s.sid
  , s.serial#
  , lo.opname
  , lo.target
  , lo.sofar
  , lo.totalwork
  , ROUND(lo.sofar / lo.totalwork * 100, 2) AS percent_complete
  , lo.elapsed_seconds
  , lo.time_remaining
  , lo.message
FROM v$session_longops lo
JOIN v$session s ON lo.sid = s.sid AND lo.serial# = s.serial#
WHERE lo.totalwork > lo.sofar
ORDER BY lo.time_remaining DESC;

-- Section 2: Top 10 Worst Statements (by Total Elapsed Time)
PROMPT 
PROMPT ##############################################################
PROMPT # 2. Top 10 Worst Statements by Total Elapsed Time
PROMPT ##############################################################
COLUMN sql_text FORMAT A90 WORD_WRAP
SELECT sql_id
  , executions
  , elapsed_time / 1000000 AS elapsed_seconds
  , cpu_time / 1000000 AS cpu_seconds
  , disk_reads
  , buffer_gets
  , sql_text
FROM v$sqlarea
ORDER BY elapsed_time DESC
FETCH FIRST 10 ROWS ONLY;

-- Section 3: Top 10 Worst I/O (by Total Physical Disk Reads)
PROMPT 
PROMPT ##############################################################
PROMPT # 3. Top 10 Worst I/O by Total Disk Reads
PROMPT ##############################################################
COLUMN sql_text FORMAT A90 WORD_WRAP
SELECT 
    sql_id,
    executions,
    disk_reads,
    buffer_gets,
    elapsed_time / 1000000 AS elapsed_seconds,
    sql_text
FROM 
    v$sqlarea
ORDER BY 
    disk_reads DESC
FETCH FIRST 10 ROWS ONLY;

-- Section 4: Top 10 Worst Network Usage (by Total Bytes)
PROMPT 
PROMPT ##############################################################
PROMPT # 4. Top 10 Worst Network Usage by Total Bytes
PROMPT ##############################################################
COLUMN sql_text FORMAT A90 WORD_WRAP
SELECT s.sid
  , s.serial#
  , s.sql_id
  , MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes sent via SQL*Net to client') THEN st.value END) AS bytes_sent
  , MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes received via SQL*Net from client') THEN st.value END) AS bytes_received
  , (MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes sent via SQL*Net to client') THEN st.value END) +
     MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes received via SQL*Net from client') THEN st.value END)) AS total_network_bytes
  , ROUND((SYSDATE - s.sql_exec_start) * 24 * 3600, 2) AS elapsed_seconds
  , sa.sql_text
FROM v$session s
JOIN v$sesstat st ON s.sid = st.sid
LEFT JOIN v$sqlarea sa ON s.sql_id = sa.sql_id
WHERE s.sql_id IS NOT NULL
AND st.statistic# IN ((SELECT statistic# FROM v$statname WHERE name = 'bytes sent via SQL*Net to client')
                    , (SELECT statistic# FROM v$statname WHERE name = 'bytes received via SQL*Net from client'))
GROUP BY s.sid, s.serial#, s.sql_id, s.sql_exec_start, sa.sql_text
HAVING (MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes sent via SQL*Net to client') THEN st.value END) +
        MAX(CASE WHEN st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'bytes received via SQL*Net from client') THEN st.value END)) > 0
ORDER BY total_network_bytes DESC
FETCH FIRST 10 ROWS ONLY;

-- Section 5: Execution Plans for Top 10 Worst SQL IDs (by Total Elapsed Time)
PROMPT 
PROMPT ##############################################################
PROMPT # 5. Execution Plans for Top 10 Worst SQL IDs by Total Elapsed Time
PROMPT ##############################################################
DECLARE
  TYPE sql_id_tab IS TABLE OF v$sqlarea.sql_id%TYPE;
  sql_ids sql_id_tab;
BEGIN
  -- Collect top 10 SQL IDs by elapsed time
  SELECT sql_id
  BULK COLLECT INTO sql_ids
  FROM (SELECT sql_id FROM v$sqlarea ORDER BY elapsed_time DESC FETCH FIRST 10 ROWS ONLY);

  -- Loop through each SQL ID and display its execution plan
  FOR i IN 1..sql_ids.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('===================================================================');
    DBMS_OUTPUT.PUT_LINE('Execution Plan for SQL_ID: ' || sql_ids(i));
    DBMS_OUTPUT.PUT_LINE('===================================================================');
      
    FOR rec IN 
      (SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(sql_ids(i), NULL, 'ALL'))) LOOP DBMS_OUTPUT.PUT_LINE(rec.plan_table_output);
    END LOOP;
      DBMS_OUTPUT.PUT_LINE(CHR(10)); -- Add some spacing between plans
    END LOOP;
END;
/

-- Section 6: Top 10 CPU Usage by Session
PROMPT 
PROMPT ##############################################################
PROMPT # 6. Top 10 Sessions by CPU Usage
PROMPT ##############################################################
COLUMN username FORMAT A20
COLUMN program FORMAT A40
SELECT s.sid
  , s.serial#
  , s.username
  , s.program
  , MAX(st.value) / 1000000 AS cpu_seconds
FROM v$session s
JOIN v$sesstat st ON s.sid = st.sid
WHERE st.statistic# = (SELECT statistic# FROM v$statname WHERE name = 'CPU used by this session')
GROUP BY s.sid, s.serial#, s.username, s.program
ORDER BY cpu_seconds DESC
FETCH FIRST 10 ROWS ONLY;

-- Section 7: Memory Utilization (SGA and PGA)
PROMPT 
PROMPT ##############################################################
PROMPT # 7. Memory Utilization (SGA and PGA)
PROMPT ##############################################################
PROMPT SGA Utilization
SELECT name
  , ROUND(bytes / 1024 / 1024, 2) AS size_mb
  , ROUND(bytes / (SELECT SUM(bytes) FROM v$sgastat) * 100, 2) AS percent_of_total
FROM v$sgastat
WHERE name IN ('free memory', 'buffer_cache', 'shared pool', 'large pool', 'java pool')
ORDER BY bytes DESC;

PROMPT PGA Utilization
col name for a30
SELECT name
  , ROUND(value / 1024 / 1024, 2) AS size_mb
FROM v$pgastat
WHERE name IN ('aggregate PGA target parameter', 'total PGA allocated', 'total PGA used by SQL workareas')
ORDER BY value DESC;

-- Section 8: Top 10 Wait Events
PROMPT 
PROMPT ##############################################################
PROMPT # 8. Top 10 Wait Events
PROMPT ##############################################################
SELECT event
  , total_waits
  , time_waited / 100 AS time_waited_seconds
  , ROUND(time_waited / total_waits, 2) AS avg_wait_ms
FROM v$system_event
WHERE wait_class != 'Idle'
ORDER BY time_waited DESC
FETCH FIRST 10 ROWS ONLY;

-- Section 9: Locking and Contention
PROMPT 
PROMPT ##############################################################
PROMPT # 9. Blocking Sessions and Locks
PROMPT ##############################################################
COLUMN username FORMAT A20
COLUMN object_name FORMAT A30
SELECT s.sid
  , s.serial#
  , s.username
  , o.object_name
  , l.type AS lock_type
  , l.lmode AS lock_mode
  , s.blocking_session
  , bs.username AS blocking_username
FROM v$session s
JOIN v$lock l ON s.sid = l.sid
LEFT JOIN dba_objects o ON l.id1 = o.object_id
LEFT JOIN v$session bs ON s.blocking_session = bs.sid
WHERE s.blocking_session IS NOT NULL OR l.block = 1
ORDER BY s.blocking_session, s.sid;

-- Section 10: Buffer Cache and Redo Log Performance
PROMPT 
PROMPT ##############################################################
PROMPT # 10. Buffer Cache and Redo Log Performance
PROMPT ##############################################################
col name for a30
col value for a20
PROMPT Buffer Cache Hit Ratio
SELECT name
  , value
  , CASE WHEN name = 'Buffer Cache Hit Ratio' THEN ROUND(value, 2) ELSE NULL END AS cache_hit_ratio_percent
FROM (SELECT name, value, (1 - (SUM(CASE WHEN name = 'physical reads' THEN value ELSE 0 END) / NULLIF(SUM(CASE WHEN name IN ('consistent gets', 'db block gets') THEN value ELSE 0 END), 0))) * 100 AS "Buffer Cache Hit Ratio"
    FROM v$sysstat
    WHERE name IN ('physical reads', 'consistent gets', 'db block gets')
    GROUP BY name, value)
WHERE name IN ('physical reads', 'consistent gets', 'db block gets')
UNION ALL
SELECT 'Buffer Cache Hit Ratio' AS name
  , NULL AS value, ROUND((1 - (SUM(CASE WHEN name = 'physical reads' THEN value ELSE 0 END) / NULLIF(SUM(CASE WHEN name IN ('consistent gets', 'db block gets') THEN value ELSE 0 END), 0))) * 100, 2) AS cache_hit_ratio_percent
FROM v$sysstat
WHERE name IN ('physical reads', 'consistent gets', 'db block gets');


PROMPT Redo Log Switch Frequency
SELECT TO_CHAR(first_time, 'YYYY-MM-DD HH24:MI') AS switch_time
  , sequence#
  , ROUND((first_time - LAG(first_time) OVER (ORDER BY first_time)) * 24 * 60, 2) AS minutes_since_last_switch
FROM v$log_history
WHERE first_time > SYSDATE - 1
ORDER BY first_time DESC
FETCH FIRST 10 ROWS ONLY;

 
PROMPT Redo Write Time
SELECT name
  , ROUND(value / 100, 2) AS redo_write_seconds
FROM v$sysstat
WHERE name = 'redo write time';


-- SQL Script to Monitor Current Long-Running Operations with Details
PROMPT 
PROMPT ##############################################################
PROMPT # 11. Script to Monitor Current Long-Running Operations with Details
PROMPT ##############################################################
COLUMN inst_id FORMAT 9999
COLUMN username FORMAT A15
COLUMN machine FORMAT A20
COLUMN program FORMAT A40
COLUMN opname FORMAT A30
COLUMN target FORMAT A10
COLUMN sql_id FORMAT A13
COLUMN message FORMAT A75
COLUMN percent_complete FORMAT A10        HEADING 'Percent|Completed'
COLUMN elapsed_seconds FORMAT 999999      HEADING 'Elapsed|Seconds'
COLUMN time_remaining_min FORMAT 99999.9  HEADING 'Minutes|Remaining'
COLUMN estimated_total_time FORMAT 999999 HEADING 'Estimated|Total Time'
COLUMN start_time FORMAT A20
COLUMN last_update_time FORMAT A20
SELECT lo.inst_id
  , s.username
  , s.machine
  , s.program
  , lo.sql_id
--  , lo.opname
  , lo.target
  , lo.message
  , ROUND(lo.sofar / lo.totalwork * 100, 2) || '%' AS percent_complete
  , lo.elapsed_seconds
  , ROUND(lo.time_remaining / 60, 1) AS time_remaining_min
  , (lo.elapsed_seconds + lo.time_remaining) AS estimated_total_time
  , lo.start_time
  , lo.last_update_time
FROM gv$session_longops lo
JOIN v$session s ON lo.sid = s.sid AND lo.serial# = s.serial#
WHERE lo.totalwork > lo.sofar  -- Only show operations still in progress
AND (lo.opname LIKE 'RMAN%' AND lo.opname NOT LIKE '%aggregate%' OR lo.opname NOT LIKE 'RMAN%') -- Include RMAN with filter or other operations
ORDER BY lo.time_remaining DESC;
