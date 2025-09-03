--
-- Author    : Ludovico Caldara
-- Version   : 0.2
-- Purpose   : Checks the health of a Data Guard configuration on ONE database, including RAC environments
-- Run as    : SYSDBA, execute on each DB in the config
--             Does not check ALL DBs in the configuration but only the current one
-- Limitations: Tested on Oracle 19c; may require adjustments for 11g
-- Modified by: Andre Augusto Ribas
--
set pages 700 lines 700 timing off long 9999999 numwidth 20 heading on echo off verify on feedback off colsep '|' serveroutput on
prompt ##############################################################
prompt # General Status (RAC-Aware)
prompt ##############################################################
col OBJECT_ID for a10
col DATABASE for a20
col INTENDED_STATE for a25
col CONNECT_STRING for a20
col RAC for a3
col ENABLED for a7
col ROLE for a20
col RECEIVE_FROM for a15
col SHIP_TO for a15
col DGB_CONNECT for a25
col FSFOTARGETVALIDITY for a25
col STATUS for a15
col INSTANCE_NAME for a15
SELECT piv.*, obj.status, inst.instance_name FROM (SELECT to_char(object_id) as object_id, attribute, value FROM x$drc WHERE object_id IN (SELECT object_id FROM x$drc WHERE attribute = 'DATABASE')) drc
PIVOT (MAX(value) FOR attribute
   IN ('DATABASE'           DATABASE
     , 'intended_state'     intended_state
     , 'connect_string'     connect_string
     , 'enabled'            enabled
     , 'role'               role
     , 'receive_from'       receive_from
     , 'ship_to'            ship_to
     , 'dgb_connect'        dgb_connect
     , 'FSFOTargetValidity' FSFOTargetValidity)) piv
JOIN x$drc obj ON (obj.object_id = piv.object_id AND obj.attribute = 'DATABASE')
JOIN gv$instance inst ON (1=1);
prompt
prompt ##############################################################
prompt # Difference Between the Primary and Standbys (Per Thread)
prompt ##############################################################
SELECT ARCH.instance_name
     , ARCH.THREAD# AS "Thread"
     , ARCH.SEQUENCE# AS "Last in Sequence"
     , APPL.SEQUENCE# AS "Last Applied Sequence"
     , (ARCH.SEQUENCE# - APPL.SEQUENCE#) AS "Difference"
FROM (SELECT inst.instance_name, al.THREAD#, al.SEQUENCE# FROM GV$ARCHIVED_LOG al JOIN GV$INSTANCE inst ON (al.inst_id = inst.inst_id) WHERE (al.THREAD#, al.FIRST_TIME) IN (SELECT THREAD#, MAX(FIRST_TIME) FROM GV$ARCHIVED_LOG GROUP BY THREAD#)) ARCH
JOIN (SELECT inst.instance_name, lh.THREAD#, lh.SEQUENCE# FROM GV$LOG_HISTORY lh JOIN GV$INSTANCE inst ON (lh.inst_id = inst.inst_id) WHERE (lh.THREAD#, lh.FIRST_TIME) IN (SELECT THREAD#, MAX(FIRST_TIME) FROM GV$LOG_HISTORY GROUP BY THREAD#)) APPL ON (ARCH.THREAD# = APPL.THREAD#)
ORDER BY ARCH.THREAD#, ARCH.instance_name;
prompt
DECLARE
  r_var_name                VARCHAR2(4000);
  r_var_uniq_name           VARCHAR2(4000);
  r_var_db_role             VARCHAR2(4000);
  r_var_open_mode           VARCHAR2(4000);
  r_var_prot_mode           VARCHAR2(4000);
  r_var_prot_level          VARCHAR2(4000);
  r_var_force_log           VARCHAR2(4000);
  r_var_flashback           VARCHAR2(4000);
  r_var_log_mode            VARCHAR2(4000);
  r_var_switch_status       VARCHAR2(4000);
  r_var_redologs_group      VARCHAR2(4000);
  r_var_standbys_group      VARCHAR2(4000);
  r_var_redologs_threads    VARCHAR2(4000);
  r_var_standbys_threads    VARCHAR2(4000);
  r_var_instance_name       VARCHAR2(4000);
  v_dgconfig                BINARY_INTEGER;
  v_num_errors              BINARY_INTEGER;
  v_num_warnings            BINARY_INTEGER;
  v_apply_lag               INTERVAL DAY TO SECOND;
  v_transport_lag           INTERVAL DAY TO SECOND;
  v_apply_th                INTERVAL DAY TO SECOND;
  v_transport_th            INTERVAL DAY TO SECOND;
  v_delay                   INTERVAL DAY TO SECOND;
  v_delaymins               BINARY_INTEGER;
  v_flashback v$database.flashback_on%type;
CURSOR c_dgconfig IS
  SELECT piv.*, obj.status, inst.instance_name FROM (SELECT object_id, attribute, value FROM x$drc WHERE object_id IN (SELECT object_id FROM x$drc WHERE attribute = 'DATABASE'))
    drc PIVOT (MAX(value) FOR attribute
           IN ('DATABASE'           DATABASE
             , 'intended_state'     intended_state
             , 'connect_string'     connect_string
             , 'enabled'            enabled
             , 'role'               role
             , 'receive_from'       receive_from
             , 'ship_to'            ship_to
             , 'FSFOTargetValidity' FSFOTargetValidity)) piv
    JOIN x$drc obj ON (obj.object_id = piv.object_id AND obj.attribute = 'DATABASE')
    JOIN gv$instance inst ON (1=1)
    WHERE lower(piv.database)=lower(sys_context('USERENV','DB_UNIQUE_NAME'));
CURSOR c_priconfig IS
  SELECT piv.*, obj.status, inst.instance_name FROM (SELECT object_id, attribute, value FROM x$drc WHERE object_id IN (SELECT object_id FROM x$drc WHERE attribute = 'DATABASE'))
    drc PIVOT (MAX(value) FOR attribute
           IN ('DATABASE'           DATABASE
             , 'intended_state'     intended_state
             , 'connect_string'     connect_string
             , 'enabled'            enabled
             , 'role'               role
             , 'receive_from'       receive_from
             , 'ship_to'            ship_to
             , 'FSFOTargetValidity' FSFOTargetValidity)) piv
    JOIN x$drc obj ON (obj.object_id = piv.object_id AND obj.attribute = 'DATABASE')
    JOIN gv$instance inst ON (1=1)
    WHERE piv.role='PRIMARY';
  r_dgconfig  c_dgconfig%ROWTYPE;
  r_priconfig c_priconfig%ROWTYPE;
  v_open_mode v$database.open_mode%TYPE;
  v_status               VARCHAR2(100);
  v_error                VARCHAR2(100);
  v_p_connect            BINARY_INTEGER;
  v_s_connect            BINARY_INTEGER;
  v_offline_datafiles    BINARY_INTEGER;
  v_indoc                VARCHAR2(4000);
  v_outdoc               VARCHAR2(4000);
  v_rid                  NUMBER;
  v_context              VARCHAR2(100);
  v_pieceno              NUMBER;
 
BEGIN
  v_num_errors := 0;
  v_num_warnings := 0;
  v_p_connect := 0;
  v_s_connect := 0;
  dbms_output.put_line('+--------------------------------------------------------------');
  dbms_output.put_line('|Checking Data Guard Configuration for ' || sys_context('USERENV','DB_UNIQUE_NAME') || ' (RAC-Aware)');
  dbms_output.put_line('+--------------------------------------------------------------');
 
  SELECT NAME                       INTO r_var_name              FROM V$DATABASE;
  SELECT DB_UNIQUE_NAME             INTO r_var_uniq_name         FROM V$DATABASE;
  SELECT DATABASE_ROLE              INTO r_var_db_role           FROM V$DATABASE;
  SELECT OPEN_MODE                  INTO r_var_open_mode         FROM V$DATABASE;
  SELECT PROTECTION_MODE            INTO r_var_prot_mode         FROM V$DATABASE;
  SELECT PROTECTION_LEVEL           INTO r_var_prot_level        FROM V$DATABASE;
  SELECT force_logging              INTO r_var_force_log         FROM V$DATABASE;
  SELECT flashback_on               INTO r_var_flashback         FROM V$DATABASE;
  SELECT log_mode                   INTO r_var_log_mode          FROM V$DATABASE;
  SELECT SWITCHOVER_STATUS          INTO r_var_switch_status     FROM V$DATABASE;
  SELECT COUNT(*)                   INTO r_var_redologs_group    FROM V$LOG;
  SELECT COUNT(*)                   INTO r_var_standbys_group    FROM V$STANDBY_LOG;
  SELECT COUNT(DISTINCT thread#)    INTO r_var_redologs_threads  FROM V$LOG;
  SELECT COUNT(DISTINCT thread#)    INTO r_var_standbys_threads  FROM V$STANDBY_LOG;
  SELECT instance_name              INTO r_var_instance_name     FROM gv$instance WHERE inst_id = sys_context('USERENV','INSTANCE');
 
  dbms_output.put_line('| _INFO: Database Name: '                || r_var_name);
  dbms_output.put_line('| _INFO: Database Unique Name: '         || r_var_uniq_name);
  dbms_output.put_line('| _INFO: Database Role: '                || r_var_db_role);
  dbms_output.put_line('| _INFO: Database Open Mode: '           || r_var_open_mode);
  dbms_output.put_line('| _INFO: Database Protection Mode: '     || r_var_prot_mode);
  dbms_output.put_line('| _INFO: Database Protection Level: '    || r_var_prot_level);
  dbms_output.put_line('| _INFO: Database Force Logging: '       || r_var_force_log);
  dbms_output.put_line('| _INFO: Database Flashback ON: '        || r_var_flashback);
  dbms_output.put_line('| _INFO: Database Log Mode: '            || r_var_log_mode);
  dbms_output.put_line('| _INFO: Database Switchover Status: '   || r_var_switch_status);
  dbms_output.put_line('| _INFO: Instance Name: '                || r_var_instance_name);
  dbms_output.put_line('| _INFO: Database Redo Logs Groups: '    || r_var_redologs_group || ' | Threads: ' || r_var_redologs_threads);
  dbms_output.put_line('| _INFO: Database Standby Logs Groups: ' || r_var_standbys_group || ' | Threads: ' || r_var_standbys_threads);
 
  -- get open_mode
  SELECT open_mode INTO v_open_mode FROM v$database;
  -- check if the configuration exists
  SELECT count(*) INTO v_dgconfig FROM x$drc;
  IF v_dgconfig = 0 THEN
    dbms_output.put_line('| ERROR: Current database does not have a Data Guard config.');
    v_num_errors := v_num_errors + 1;
    GOTO stop_checks;
  ELSE
    dbms_output.put_line('| ___OK: Current database has a Data Guard config.');
  END IF;
 
  -- fetch the primary DB config (moved here so it's available for checks below)
  OPEN c_priconfig;
  FETCH c_priconfig INTO r_priconfig;
  IF c_priconfig%NOTFOUND THEN
    dbms_output.put_line('| ERROR: There is no primary database in the config.');
    v_num_errors := v_num_errors + 1;
    GOTO stop_checks;
  END IF;
  CLOSE c_priconfig;
  -- fetch the current DB config in record
  OPEN c_dgconfig;
  LOOP
    FETCH c_dgconfig INTO r_dgconfig;
    EXIT WHEN c_dgconfig%NOTFOUND;
    dbms_output.put_line('| _INFO: Checking instance: ' || r_dgconfig.instance_name);
 
    -- enabled?
    IF r_dgconfig.enabled = 'YES' THEN
      dbms_output.put_line('| ___OK: Current database is enabled in Data Guard for instance ' || r_dgconfig.instance_name || '.');
    ELSE
      dbms_output.put_line('| ERROR: Current database is not enabled in Data Guard for instance ' || r_dgconfig.instance_name || '.');
      v_num_errors := v_num_errors + 1;
    END IF;
    -- status SUCCESS?
    IF r_dgconfig.status = 'SUCCESS' THEN
      dbms_output.put_line('| ___OK: Data Guard status for the database is: ' || r_dgconfig.status || ' for instance ' || r_dgconfig.instance_name || '.');
    ELSE
      dbms_output.put_line('| ERROR: Data Guard status for the database is: ' || r_dgconfig.status || ' for instance ' || r_dgconfig.instance_name || '.');
      v_num_errors := v_num_errors + 1;
    END IF;
    -- reachability of the primary
    BEGIN
      dbms_drs.CHECK_CONNECT(r_priconfig.database, r_priconfig.database);
      dbms_output.put_line('| ___OK: Primary (' || r_priconfig.database || ') is reachable from instance ' || r_dgconfig.instance_name || '.');
      v_p_connect := 1;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('| ERROR: Primary (' || r_priconfig.database || ') unreachable from instance ' || r_dgconfig.instance_name || '. Error code ' || SQLCODE || ': ' || SQLERRM);
        v_num_errors := v_num_errors + 1;
    END;
    -- if we are not on the primary, check the current database connectivity as well through the broker
    IF r_priconfig.object_id <> r_dgconfig.object_id THEN
      BEGIN
        dbms_drs.CHECK_CONNECT(r_dgconfig.database, r_dgconfig.database);
        dbms_output.put_line('| ___OK: Current DB (' || r_dgconfig.database || ') is reachable from instance ' || r_dgconfig.instance_name || '.');
        v_s_connect := 1;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('| ERROR: Current DB (' || r_dgconfig.database || ') unreachable from instance ' || r_dgconfig.instance_name || '. Error code ' || SQLCODE || ': ' || SQLERRM);
          v_num_errors := v_num_errors + 1;
      END;
    END IF;
 
    -- we check primary transport only if reachable
    IF v_p_connect = 1 THEN
      v_indoc := '<DO_MONITOR version="19.1"><PROPERTY name="LogXptStatus" object_id="' || r_priconfig.object_id || '"/></DO_MONITOR>';
      v_pieceno := 1;
      dbms_drs.do_control(v_indoc, v_outdoc, v_rid, v_pieceno, v_context);
      select regexp_substr(v_outdoc, '(<TD >)([[:alnum:]].*?)(</TD>)',1,3,'i',2) into v_status from dual;
      IF v_status = 'VALID' THEN
        dbms_output.put_line('| ___OK: LogXptStatus of primary is VALID for instance ' || r_dgconfig.instance_name || '.');
      ELSE
        dbms_output.put_line('| ERROR: LogXptStatus of primary is ' || nvl(v_status,'NULL') || ' for instance ' || r_dgconfig.instance_name || '.');
        v_num_errors := v_num_errors + 1;
      END IF;
    END IF;
    -- flashback?
    SELECT flashback_on INTO v_flashback FROM v$database;
    IF v_flashback = 'YES' THEN
      dbms_output.put_line('| ___OK: Flashback Logging is enabled for instance ' || r_dgconfig.instance_name || '.');
    ELSE
      dbms_output.put_line('| _WARN: Flashback Logging is disabled for instance ' || r_dgconfig.instance_name || '.');
      v_num_warnings := v_num_warnings + 1;
    END IF;
    -- role?
    IF r_dgconfig.ROLE = 'PRIMARY' THEN
      dbms_output.put_line('| ___OK: The database is PRIMARY, skipping standby checks for instance ' || r_dgconfig.instance_name || '.');
    ELSE
      dbms_output.put_line('| ___OK: The database is STANDBY, executing standby checks for instance ' || r_dgconfig.instance_name || '.');
      -- intended state?
      IF r_dgconfig.intended_state = 'PHYSICAL-APPLY-ON' THEN
        dbms_output.put_line('| ___OK: The database intended state is APPLY-ON for instance ' || r_dgconfig.instance_name || '.');
      ELSIF r_dgconfig.intended_state = 'PHYSICAL-APPLY-READY' THEN
        dbms_output.put_line('| _WARN: The database intended state is APPLY-OFF for instance ' || r_dgconfig.instance_name || '.');
        v_num_warnings := v_num_warnings + 1;
      ELSE
        dbms_output.put_line('| ERROR: The database intended state is ' || r_dgconfig.intended_state || ' for instance ' || r_dgconfig.instance_name || '.');
        v_num_errors := v_num_errors + 1;
      END IF;
      -- real time apply?
      IF v_open_mode = 'READ ONLY WITH APPLY' THEN
        dbms_output.put_line('| _WARN: Real Time Apply is used for instance ' || r_dgconfig.instance_name || '.');
        v_num_warnings := v_num_warnings + 1;
      ELSIF v_open_mode = 'MOUNTED' THEN
        dbms_output.put_line('| ___OK: The standby database is mounted for instance ' || r_dgconfig.instance_name || '.');
      ELSE
        dbms_output.put_line('| ERROR: The database open_mode is ' || v_open_mode || ' for instance ' || r_dgconfig.instance_name || '.');
        v_num_errors := v_num_errors + 1;
      END IF;
      -- offline datafiles?
      SELECT COUNT(DISTINCT con_id) INTO v_offline_datafiles FROM gv$recover_file WHERE online_status='OFFLINE' AND inst_id = sys_context('USERENV','INSTANCE');
      IF v_offline_datafiles > 0 THEN
        dbms_output.put_line('| ERROR: There are ' || v_offline_datafiles || ' PDBs with OFFLINE datafiles for instance ' || r_dgconfig.instance_name);
        v_num_errors := v_num_errors + 1;
      ELSE
        dbms_output.put_line('| ___OK: There are no PDBs with OFFLINE datafiles for instance ' || r_dgconfig.instance_name);
      END IF;
      -- delay
      v_delaymins := dbms_drs.get_property_obj(r_dgconfig.object_id,'DelayMins');
      v_delay := numtodsinterval(v_delaymins,'minute');
      IF v_delaymins > 0 THEN
        dbms_output.put_line('| _WARN: Standby delayed by ' || v_delaymins || ' minutes for instance ' || r_dgconfig.instance_name || '.');
        v_num_warnings := v_num_warnings + 1;
      END IF;
      -- apply lag?
      v_apply_th := numtodsinterval(dbms_drs.get_property_obj(r_dgconfig.object_id,'ApplyLagThreshold'),'second');
      BEGIN
        SELECT TO_DSINTERVAL(value) INTO v_apply_lag FROM gv$dataguard_stats WHERE name='apply lag' AND inst_id = sys_context('USERENV','INSTANCE');
        IF v_apply_lag IS NULL THEN
          dbms_output.put_line('| _WARN: apply lag is unknown (null) for instance ' || r_dgconfig.instance_name);
          v_num_warnings := v_num_warnings + 1;
        ELSIF v_apply_lag > (v_apply_th + v_delay) THEN
          dbms_output.put_line('| ERROR: apply lag is ' || v_apply_lag || ' for instance ' || r_dgconfig.instance_name);
          v_num_errors := v_num_errors + 1;
        ELSE
          dbms_output.put_line('| ___OK: apply lag is ' || v_apply_lag || ' for instance ' || r_dgconfig.instance_name);
        END IF;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('| ERROR: cannot determine apply lag for instance ' || r_dgconfig.instance_name || '.');
        v_num_errors := v_num_errors + 1;
      END;
      -- transport lag?
      v_transport_th := numtodsinterval(dbms_drs.get_property_obj(r_dgconfig.object_id,'TransportLagThreshold'),'second');
      BEGIN
        SELECT TO_DSINTERVAL(value) INTO v_transport_lag FROM gv$dataguard_stats WHERE name='transport lag' AND inst_id = sys_context('USERENV','INSTANCE');
        IF v_transport_lag IS NULL THEN
          dbms_output.put_line('| _WARN: transport lag is unknown (null) for instance ' || r_dgconfig.instance_name);
          v_num_warnings := v_num_warnings + 1;
        ELSIF v_transport_lag > v_transport_th THEN
          dbms_output.put_line('| ERROR: transport lag is ' || v_transport_lag || ' for instance ' || r_dgconfig.instance_name);
          v_num_errors := v_num_errors + 1;
        ELSE
          dbms_output.put_line('| ___OK: transport lag is ' || v_transport_lag || ' for instance ' || r_dgconfig.instance_name);
        END IF;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('| _WARN: cannot determine transport lag for instance ' || r_dgconfig.instance_name || '.');
        v_num_warnings := v_num_warnings + 1;
      END;
    END IF;
  END LOOP;
  CLOSE c_dgconfig;
  <<stop_checks>>
  dbms_output.put_line('+--------------------------------------------------------------');
  IF v_num_errors > 0 THEN
    DBMS_OUTPUT.PUT_LINE('| RESULT: ERROR: ' || to_char(v_num_errors));
  ELSIF v_num_warnings > 0 THEN
    DBMS_OUTPUT.PUT_LINE('| RESULT: WARN: ' || to_char(v_num_warnings));
  ELSE
    DBMS_OUTPUT.PUT_LINE('| RESULT: OK: You can drink a coffee now!!!');
  END IF;
  dbms_output.put_line('+--------------------------------------------------------------');
END;
/