-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
var days_back number;
exec :days_back := 15;
set pages 3000 lines 3000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
set feedback off
col "DATE_TIME" for a20
col host_address for a16
col MESSAGE_TEXT for a140
col total for a80
prompt ##############################################################
prompt # ERRORS ON ALERT LOG FILE
prompt ##############################################################
select to_char(ORIGINATING_TIMESTAMP, 'yyyy-mm-dd HH24:MI:SS') as "DATE_TIME"
  , host_address
  , MESSAGE_TEXT
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%ora-%' 
or lower(MESSAGE_TEXT) like '%error%' 
or lower(MESSAGE_TEXT) like '%checkpoint not complete%' 
or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back
order by ORIGINATING_TIMESTAMP;
prompt
prompt ##############################################################
select '[ GENERAL ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%error%' 
or lower(MESSAGE_TEXT) like '%checkpoint not complete%' 
or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORACLE ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where (lower(MESSAGE_TEXT) like '%ora-%' 
or lower(MESSAGE_TEXT) like '%error%' 
or lower(MESSAGE_TEXT) like '%fail%')
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-00600 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-00600%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-00700 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-00700%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;
prompt
prompt ##############################################################
select '[ ORA-07445 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || count(*) as "Total"
from sys.X$DBGALERTEXT
where MESSAGE_TEXT like '%ORA-07445%'
and ORIGINATING_TIMESTAMP > sysdate-:days_back;

------------------------------------------------------------------------------------------------------------------------

-- set feedback off timing off
-- var days_back number;
-- exec :days_back := 15;
-- -- set pages 3000 lines 3000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
-- SET feedback OFF timing OFF pages 3000 lines 3000 long 9999999 numwidth 20 heading ON echo ON verify ON colsep '|'
-- COL "DATE_TIME" FOR a20
-- COL host_address FOR a16
-- COL MESSAGE_TEXT FOR a140
-- PROMPT ##############################################################
-- PROMPT # ERRORS ON ALERT LOG FILE
-- PROMPT ##############################################################
-- WITH filtered_logs AS (
-- SELECT ORIGINATING_TIMESTAMP
--   , host_address
--   , MESSAGE_TEXT
-- FROM sys.X$DBGALERTEXT 
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back)
-- PROMPT ##############################################################
-- SELECT TO_CHAR(ORIGINATING_TIMESTAMP, 'yyyy-mm-dd HH24:MI:SS') AS "DATE_TIME"
--   , host_address
--   , MESSAGE_TEXT
-- FROM filtered_logs
-- WHERE INSTR(LOWER(MESSAGE_TEXT), 'ora-') > 0
-- OR INSTR(LOWER(MESSAGE_TEXT), 'error') > 0
-- OR INSTR(LOWER(MESSAGE_TEXT), 'checkpoint not complete') > 0
-- OR INSTR(LOWER(MESSAGE_TEXT), 'fail') > 0
-- ORDER BY ORIGINATING_TIMESTAMP;
-- SELECT '[ GENERAL ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || COUNT(*) AS "Total"
-- FROM sys.X$DBGALERTEXT
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back
-- AND (INSTR(LOWER(MESSAGE_TEXT), 'error') > 0 
-- OR INSTR(LOWER(MESSAGE_TEXT), 'checkpoint not complete') > 0 
-- OR INSTR(LOWER(MESSAGE_TEXT), 'fail') > 0);
-- PROMPT ##############################################################
-- SELECT '[ ORACLE ERRORS ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || COUNT(*) AS "Total"
-- FROM sys.X$DBGALERTEXT
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back
-- AND (INSTR(LOWER(MESSAGE_TEXT), 'ora-') > 0 
-- OR INSTR(LOWER(MESSAGE_TEXT), 'error') > 0 
-- OR INSTR(LOWER(MESSAGE_TEXT), 'fail') > 0);
-- PROMPT ##############################################################
-- SELECT '[ ORA-00600 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || COUNT(*) AS "Total"
-- FROM sys.X$DBGALERTEXT
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back
-- AND MESSAGE_TEXT LIKE '%ORA-00600%';
-- PROMPT ##############################################################
-- SELECT '[ ORA-00700 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || COUNT(*) AS "Total"
-- FROM sys.X$DBGALERTEXT
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back
-- AND MESSAGE_TEXT LIKE '%ORA-00700%';
-- PROMPT ##############################################################
-- SELECT '[ ORA-07445 ] Total of Occurrences on The Lasts ' || :days_back || ' Days: ' || COUNT(*) AS "Total"
-- FROM sys.X$DBGALERTEXT
-- WHERE ORIGINATING_TIMESTAMP > SYSDATE - :days_back
-- AND MESSAGE_TEXT LIKE '%ORA-07445%';
-- 