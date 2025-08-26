-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 20/02/2024
-- DateModification.: 20/02/2024
-- EMAIL............: ribas@dbnitro.net
-- GitHub...........: https://github.com/DBNitro
-- WEBSITE..........: http://dbnitro.net

set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
prompt ##############################################################
prompt # DATABASE FOLDERS                                           #
prompt ##############################################################
col folders for a150
select 'create or replace directory ' || directory_name || ' as ' || '''' || directory_path || ''';' as folders from all_directories order by 1;