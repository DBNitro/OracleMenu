-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 31/12/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # ASM: VERIFY DISK GROUP SIZE AND USAGE
prompt ##############################################################
prompt
col username for a20
col machine for a40
select ses.username
  , ses.machine
  , driv.CLIENT_DRIVER
  , driv.CLIENT_VERSION 
from gv$session ses
   , gv$session_connect_info driv 
where ses.sid = driv.sid
order by 1,2,3;