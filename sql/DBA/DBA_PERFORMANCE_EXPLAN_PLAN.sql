-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # Performance Analysis of SQL Execution Plans                #
prompt ##############################################################
col sql_text for a50
col status for a50
col PLAN_EXPLANATION for a100

WITH samples AS (
-- Retrieves historical statistics of SQLs, including those triggered by "DBMS_SCHEDULER", from the last 20 days
-- This selects SQLs with execution count greater than zero
-- The data is joined with sql_id and plan hash values.
SELECT * FROM dba_hist_sqlstat st
JOIN dba_hist_snapshot sn USING (snap_id, instance_number)
WHERE executions_delta > 0
AND begin_interval_time BETWEEN sysdate - 20 
AND sysdate), -- Last 20 days
sql_ids AS (
-- Filters SQLs with more than 3 distinct execution plans.
-- Counts the number of distinct plan hash values per sql_id and selects those with more than 3 different plans.
SELECT sql_id
  , COUNT(DISTINCT plan_hash_value) plancount
FROM samples
GROUP BY sql_id
HAVING COUNT(DISTINCT plan_hash_value) > 3), -- SQLs with more than 3 different plans
plan_stats AS (
-- Collects statistics based on sql_id and plan hash values.
-- It calculates the number of snapshots, total executions, and average elapsed time for each plan.
SELECT sql_id
  , plan_hash_value
  , COUNT(snap_id) snap_count
  , MAX(end_interval_time) last_seen
  , SUM(executions_delta) total_execs
  , SUM(elapsed_time_delta) / SUM(executions_delta) elapsed_per_exec_thisplan
FROM sql_ids
JOIN samples USING (sql_id)
GROUP BY sql_id, plan_hash_value),
elapsed_time_diffs AS (
-- Calculates the elapsed time differences and ratios.
-- It computes the difference between the last observation and the first observation for each plan.
SELECT p.*
  , elapsed_per_exec_thisplan - FIRST_VALUE(elapsed_per_exec_thisplan) OVER (PARTITION BY sql_id ORDER BY last_seen DESC) elapsed_per_exec_diff
  , (elapsed_per_exec_thisplan - FIRST_VALUE(elapsed_per_exec_thisplan) OVER (PARTITION BY sql_id ORDER BY last_seen DESC)) / elapsed_per_exec_thisplan elapsed_per_exec_diff_ratio
FROM plan_stats p), impacted_sql_ids AS (
-- Selects SQL plans with differences greater than 20%. This is used to examine performance changes.
SELECT * FROM elapsed_time_diffs
WHERE ABS(elapsed_per_exec_diff_ratio) > 0.2), -- Differences greater than 20%
all_info AS (
-- Gathers more information about SQL plans: previous plans, explanations, and plan times
SELECT sql_id
  , plan_hash_value
  , snap_count
  , last_seen
  , LAG(last_seen) OVER (PARTITION BY sql_id ORDER BY last_seen DESC) prev_plan_seen
  , elapsed_per_exec_thisplan
  , ROUND(MAX(ABS(elapsed_per_exec_diff_ratio)) OVER (PARTITION BY sql_id), 2) * 100 max_abs_diff
  , ROUND(MAX(elapsed_per_exec_diff_ratio) OVER (PARTITION BY sql_id), 2) * 100 max_diff
  , 'select * from table(dbms_xplan.display_awr(sql_id=>''' || sql_id || ''', plan_hash_value=>' || plan_hash_value || '));' xplan
  , MAX(plan_hash_value) OVER (PARTITION BY sql_id ORDER BY last_seen DESC) AS current_plan_hash
  , FIRST_VALUE(elapsed_per_exec_thisplan) OVER (PARTITION BY sql_id ORDER BY last_seen DESC) AS first_elapsed_per_exec
FROM elapsed_time_diffs
WHERE sql_id IN (SELECT sql_id FROM impacted_sql_ids))
-- Main query to finalize results and provide query text, SQL plan explanations, and time differences
SELECT a.sql_id AS sql_id
  , a.current_plan_hash AS current_plan_hash -- Current plan hash value
  , t.sql_text AS sql_text -- SQL_TEXT
  , a.snap_count AS snapshot_count
  , TO_CHAR(a.last_seen, 'YYYY-MM-DD hh24:mi:ss') AS last_seen
  , TO_CHAR(a.prev_plan_seen, 'YYYY-MM-DD hh24:mi:ss') AS previous_plan_seen
  , CASE WHEN a.elapsed_per_exec_thisplan < a.first_elapsed_per_exec 
    THEN ROUND(((a.first_elapsed_per_exec - a.elapsed_per_exec_thisplan) / a.first_elapsed_per_exec) * 100, 2) || '% better plan found (current plan: ' || a.current_plan_hash || ')'
    ELSE ROUND(((a.elapsed_per_exec_thisplan - a.first_elapsed_per_exec) / a.first_elapsed_per_exec) * 100, 2) || '% worse plan found (current plan: ' || a.current_plan_hash || ')' END AS status
  , a.xplan AS plan_explanation
FROM all_info a
JOIN dba_hist_sqltext t ON a.sql_id = t.sql_id
WHERE a.plan_hash_value = a.current_plan_hash
ORDER BY a.sql_id, a.last_seen DESC;