-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
DEF days_of_history_accessed = '31';
DEF captured_at_least_x_times = '10';
DEF captured_at_least_x_days_apart = '5';
DEF med_elap_microsecs_threshold = '1e4';
DEF min_slope_threshold = '0.1';
DEF max_num_rows = '20';
SET lin 200 ver OFF;
COL SLOPE for a15
COL row_n FOR A2 HEA '#';
COL med_secs_per_exec HEA 'Median Secs|Per Exec' for a20;
COL std_secs_per_exec HEA 'Std Dev Secs|Per Exec';
COL avg_secs_per_exec HEA 'Avg Secs|Per Exec';
COL min_secs_per_exec HEA 'Min Secs|Per Exec';
COL max_secs_per_exec HEA 'Max Secs|Per Exec';
COL plans FOR 9999;
COL sql_text_80 FOR A75;
prompt
prompt ##############################################################
prompt # SQL Statements with "Elapsed Time per Execution" changing over time
prompt ##############################################################
WITH
per_time AS (
select h.dbid
   , h.sql_id
   , SYSDATE - CAST(s.end_interval_time AS DATE) days_ago
   , SUM(h.elapsed_time_total) / SUM(h.executions_total) time_per_exec
FROM  dba_hist_sqlstat h, dba_hist_snapshot s
WHERE h.executions_total > 0
AND s.snap_id = h.snap_id
AND s.dbid = h.dbid
AND s.instance_number = h.instance_number
AND CAST(s.end_interval_time AS DATE) > SYSDATE - &&days_of_history_accessed
GROUP BY h.dbid, h.sql_id, SYSDATE - CAST(s.end_interval_time AS DATE)),
avg_time AS (
select dbid
   , sql_id
   , MEDIAN(time_per_exec) med_time_per_exec
   , STDDEV(time_per_exec) std_time_per_exec
   , AVG(time_per_exec)    avg_time_per_exec
   , MIN(time_per_exec)    min_time_per_exec
   , MAX(time_per_exec)    max_time_per_exec
FROM per_time
GROUP BY dbid, sql_id
HAVING COUNT(*) >= &&captured_at_least_x_times
AND MAX(days_ago) - MIN(days_ago) >= &&captured_at_least_x_days_apart
AND MEDIAN(time_per_exec) > &&med_elap_microsecs_threshold),
time_over_median AS (
select h.dbid
   ,  h.sql_id
   ,  h.days_ago
   ,  (h.time_per_exec / a.med_time_per_exec) time_per_exec_over_med
   ,  a.med_time_per_exec
   ,  a.std_time_per_exec
   ,  a.avg_time_per_exec
   ,  a.min_time_per_exec
   ,  a.max_time_per_exec
FROM per_time h, avg_time a WHERE a.sql_id = h.sql_id),
ranked AS (
select RANK () OVER (ORDER BY ABS(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago)) DESC) rank_num
   ,  t.dbid
   ,  t.sql_id
   ,  CASE WHEN REGR_SLOPE(t.time_per_exec_over_med, t.days_ago) > 0 THEN 'IMPROVING' ELSE 'REGRESSING' END change
   ,  ROUND(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago), 3) slope
   ,  ROUND(AVG(t.med_time_per_exec)/1e6, 3) med_secs_per_exec
   ,  ROUND(AVG(t.std_time_per_exec)/1e6, 3) std_secs_per_exec
   ,  ROUND(AVG(t.avg_time_per_exec)/1e6, 3) avg_secs_per_exec
   ,  ROUND(MIN(t.min_time_per_exec)/1e6, 3) min_secs_per_exec
   ,  ROUND(MAX(t.max_time_per_exec)/1e6, 3) max_secs_per_exec
FROM time_over_median t
GROUP BY t.dbid, t.sql_id
HAVING ABS(REGR_SLOPE(t.time_per_exec_over_med, t.days_ago)) > &&min_slope_threshold)
select LPAD(ROWNUM, 2) row_n
   ,  r.sql_id
   ,  r.change
   ,  TO_CHAR(r.slope, '990.000MI') slope
   ,  TO_CHAR(r.med_secs_per_exec, '999,990.000') med_secs_per_exec
   ,  TO_CHAR(r.std_secs_per_exec, '999,990.000') std_secs_per_exec
   ,  TO_CHAR(r.avg_secs_per_exec, '999,990.000') avg_secs_per_exec
   ,  TO_CHAR(r.min_secs_per_exec, '999,990.000') min_secs_per_exec
   ,  TO_CHAR(r.max_secs_per_exec, '999,990.000') max_secs_per_exec
   ,  (select COUNT(DISTINCT p.plan_hash_value) FROM dba_hist_sql_plan p WHERE p.dbid = r.dbid AND p.sql_id = r.sql_id) plans
--  ,  REPLACE((select DBMS_LOB.SUBSTR(s.sql_text, 80) FROM dba_hist_sqltext s WHERE s.dbid = r.dbid AND s.sql_id = r.sql_id), CHR(10)) sql_text_80
FROM ranked r
WHERE r.rank_num <= &&max_num_rows
ORDER BY r.rank_num
/