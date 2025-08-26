-- |------------------------------------------------------------------------------------------------|
-- | DATABASE : Oracle 11g und 12c                                                                  |
-- | FILE     : check_database_license_violation.sql                                                |
-- | OUTPUT   : olu_<instance_name>_<host_name>_<date>.txt                                          |
-- | ZWECK    : Dieses Script fuehrt einen Check gegen die Datenbank aus und erzeugt anschliessend  |
-- |            eine Ergebnis-Report ueber die in der Datenbank genutzten lizenzpflichtigen         |
-- |            Features. Des Weiteren wird geprÈ­ft, ob die richtige Edition installiert ist und   |
-- |            die Anzahl der genutzten CPU Sockel den Lizenzbestimmungen entspricht.              |
-- |            Die Information bezueglich den CPU Sockel ist allerdings nur auf physikalischen     |
-- |            gueltig.                                                                            |
-- | VERSION  : 1.5                                                                                 |
-- | DATE     : 31.01.2017                                                                          |
-- | AUTOR    : Frank Gerasch, Oracle Senior Consultant                                             |
-- | INFO     : Das Script muss als User mit SYSDBA-Rolle, z.B. SYS, in SQL*Plus ausgefuehrt        |
-- |          : werden, um auf alle notwendigen Dictionary-Views Zugriff zu haben.                  |
-- |          : Vor der Ausfuehrung muessen Angaben im Header ueber die vorhandenen Lizenzen        |
-- |          : gemacht werden (TRUE | FALSE)!                                                      |  
-- | USAGE    : sqlplus sys/<password>[@db_connect_identifier] as sysdba                            |
-- |            SQL> @check_database_license_violation.sql                                          |
-- | OUTPUT   : dlu_<instance_name>_<host_name>_<timestamp>.txt                                     |
-- +------------------------------------------------------------------------------------------------+

set linesize 130 feedback off echo off verify off
set serveroutput on format wrapped size 1000000

column spool_name new_value S
set termout off
select 'dlu_'||lower(instance_name)||'_'||lower(host_name)||'_'||to_char(sysdate,'DD.MM.YYYY')||'.txt' spool_name
from v$instance
where rownum < 2;
set termout on
spool &S


DECLARE


-- Hier Angabe zum Report
-- TRUE = Alle Pruefungen werden angezeigt ( auch die das Ergbnise OK haben)
-- FALSE = Nur die Pruefungen werden angezeigt mit dem Ergebnis WARNUNG
----------------------------------------------------------------------------------------------------
v_show_only_warnings boolean := FALSE;
 


-- Angabe zu lizenzierter Oracle Edition
---------------------------------------
v_oracle_edition_license varchar2(3) := 'SEO';     -- Default = seo. Moeglichkeiten: seo, se2, se, ee, 
-- Moeglichkeiten:
--    'PE'  = Lizenz Personal Edition vorhanden
--    'SEO' = Lizenz Standard Edition One vorhanden (Default)
--    'SE2' = Lizenz Standard Edition Two vorhanden
--    'SE'  = Lizenz Standard Edition vorhanden
--    'EE'  = Lizenz Enterprise Edition Edition vorhanden


-- Hier Angaben zu den vorhandenen Lizenzen machen
----------------------------------------------------------------------------------------------------
-- FALSE (Default) = Keine entsprechende Lizenz vorhanden 
-- TRUE = Entsprechende Lizenz vorhanden 


-- Angabe zu lizenzierten Packs
---------------------------------------
    
-- Oracle Tuning Pack Lizenz
v_tuning_pack_license boolean := FALSE;          

-- Oracle Diagnostic Pack Lizenz 
v_diag_pack_license boolean := FALSE;            

-- Change Management Pack Lizenz
v_change_pack_license boolean := FALSE;           

-- Configuration Management Pack Lizenz
v_config_pack_license boolean := FALSE;             

-- Data Masking Pack Lizenz
v_datam_license boolean := FALSE;                   

-- Provisioning and Patch Automation Pack Lizenz / Lifecycle Management Pack Lizenz
v_provis_license boolean := FALSE;                 

-- WebLogic Server Management Pack EE Lizenz
v_wls_license boolean := FALSE;                     


-- Angabe zu lizenzierten EE OPTIONEN 
---------------------------------------
-- Active Data Guard Option Lizenz
v_active_dg_license boolean := FALSE;                

-- Advanced Anylytics Option Lizenz
v_oaa_license boolean := FALSE;                   

-- Advanced Compression Option Lizenz
v_oac_license boolean := FALSE;                      

-- Advanced Security Option Lizenz
v_oas_license boolean := FALSE;                    

-- Database Gateway Option Lizenz
v_gateway_license boolean := FALSE;                  

-- Database In-Memory Option Lizenz
v_inmemory_license boolean := FALSE;                 

-- Database Vault Option Lizenz
v_vault_license boolean := FALSE;                   

-- Golden Gate Option Lizenz
v_golden_gate_license boolean := FALSE;              

-- Label Security Option Lizenz
v_label_sec_license boolean := FALSE;                

-- Multitenant Option Lizenz   
v_multiteant_license boolean := FALSE;                

-- OLAP Option Lizenz
v_olap_license boolean := FALSE;                      

-- Partitioning Option Lizenz 
v_partitioning_license boolean := FALSE;              

-- RAC or RAC One Node Option Lizenz
v_rac_raconenode_license boolean := FALSE;             

-- Real Application Clusters Lizenz
v_rac_license boolean := FALSE;               

-- Real Application Clusters One Node Lizenz
v_rac_onenode_license boolean := FALSE;             

-- Real Application Testing Lizenz
v_rat_license boolean := FALSE;             

-- Secure Backup Option  Lizenz
v_sec_backup_license boolean := FALSE;             

-- Spatial Option  Lizenz
v_spatial_license boolean := FALSE;             


----------------------------------------------------------------------------------------------------

BEGIN
  DECLARE
    v1 VARCHAR(200);
    v2 VARCHAR(200);
    v3 VARCHAR(200);
    v4 VARCHAR(200);
    v5 VARCHAR(200);
BEGIN
  select banner into v1 from v$version where banner like 'Oracle%';
  select version into v2 from v$instance;
  select instance_name into v3 from v$instance;
  select name into v4 from v$database;
  select to_char(sysdate,'DD.MM.YYYY HH24:MI') into v5 from dual;
  DBMS_OUTPUT.PUT_LINE(' ');
  DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
  DBMS_OUTPUT.PUT_LINE(' DATABASE LICENSE VIOLATION REPORT');
  DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
  DBMS_OUTPUT.PUT_LINE(' Edition            '||v1 );
  DBMS_OUTPUT.PUT_LINE(' Version            '||v2 );
  DBMS_OUTPUT.PUT_LINE(' Instance           '||v3);
  DBMS_OUTPUT.PUT_LINE(' DB Name            '||v4);
  DBMS_OUTPUT.PUT_LINE(' Timestamp          '||v5);
  DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
END;

DBMS_OUTPUT.PUT_LINE(' EDITION / PACK / OPTION            RESULT    USAGE ');
DBMS_OUTPUT.PUT_LINE('========================================================================================================================');


-- Enterprise Edition Lizenz
DECLARE
  v1 number;
BEGIN
  execute immediate 'select count(*) from v$version where banner like ''%Enterprise Edition%''' into v1;
  IF v1 = '0' THEN
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Enterprise Edition Lizenz:         OK      - Es ist keine Enterprise Edition installiert');
  END IF;
ELSE
  IF v_oracle_edition_license = 'EE' THEN
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Enterprise Edition Lizenz:         OK      - Enterprise Edition installiert und laut Angabe lizenziert');
END IF;
ELSE
  dbms_output.put_line(' Enterprise Edition Lizenz:         WARNUNG - Enterprise Edition installiert, aber laut Angabe nicht lizenziert');
END IF;
END IF;
END;

-- CPU Socket Count Non-Enterprise Editions
DECLARE
  v1 number;
  v_is_rac varchar2(10);
  v_socket_count number;
BEGIN
  select count(*) into v1 from v$version where banner like '%Enterprise Edition%';
  select value into v_is_rac from v$parameter where name='cluster_database';
  select nvl(cpu_socket_count_current,0) into v_socket_count from v$license;
  IF v1 = '0' THEN
  IF v_socket_count > 0 THEN
  IF v_socket_count > 4 THEN
  dbms_output.put_line(' Edition CPU Socket Count:          WARNUNG - Evtl. mehr Sockets vorhanden, als fuer diese DB Edition ('||v_oracle_edition_license||') erlaubt sind ('||v_socket_count||')');
ELSE
  IF v_socket_count > 2 AND v_oracle_edition_license = 'SE' AND v_is_rac = 'TRUE' THEN
  dbms_output.put_line(' Edition CPU Socket Count:          WARNUNG - Evtl. mehr Sockets vorhanden, als fuer diese DB Edition ('||v_oracle_edition_license||') im RAC erlaubt ('||v_socket_count||')');
ELSE
  IF v_socket_count > 1 AND (v_oracle_edition_license =  'SE2' OR v_oracle_edition_license = 'SEO') AND v_is_rac = 'TRUE' THEN
  dbms_output.put_line(' Edition CPU Socket Count:          WARNUNG - Evtl. mehr Sockets vorhanden, als fuer diese DB Edition ('||v_oracle_edition_license||') im RAC erlaubt ('||v_socket_count||')');
ELSE
  IF v_socket_count > 2 AND (v_oracle_edition_license =  'SE2' OR v_oracle_edition_license = 'SEO') AND v_is_rac = 'FALSE' THEN
  dbms_output.put_line(' Edition CPU Socket Count:          WARNUNG - Evtl. mehr Sockets vorhanden, als fuer diese DB Edition ('||v_oracle_edition_license||') erlaubt sind ('||v_socket_count||')');
ELSE
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Edition CPU Socket Count:          OK      - Es sind nicht mehr Sockets vorhanden, als fuer diese DB Edition ('||v_oracle_edition_license||') erlaubt sind('||v_socket_count||')');
END IF;
END IF;
END IF;
END IF;
END IF;
ELSE
  dbms_output.put_line(' Edition CPU Socket Count:          WARNUNG - Die Anzahl der Sockets kann nicht ermittelt werden ('||v_socket_count||')');
END IF;
ELSE
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Edition CPU Socket Count:          OK      - Fuer die installierte Enterprise Edition gibt es keine CPU Beschraenkung');
END IF;
END IF;
END;


-- Change Management Pack - EM Config Management Pack
DECLARE
  v_detected_usages number;
  v_name varchar2(200) := 'Change Management Pack';
BEGIN
  select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
  IF nvl(v_detected_usages,0) > 0 THEN 
  IF v_change_pack_license = FALSE THEN  
  dbms_output.put_line(' Change Management Pack:            WARNUNG - Das Change Management Pack wurde genutzt ');
ELSE
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Change Management Pack:            OK      - Das Change Management Pack wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
  IF v_show_only_warnings = FALSE THEN
  dbms_output.put_line(' Change Management Pack:            OK      - Das Change Management Pack wurde nie genutzt' );
END IF;
END IF;
END;

-- Configuration Mngmt Pack - EM Config Management Pack
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM Config Management Pack';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_config_pack_license = FALSE THEN  
dbms_output.put_line(' Configuration Management Pack:     WARNUNG - Das EM Config Management Pack wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Configuration Management Pack:     OK      - Das EM Config Management Pack wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Configuration Management Pack:     OK      - Das EM Config Management Pack wurde nie genutzt' );
END IF;
END IF;
END;

-- Data Masking Pack - Data Masking Pack    
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM Standalone Provisioning and Patch Automation Pack';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_datam_license = FALSE THEN  
dbms_output.put_line(' Data Masking Pack:                 WARNUNG - Das Data Masking Pack wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Data Masking Pack:                 OK      - Das Data Masking Pack wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Data Masking Pack:                 OK      - Das Data Masking Pack wurde nie genutzt' );
END IF;
END IF;
END;

--  Diagnostic Pack Usage - Control Pack Access
DECLARE
v1 varchar2(100);
BEGIN
select VALUE into v1 from V$PARAMETER  where lower(NAME) in ('control_management_pack_access');
IF v1 = 'NONE'  THEN 
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Nutzung Diagnostic Pack durch Parameter control_management_pack_access deaktiviert');
END IF;
ELSE
IF v1 = 'DIAGNOSTIC+TUNING' THEN
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - Nutzung Diagnostic Pack durch Parameter aktiviert' );
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Nutzung des Tuning- und Diagnostic Pack durch Parameter aktiviert, Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v1 = 'DIAGNOSTIC' THEN
IF v_diag_pack_license = FALSE THEN   
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - Nutzung des Diagnostic Pack durch Parameter aktiviert' );
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Nutzung des Diagnostic Pack durch Parameter aktiviert, Lizenz vorhanden' );
END IF;
END IF;
END IF;
END IF;
END IF;
END;

-- Diagnostic Pack - EM Performance Page 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM Performance Page';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - Die EM Performance Seite wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - EM Performance Seite wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - EM Performance Seite wurde nie genutzt' );
END IF;
END IF;
END;

-- Diagnostic Pack - ADDM
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'ADDM';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - Der Automatic Database Diagnostic Monitor wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Der Automatic Database Diagnostic Monitor wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Der Automatic Database Diagnostic Monitor wurde nie genutzt' );
END IF;
END IF;
END;

-- Diagnostic Pack - AWR Baseline
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'AWR Baseline';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR Baselines wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baselines wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baselines wurden nie genutzt' );
END IF;
END IF;
END;



-- Diagnostic Pack - AWR Baseline Template
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'AWR Baseline Template';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR Baseline Templates wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Templates wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Templates wurde nie genutzt' );
END IF;
END IF;
END;

-- Diagnostic Pack - AWR 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Automatic Workload Repository';
BEGIN

select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR (Automatic Workload Repository) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR (Automatic Workload Repository) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR (Automatic Workload Repository) wurde nie genutzt' );
END IF;
END IF;
END;

--  Diagnostic Pack - AWR Report
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'AWR Report';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR Reports wurden generiert ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Reports wurden generiert - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Reports wurden nie generiert' );
END IF;
END IF;
END;

-- Diagnostic Pack - AWR Baseline Adaptive Thresholds
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Baseline Adaptive Thresholds';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR Baseline Adaptive Thresholds wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Adaptive Thresholds wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Adaptive Thresholds wurden nie genutzt' );
END IF;
END IF;
END;

-- Diagnostic Pack - Baseline Static Computations
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Baseline Static Computations';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - AWR Baseline Static Computations wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Static Computations wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - AWR Baseline Static Computations wurden nie genutzt' );
END IF;
END IF;
END;

-- Diagnostic Pack - Diagnostic Pack
DECLARE
v_version varchar2(2);
v_detected_usages number;
v_name varchar2(200) := 'Diagnostic Pack';
BEGIN
select substr(version,1,2) into v_version from v$instance;
IF v_version = '11' THEN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Diagnostic Pack:                   WARNUNG - Diagnostic Pack Flag aktiv ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Diagnostic Pack Flag aktiv  - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Diagnostic Pack:                   OK      - Diagnostic Pack Flag nicht aktiv' );
END IF;
END IF;
END IF;
END;

-- Tuning Pack - Control Pack Access
DECLARE
v1 varchar2(100);
BEGIN
select VALUE into v1 from V$PARAMETER  where lower(NAME) in ('control_management_pack_access');
IF v1 = 'NONE'  THEN 
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Nutzung Tuning Pack durch Parameter control_management_pack_access deaktiviert');
END IF;
ELSE
IF v1 = 'DIAGNOSTIC+TUNING' THEN
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Nutzung Tuning Pack durch Parameter aktiviert' );
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Nutzung Tuning Pack durch Parameter aktiviert, Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v1 = 'TUNING' THEN
IF v_diag_pack_license = FALSE THEN   
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Nutzung Tuning Pack durch Parameter aktiviert' );
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Nutzung des Tuning Pack durch Parameter aktiviert, Lizenz vorhanden' );
END IF;
END IF;
END IF;
END IF;
END IF;
END;

-- Tuning Pack - SQL Monitoring and Tuning pages 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Monitoring and Tuning pages';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Die EM SQL Monitoring and Tuning Seiten wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Die EM SQL Monitoring and Tuning Seiten wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Die EM SQL Monitoring and Tuning Seiten wurden nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - Automatic Maintenance - SQL Tuning Advisor
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Automatic Maintenance - SQL Tuning Advisor';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Automatic Maintenance - SQL Tuning Advisor wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Automatic Maintenance - SQL Tuning Advisor wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Automatic Maintenance - SQL Tuning Advisor urde nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - Automatic SQL Tuning Advisor
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Automatic SQL Tuning Advisor';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Der Automatic SQL Tuning Advisor wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der Automatic SQL Tuning Advisor wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der Automatic SQL Tuning Advisor wurde nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - Real-Time SQL Monitoring
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Real-Time SQL Monitoring';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Das Real-Time SQL Monitoring wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Das Real-Time SQL Monitoring wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Das Real-Time SQL Monitoring wurde nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - SQL Access Advisor
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Access Advisor';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Der SQL Access Advisor wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der SQL Access Advisor wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der SQL Access Advisor wurde nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - SQL Profile
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Profile';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - SQL Profile wurden genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - SQL Profile wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - SQL Profile wurden nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - SQL Tuning Advisor
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Tuning Advisor';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Der SQL Tuning Advisor wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der SQL Tuning Advisor wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Der SQL Tuning Advisor wurde nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - SQL Tuning Set (user)
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Tuning Set (user)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_tuning_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - SQL Tuning Sets wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - SQL Tuning Sets wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - SQL Tuning Sets wurden nie genutzt' );
END IF;
END IF;
END;

-- Tuning Pack - Tuning Pack
DECLARE
v_version varchar2(2);
v_detected_usages number;
v_name varchar2(200) := 'Tuning Pack';
BEGIN
select substr(version,1,2) into v_version from v$instance;
IF v_version = '11' THEN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_diag_pack_license = FALSE THEN  
dbms_output.put_line(' Tuning Pack:                       WARNUNG - Tuning Pack Flag aktiv ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Tuning Pack Flag aktiv  - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Tuning Pack:                       OK      - Tuning Pack Flag nicht aktiv' );
END IF;
END IF;
END IF;
END;

-- Lifecyle Mangement Pack - EM Database Provisioning and Patch Automation Pack     
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM Database Provisioning and Patch Automation Pack';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_provis_license = FALSE THEN  
dbms_output.put_line(' Lifecyle Mangement Pack:           WARNUNG - Das EM Database Provisioning and Patch Automation Pack wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - Das EM Database Provisioning and Patch Automation Pack wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - Das EM Database Provisioning and Patch Automation Pack wurde nie genutzt' );
END IF;
END IF;
END;

-- Lifecyle Mangement Pack - EM Standalone Provisioning and Patch Automation Pack
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM Standalone Provisioning and Patch Automation Pack';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_provis_license = FALSE THEN  
dbms_output.put_line(' Lifecyle Mangement Pack:           WARNUNG - Das EM Standalone Provisioning and Patch Automation Pack wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - Das EM Standalone Provisioning and Patch Automation Pack wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - Das EM Standalone Provisioning and Patch Automation Pack wurde nie genutzt' );
END IF;
END IF;
END;

-- Lifecyle Mangement Pack - DDL Logging
DECLARE
v1 varchar2(20);
BEGIN
select value into v1 from v$parameter where name = 'enable_ddl_logging';
IF v1 = 'TRUE'  THEN 
IF v_provis_license = FALSE THEN  
dbms_output.put_line(' Lifecyle Mangement Pack:           WARNUNG - DDL Logging durch Parameter aktiviert, Lifecycle Management Pack in Nutzung' );
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - DDL Logging durch Parameter aktiviert - Lifecycle Management Pack Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Lifecyle Mangement Pack:           OK      - DDL Logging durch Parameter deaktiviert');
END IF;
END IF;
END;

-- Oracle Weblogic Server Management Packs - EM AS Provisioning and Patch Automation Pack
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'EM AS Provisioning and Patch Automation Pack';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_wls_license = FALSE THEN  
dbms_output.put_line(' WLS Mangement Pack EE              WARNUNG - Das EM AS Provisioning and Patch Automation Pack wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' WLS Mangement Pack EE              OK      - Das EM AS Provisioning and Patch Automation Pack wurde genutz - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' WLS Mangement Pack EE              OK      - Das EM AS Provisioning and Patch Automation Pack wurde nie genutzt' );
END IF;
END IF;
END;

-- Active Data Guard Option - Real-Time Query on Physical Standby
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Active Data Guard - Real-Time Query on Physical Standby';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_active_dg_license = FALSE THEN  
dbms_output.put_line(' Active Data Guard Option:          WARNUNG - Active Data Guard - Real-Time Query on Physical Standby wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Active Data Guard Option:          OK      - Active Data Guard - Real-Time Query on Physical Standby wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Active Data Guard Option:          OK      - Active Data Guard - Real-Time Query on Physical Standby wurde nie genutzt' );
END IF;
END IF;
END;

-- Active Data Guard Option - Global Data Services
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Global Data Services';
v_description varchar2(200);
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_active_dg_license = FALSE THEN  
dbms_output.put_line(' Active Data Guard Option:          WARNUNG - Global Data Services wurden genutzt ');
select distinct(description) into v_description from dba_feature_usage_statistics where name = v_name and detected_usages > 1;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Active Data Guard Option:          OK      - Global Data Services wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Active Data Guard Option:          OK      - Global Data Services wurden nie genutzt' );
END IF;
END IF;
END;

-- Advanced Analytics Option - Data Mining
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Data Mining';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oaa_license = FALSE THEN  
dbms_output.put_line(' Advanced Analytics Option:         WARNUNG - Data Mining wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Analytics Option:         OK      - Data Mining wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Analytics Option:         OK      - Data Mining wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Datapump Compressed Import 
DECLARE
v1 number;
v2 number;
v_detected_usages number;
v_name varchar2(200) := 'Oracle Utility Datapump (Import)';
BEGIN
select count(*) into v1 from dba_feature_usage_statistics where feature_info is not null 
and name = 'Oracle Utility Datapump (Import)' 
and (regexp_like(to_char(FEATURE_INFO), 'LOW algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
or regexp_like(to_char(FEATURE_INFO), 'MEDIUM algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
or regexp_like(to_char(FEATURE_INFO), 'HIGH algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i'))
and substr(version,1,2) >= '12';
select count(*) into v2 from dba_feature_usage_statistics where feature_info is not null 
and name = 'Oracle Utility Datapump (Import)' 
and regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
and substr(version,1,2) < '12';
IF v1 > 0 or v2 > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Lizenzpflichtige Datapump Compression (Import) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Lizenzpflichtige Datapump Compression (Import) wurde genutzt - Lizenz aber vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Lizenzpflichtige Datapump Compression (Import) wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Datapump Compressed Export 
DECLARE
v1 number;
v2 number;
v_detected_usages number;
v_name varchar2(200) := 'Oracle Utility Datapump (Export)';
BEGIN
select count(*) into v1 from dba_feature_usage_statistics where feature_info is not null 
and name = 'Oracle Utility Datapump (Export)' 
and (regexp_like(to_char(FEATURE_INFO), 'LOW algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
or regexp_like(to_char(FEATURE_INFO), 'MEDIUM algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
or regexp_like(to_char(FEATURE_INFO), 'BASIC algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
or regexp_like(to_char(FEATURE_INFO), 'HIGH algorithm used:[ 0-9]*[1-9][ 0-9]*time', 'i'))
and substr(version,1,2) >= '12';
select count(*) into v2 from dba_feature_usage_statistics where feature_info is not null 
and name = 'Oracle Utility Datapump (Export)' 
and regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i') 
and substr(version,1,2) < '12';
IF v1 > 0 or v2 > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Lizenzpflichtige Datapump Compression (Export) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Lizenzpflichtige Datapump Compression wurde genutzt - Lizenz aber vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Lizenzpflichtige Datapump Compression (Export) wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Backup HIGH Compression
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup HIGH Compression';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Backup HIGH Compression wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup HIGH Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup HIGH Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Backup LOW Compression
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup LOW Compression';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Backup LOW Compression wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup LOW Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup LOW Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Backup MEDIUM Compression
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup MEDIUM Compression';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Backup MEDIUM Compression wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup MEDIUM Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup MEDIUM Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Backup ZLIB Compression
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup ZLIB Compression';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_detected_usages > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Backup ZLIB Compression wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup ZLIB Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Backup ZLIB Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - SecureFile Deduplication (user)
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SecureFile Deduplication (user)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - SecureFile Deduplication wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - SecureFile Deduplication wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - SecureFile Deduplication wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - SecureFile Compression (user)
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SecureFile Compression (user)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - SecureFile Compression wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - SecureFile Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - SecureFile Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Advanced Index Compression
DECLARE
v_detected_usages number;
v_name varchar2(200);
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name in ('ADVANCED Index Compression','Advanced Index Compression') and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Advanced Index Compression wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Advanced Index Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Advanced Index Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Advanced Network Compression Service
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Oracle Advanced Network Compression Service';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Advanced Network Compression Service wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Advanced Network Compression Service wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Advanced Network Compression Service wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Information Lifecycle Management
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Information Lifecycle Management';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Information Lifecycle Management (ILM) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Information Lifecycle Management (ILM) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Information Lifecycle Management (ILM) wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Hybrid Columnar Compression Row Level Locking
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Hybrid Columnar Compression Row Level Locking';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Hybrid Columnar Compression wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Hybrid Columnar Compression wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Hybrid Columnar Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Flashback Data Archive
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Flashback Data Archive';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0 and version in ('11.2.0.1','11.2.0.2','11.2.0.3');
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Flashback Data Archive wurde genutzt in Version < 11.2.0.3 ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Flashback Data Archive wurde genutzt in Version < 11.2.0.3  - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Flashback Data Archive wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Heat Map 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Heat Map';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Heat Map (Automatic Data Optimization) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Heat Map (Automatic Data Optimization) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Heat Map (Automatic Data Optimization) wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Compression Option - Data Guard Network Compression
DECLARE
v1 number;
v2 number;
v_detected_usages number;
v_name varchar2(200) := 'Data Guard';
BEGIN
select count(*) into v1 from dba_feature_usage_statistics where feature_info is not null and name = 'Data Guard' and regexp_like(to_char(FEATURE_INFO), 'compression used: *TRUE', 'i') ;
IF v1 > 0 THEN 
IF v_oac_license = FALSE THEN  
dbms_output.put_line(' Advanced Compression Option:       WARNUNG - Data Guard Network Compression wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Data Guard Network Compression wurde genutzt - Lizenz aber vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Compression Option:       OK      - Data Guard Network Compression wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Data Redaction
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Data Redaction';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Data Redaction wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Data Redaction wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Data Redaction wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Encrypted Tablespaces
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Encrypted Tablespaces';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line('Advanced Security Option:           WARNUNG - Encrypted Tablespaces wurden genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Encrypted Tablespaces wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Encrypted Tablespaces wurden nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - SecureFile Encryption (user)
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SecureFile Encryption (user)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - SecureFile Encryption wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - SecureFile Encryption wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - SecureFile Encryption wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Backup Encryption
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup Encryption';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Backup Encryption wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Backup Encryption wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Backup Encryption wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Backup Encryption
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Backup Encryption';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0 and version in ('11.2.0.1','11.2.0.2','11.2.0.3','11.2.0.3');
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Backup Encryption wurde genutzt in Version 11g (to Disk lizenzpflichtig!) ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Backup Encryption wurde genutzt in Version 11g - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Backup Encryption in Version 11g wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Transparent Data Encryption
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Transparent Data Encryption';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Transparent Data Encryption wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Transparent Data Encryption wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Transparent Data Encryption wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option - Datapump Encrypted Import 
DECLARE
v1 number;
v2 number;
v_detected_usages number;
v_name varchar2(200) := 'Oracle Utility Datapump (Import)';
BEGIN
select count(*) into v1 from dba_feature_usage_statistics where feature_info is not null and name = 'Oracle Utility Datapump (Import)' and regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i') ;
IF v1 > 0 THEN 
select compresscnt into v_detected_usages from sys.ku_utluse where utlname = 'Oracle Utility Datapump (Import)';
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Datapump Encryption (Import) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Datapump Encryption (Import) wurde genutzt  - Lizenz aber vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Datapump Encryption (Import) wurde nie genutzt' );
END IF;
END IF;
END;

-- Advanced Security Option  - Datapump Encrypted Export 
DECLARE
v1 number;
v2 number;
v_detected_usages number;
v_name varchar2(200) := 'Oracle Utility Datapump (Export)';
BEGIN
select count(*) into v1 from dba_feature_usage_statistics where feature_info is not null and name = 'Oracle Utility Datapump (Export)' and regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i') ;
IF v1 > 0 THEN 
select compresscnt into v_detected_usages from sys.ku_utluse where utlname = 'Oracle Utility Datapump (Export)';
IF v_oas_license = FALSE THEN  
dbms_output.put_line(' Advanced Security Option:          WARNUNG - Datapump Encryption (Export) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK       - Datapump Encryption (Export) wurde genutzt  - Lizenz aber vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Advanced Security Option:          OK      - Datapump Encryption (Export) wurde nie genutzt' );
END IF;
END IF;
END;

-- Database Gateway Option - Gateways
DECLARE
v_non_odbc_usages number;
v_detected_usages number;
v_name varchar2(200) := 'Gateways';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
select count(*) into v_non_odbc_usages from hs$_fds_class where fds_class_name != 'BITE' and fds_class_name not like 'ODBC%';
IF nvl(v_detected_usages,0) > 0 and v_non_odbc_usages > 0 THEN 
IF v_gateway_license = FALSE THEN  
dbms_output.put_line(' Database Gateway Option:           WARNUNG - Lizenzpflichtige Gateways wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Lizenzpflichtige Gateways wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_detected_usages > 0 THEN
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Nur ODBC Gateway wurde genutzt (lizenzfrei)' );
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Lizenzpflichtige Gateways wurden nie genutzt' );
END IF;
END IF;
END IF;
END;

-- Database Gateway Option - Transparent Gateway
DECLARE
v_non_odbc_usages number;
v_detected_usages number;
v_name varchar2(200) := 'Transparent Gateway';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
select count(*) into v_non_odbc_usages from hs$_fds_class where fds_class_name != 'BITE' and fds_class_name not like 'ODBC%';
IF nvl(v_detected_usages,0) > 0 and v_non_odbc_usages > 0 THEN 
IF v_gateway_license = FALSE THEN  
dbms_output.put_line(' Database Gateway Option:           WARNUNG - Lizenzpflichtige Transparent Gateway wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Transparent Gateway wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_detected_usages > 0 THEN
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Nur ODBC Transparent Gateway wurde genutzt (lizenzfrei)' );
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Gateway Option:           OK      - Transparent Gateway wurde nie genutzt' );
END IF;
END IF;
END IF;
END;

-- Database In-Memory Option - In-Memory Aggregation
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'In-Memory Aggregation';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_inmemory_license = FALSE THEN  
dbms_output.put_line(' Database In-Memory Option:         WARNUNG - In-Memory Aggregation wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database In-Memory Option:         OK      - In-Memory Aggregation wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database In-Memory Option:         OK      - In-Memory Aggregation wurde nie genutzt' );
END IF;
END IF;
END;

-- Database In-Memory Option - In-Memory Aggregation   - BUG! 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'In-Memory Column Store';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_inmemory_license = FALSE THEN  
dbms_output.put_line(' Database In-Memory Option:         WARNUNG - In-Memory Column Store wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database In-Memory Option:         OK      - In-Memory Column Store wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database In-Memory Option:         OK      - In-Memory Column Store wurde nie genutzt' );
END IF;
END IF;
END;

-- Database Vault Option - Oracle Database Vault
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Oracle Database Vault';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_vault_license = FALSE THEN  
dbms_output.put_line(' Database Vault Option:             WARNUNG - Oracle Database Vault wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Vault Option:             OK      - Oracle Database Vault wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Vault Option:             OK      - Oracle Database Vault wurde nie genutzt' );
END IF;
END IF;
END;

-- Database Vault Option - Privilege Capture
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Privilege Capture';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_vault_license = FALSE THEN  
dbms_output.put_line(' Database Vault Option:             WARNUNG - Privilege Capture wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Vault Option:             OK      - Privilege Capture wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Database Vault Option:             OK      - Privilege Capture wurde nie genutzt' );
END IF;
END IF;
END;

-- Golden Gate - GoldenGate
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'GoldenGate';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_golden_gate_license = FALSE THEN  
dbms_output.put_line(' Golden Gate:                       WARNUNG - Golden Gate wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Golden Gate:                       OK      - Golden Gate wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Golden Gate:                       OK      - Golden Gate wurde nie genutzt' );
END IF;
END IF;
END;

-- Label Security Option - Label Security
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Label Security';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_label_sec_license = FALSE THEN  
dbms_output.put_line(' Label Security Option:             WARNUNG - Privilege Capture wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Label Security Option:             OK      - Privilege Capture wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Label Security Option:             OK      - Privilege Capture wurde nie genutzt' );
END IF;
END IF;
END;

-- Multitenant Option - Oracle Multitenant
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Oracle Multitenant';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_multiteant_license = FALSE THEN  
dbms_output.put_line(' Multitenant Option:                WARNUNG - Oracle Multitenant wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Multitenant Option:                OK      - Oracle Multitenant wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Multitenant Option:                OK      - Oracle Multitenant wurde nie genutzt' );
END IF;
END IF;
END;

-- Multitenant Option - Oracle Pluggable Databases
DECLARE
v_count_pdbs number;
v_detected_usages number;
v_name varchar2(200) := 'Oracle Pluggable Databases';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
select max(aux_count) into v_count_pdbs from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF v_multiteant_license = FALSE THEN 
IF v_count_pdbs > 1 THEN
dbms_output.put_line(' Multitenant Option:                WARNUNG - Oracle Pluggable Databases wurden genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Multitenant Option:                OK      - Nur eine Pluggable Databases wurde genutzt - Keine Lizenz erforderlich' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Multitenant Option:                OK      - Oracle Pluggable Databases wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Multitenant Option:                OK      - Oracle Pluggable Databases wurden nie genutzt' );
END IF;
END IF;
END;

-- OLAP Option - OLAP - Analytic Workspaces
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'OLAP - Analytic Workspaces';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_olap_license = FALSE THEN  
dbms_output.put_line(' OLAP Option:                       WARNUNG - Oracle Analytic Workspaces wurden genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' OLAP Option:                       OK      - Oracle Analytic Workspaces wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' OLAP Option:                       OK      - Oracle Analytic Workspaces wurden nie genutzt' );
END IF;
END IF;
END;

-- OLAP Option - OLAP - Cubes
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'OLAP - Cubes';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_olap_license = FALSE THEN  
dbms_output.put_line(' OLAP Option:                       WARNUNG - OLAP - Cubes wurden genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' OLAP Option:                       OK      - OLAP - Cubes wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' OLAP Option:                       OK      - OLAP - Cubes wurden nie genutzt' );
END IF;
END IF;
END;

-- Partitioning Option - Partitioning (user)
DECLARE
v_detected_usages number;
v_part_user_objects number;
v_name varchar2(200) := 'Partitioning (user)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
-- Check partitioned objects are noit in RMAN Catalog
select count(*) into v_part_user_objects from (
select owner, count(table_name) from dba_part_tables
where owner not in (select owner from dba_tables where table_name = 'RCVER')
and owner not in ('SYSTEM','SYSMAN','SYS')
group by owner
union
select owner, count(table_name) from dba_part_indexes
where owner not in (select owner from dba_tables where table_name = 'RCVER')
and owner not in ('SYSTEM','SYSMAN','SYS')
group by owner)
where (select substr(version,1,2) from v$instance) = '12';
IF nvl(v_detected_usages,0) > 0 and v_part_user_objects > 0 THEN 
IF v_partitioning_license = FALSE THEN  
dbms_output.put_line(' Partitioning Option:               WARNUNG - Partitioning wurde genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Partitioning Option:               OK      - Partitioning wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Partitioning Option:               OK      - Partitioning wurde nie genutzt' );
END IF;
END IF;
END;

-- Partitioning Option - Zone maps
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Zone maps';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_partitioning_license = FALSE THEN  
dbms_output.put_line(' Partitioning Option:               WARNUNG - Zone Maps wurden genutzt');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Partitioning Option:               OK      - Zone Maps wurden genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Partitioning Option:               OK      - Zone Maps wurden nie genutzt' );
END IF;
END IF;
END;

-- RAC Option - Real Application Clusters (RAC)                    
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Real Application Clusters (RAC)';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rac_license = FALSE THEN  
IF v_oracle_edition_license = 'SE' THEN
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC Option:                        OK      - Real Application Cluster (RAC) wurde genutzt - Lizenz in der Standard Edition vorhanden');
END IF;
ELSE
dbms_output.put_line(' RAC Option:                        WARNUNG - Real Application Cluster (RAC) wurde genutzt');
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC Option:                        OK      - Real Application Cluster (RAC) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC Option:                        OK      - Real Application Cluster (RAC) wurde nie genutzt' );
END IF;
END IF;
END;

-- RAC / RAC One Node Option  - Quality of Service Management
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Quality of Service Management';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rac_raconenode_license = FALSE THEN  
dbms_output.put_line(' RAC oder RAC One Node Option:      WARNUNG - Quality of Service Management wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC oder RAC One Node Option:      OK      - Quality of Service Management wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC oder RAC One Node Option:      OK      - Quality of Service Management wurde nie genutzt' );
END IF;
END IF;
END;

-- RAC One Node Option - Real Application Cluster One Node
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Real Application Cluster One Node';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rac_onenode_license = FALSE THEN  
dbms_output.put_line(' RAC One Node Option:               WARNUNG - Real Application Cluster One Node wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC One Node Option:               OK      - Real Application Cluster One Node wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' RAC One Node Option:               OK      - Real Application Cluster One Node wurde nie genutzt' );
END IF;
END IF;
END;

-- Real Application Testing - Database Replay: Workload Capture 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Database Replay: Workload Capture';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rat_license = FALSE THEN  
dbms_output.put_line(' Real Application Testing Option:   WARNUNG - Database Replay (Workload Capture) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - Database Replay (Workload Capture) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - Database Replay (Workload Capture) wurde nie genutzt' );
END IF;
END IF;
END;

-- Real Application Testing - Database Replay: Workload Replay 
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Database Replay: Workload Replay';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rat_license = FALSE THEN  
dbms_output.put_line('Real Application Testing Option:    WARNUNG - Database Replay (Workload Replay) wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - Database Replay (Workload Replay) wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - Database Replay (Workload Replay) wurde nie genutzt' );
END IF;
END IF;
END;

-- Real Application Testing - SQL Performance Analyzer
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'SQL Performance Analyzer';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_rat_license = FALSE THEN  
dbms_output.put_line(' Real Application Testing Option:   WARNUNG - SQL Performance Analyzer wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - SQL Performance Analyzer wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Real Application Testing Option:   OK      - SQL Performance Analyzer wurde nie genutzt' );
END IF;
END IF;
END;

-- Secure Backup Option - Oracle Secure Backup
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Oracle Secure Backup';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_sec_backup_license = FALSE THEN  
dbms_output.put_line(' Secure Backup Option:              WARNUNG - Oracle Secure Backup wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Secure Backup Option:              OK      - Oracle Secure Backup wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Secure Backup Option:              OK      - Oracle Secure Backup wurde nie genutzt' );
END IF;
END IF;
END;

-- Spatial - Spatial
DECLARE
v_detected_usages number;
v_name varchar2(200) := 'Spatial';
BEGIN
select sum(detected_usages) into v_detected_usages from dba_feature_usage_statistics where name = v_name and detected_usages > 0;
IF nvl(v_detected_usages,0) > 0 THEN 
IF v_spatial_license = FALSE THEN  
dbms_output.put_line(' Spatial und Graph Option:          WARNUNG - Oracle Spatial wurde genutzt ');
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Spatial und Graph Option:          OK      - Oracle Spatial wurde genutzt - Lizenz vorhanden' );
END IF;
END IF;
ELSE
IF v_show_only_warnings = FALSE THEN
dbms_output.put_line(' Spatial und Graph Option:          OK      - Oracle Spatial wurde nie genutzt' );
END IF;
END IF;
END;

BEGIN
DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
END;


END;
/

