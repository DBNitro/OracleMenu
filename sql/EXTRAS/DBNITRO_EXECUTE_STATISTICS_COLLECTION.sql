-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 10/04/2024
-- DateModification.: 10/04/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'

prompt
prompt # Execute Statistics Collection SYSTEM
EXEC DBMS_STATS.GATHER_SYSTEM_STATS;
-- EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_SYSTEM_STATS_JOB');

prompt
prompt # Execute Statistics Collection DATABASE
EXEC DBMS_STATS.GATHER_DATABASE_STATS;
-- EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_DATABASE_STATS_JOB

prompt
prompt # Execute Statistics Collection DICTIONARY
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;
-- EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_DICTIONARY_STATS_JOB');

prompt
prompt # Execute Statistics Collection FIXED OBJECTS
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
-- EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_FIXED_OBJECTS_STATS_JOB');

prompt
prompt # Execute Statistics Collection DATABASE 15%
EXEC DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 15);
-- EXEC DBMS_SCHEDULER.RUN_JOB('

prompt
prompt # Execute Statistics Collection DATABASE 15% CASCADE
EXEC DBMS_STATS.GATHER_DATABASE_STATS(estimate_percent => 15, cascade => TRUE);
-- EXEC DBMS_SCHEDULER.RUN_JOB('

prompt
prompt # EXECUTE JOB GATHER_STATS_JOB
EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_STATS_JOB'); 

prompt
prompt # EXECUTE JOB GATHER_STATS_STALE_CUSTOM_JOB
EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_STATS_STALE_CUSTOM_JOB'); 

prompt
prompt # EXECUTE JOB GATHER_STATS_FULL_CUSTOM_JOB
EXEC DBMS_SCHEDULER.RUN_JOB('GATHER_STATS_FULL_CUSTOM_JOB');
