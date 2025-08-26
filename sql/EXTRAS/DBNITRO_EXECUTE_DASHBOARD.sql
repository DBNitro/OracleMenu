set pages 700 lines 700 timing on long 9999999 numwidth 20 heading on echo on verify on feedback on colsep '|'
alter session set current_schema=system;
SET LINESIZE 5000 pagesize 0 Arraysize 51 TAB OFF
prompt ##############################################################
prompt # ACCESSING THE DATABASE DASHBOARD
prompt ##############################################################
select * from table(jss.gtop(51));
/
