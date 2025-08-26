-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 12/08/2025
-- DateModification.: 12/08/2025
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set pages 2000 lines 2000 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # VERIFX THE OS PLATFORM                                     #
prompt ##############################################################
select * from V$TRANSPORTABLE_PLATFORM order by 1,2,3;