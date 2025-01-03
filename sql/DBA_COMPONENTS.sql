-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 16/08/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/dbaribas/dbnitro.net
-- WEBSITE..........: http://dbnitro.net

set feedback off timing off
alter session set nls_date_format='YYYY-MM-DD';
set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DBA: SHOW DATABASE COMPONENTS
prompt ##############################################################
COL comp_id for a15
COL status for a10
COL version for a15
col VERSION_FULL for a15
COL comp_name for a40
col MODIFIED for a25
col CONTROL for a20
col OTHER_SCHEMAS for a40
SELECT con_id
  , SUBSTR(comp_id,1,15) comp_id
  , SUBSTR(version,1,10) version
  , VERSION_FULL
  , status
  -- , to_char(MODIFIED, 'YYYY-MM-DD HH24:MI:SS') as MOD
  , MODIFIED
  --  , CONTROL
  --  , OTHER_SCHEMAS
  , SUBSTR(comp_name,1,40) comp_name 
FROM cdb_registry
order by 1,2,3;
