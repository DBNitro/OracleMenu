-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # PDB: CHECK STARTUP AND UPTIME OF ALL PDBS
prompt ##############################################################
col name for a20
col open_time for a33
select con_id
  , name
  , dbid
  , open_mode
  , to_char(open_time, 'dd/mm/yyyy hh24:mi:ss') as open_time
from v$containers
order by 1,2,3;