set feedback off timing off
alter session set nls_date_format='dd/mm/yyyy';
set pages 0 timing off heading off echo off verify off feedback off colsep '|' long 9999999 numwidth 20
select 'DB_MODE.........................: ' || status                                                                                                                                                         from v$instance;
select 'DB_VERSION......................: ' || version                                                                                                                                                        from v$instance;
select 'DB_RELEASE......................: ' || substr(version,1,2)                                                                                                                                            from v$instance;
select 'DB_EDITION......................: ' || substr(banner, 21, 18)                                                                                                                                         from v$version where banner like 'Oracle%';
select 'DB_ACTIVE_STATE.................: ' || active_state                                                                                                                                                   from v$instance;
select 'DB_ROLE.........................: ' || database_role                                                                                                                                                  from v$database;
select 'DB_UNIQ_NAME....................: ' || value                                                                                                                                                          from v$parameter where name = 'db_unique_name';
select 'DB_SRV_NAME.....................: ' || value                                                                                                                                                          from v$parameter where name = 'service_names';
select 'DB_BLOC_SIZE_K..................: ' || value || ' KB'                                                                                                                                                 from v$parameter where name = 'db_block_size';
select 'DB_BLOC_SIZE_M..................: ' || value/1024 || ' MB'                                                                                                                                            from v$parameter where name = 'db_block_size';
select 'DB_MEM_MAX_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'memory_max_target';
select 'DB_MEM_MAX_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'memory_max_target';
select 'DB_MEM_MAX_T....................: ' || ltrim(to_char(round(value)/1024/1024/1024/1024,      '9G999G999D999')) || ' TB'                                                                                from v$parameter where name = 'memory_max_target';
select 'DB_MEM_TAR_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'memory_target';
select 'DB_MEM_TAR_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'memory_target';
select 'DB_MEM_TAR_T....................: ' || ltrim(to_char(round(value)/1024/1024/1024/1024,      '9G999G999D999')) || ' TB'                                                                                from v$parameter where name = 'memory_target';
select 'DB_SGA_MAX_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'sga_max_size';
select 'DB_SGA_MAX_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'sga_max_size';
select 'DB_SGA_MAX_T....................: ' || ltrim(to_char(round(value)/1024/1024/1024/1024,      '9G999G999D999')) || ' TB'                                                                                from v$parameter where name = 'sga_max_size';
select 'DB_SGA_TAR_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'sga_target';
select 'DB_SGA_TAR_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'sga_target';
select 'DB_SGA_TAR_T....................: ' || ltrim(to_char(round(value)/1024/1024/1024/1024,      '9G999G999D999')) || ' TB'                                                                                from v$parameter where name = 'sga_target';
select 'DB_PGA_LIM_K....................: ' || ltrim(to_char(round(value)/1024,                     '9G999G999D999')) || ' KB'                                                                                from v$parameter where name = 'pga_aggregate_limit';
select 'DB_PGA_LIM_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'pga_aggregate_limit';
select 'DB_PGA_LIM_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'pga_aggregate_limit';
select 'DB_PGA_TAR_K....................: ' || ltrim(to_char(round(value)/1024,                     '9G999G999D999')) || ' KB'                                                                                from v$parameter where name = 'pga_aggregate_target';
select 'DB_PGA_TAR_M....................: ' || ltrim(to_char(round(value)/1024/1024,                '9G999G999D99')) ||  ' MB'                                                                                from v$parameter where name = 'pga_aggregate_target';
select 'DB_PGA_TAR_G....................: ' || ltrim(to_char(round(value)/1024/1024/1024,           '9G999G999D99')) ||  ' GB'                                                                                from v$parameter where name = 'pga_aggregate_target';
select 'DB_UPTIME.......................: ' || to_date(startup_time,           'dd/mm/yyyy hh24:mi')                                                                                                          from v$instance;
select 'DB_UPTIME_DAYS..................: ' || (select to_date(sysdate,        'dd/mm/yyyy hh24:mi') - to_date(startup_time, 'dd/mm/yyyy hh24:mi')                                                            from v$instance) from dual;
select 'DB_VER_TIME_PATCHED.............: ' || to_char(max(action_time),       'dd/mm/yyyy')                                                                                                                  from registry$history where action in ('APPLY','UPGRADE','RU_APPLY');
select 'DB_VER_TIME_DAYS_AGO............: ' || ltrim(lpad(substr(substr(to_char((select sysdate from dual) - (select max(action_time)                                                                         from DBA_REGISTRY_SQLPATCH where action in ('APPLY','UPGRADE','RU_APPLY'))),3),2), 16, '0'), '0') from dual;
select 'DB_TOT_SIZE_M...................: ' || ltrim(to_char(round(sum(bytes)/1024/1024),            '9G999G999D99')) ||  ' MB'                                                                               from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v$log union all select sum(block_size * file_size_blks) from v$controlfile);
select 'DB_TOT_SIZE_G...................: ' || ltrim(to_char(round(sum(bytes)/1024/1024/1024),       '9G999G999D99')) ||  ' GB'                                                                               from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v$log union all select sum(block_size * file_size_blks) from v$controlfile);
select 'DB_TOT_SIZE_T...................: ' || ltrim(to_char(round(sum(bytes)/1024/1024/1024/1024),  '9G999G999D999')) || ' TB'                                                                               from (select sum(bytes) bytes from dba_data_files union all select sum(bytes) bytes from dba_temp_files union all select sum(bytes * members) from v$log union all select sum(block_size * file_size_blks) from v$controlfile);
select 'DB_CACHE_SIZE_K.................: ' || ltrim(to_char(round(value)/1024),                     '9G999G999D999') ||  ' KB'                                                                               from v$parameter where name = 'db_cache_size';
select 'DB_CACHE_SIZE_M.................: ' || ltrim(to_char(round(value)/1024/1024),                '9G999G999D99') ||   ' MB'                                                                               from v$parameter where name = 'db_cache_size';
select 'DB_CACHE_SIZE_G.................: ' || ltrim(to_char(round(value)/1024/1024/1024),           '9G999G999D99') ||   ' GB'                                                                               from v$parameter where name = 'db_cache_size';
select 'DB_SHARED_POOL_K................: ' || ltrim(to_char(round(value)/1024),                     '9G999G999D999') ||  ' KB'                                                                               from v$parameter where name = 'shared_pool_size';
select 'DB_SHARED_POOL_M................: ' || ltrim(to_char(round(value)/1024),                     '9G999G999D99') ||   ' MB'                                                                               from v$parameter where name = 'shared_pool_size';
select 'DB_SHARED_POOL_G................: ' || ltrim(to_char(round(value)/1024),                     '9G999G999D99') ||   ' GB'                                                                               from v$parameter where name = 'shared_pool_size';
select 'DB_SCN..........................: ' || current_scn                                                                                                                                                    from v$DATABASE;
select 'DB_ARCH_LAG_TARGET..............: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'archive_lag_target';
select 'DB_ARCH_LAG_TARGET_MINUTES......: ' || to_char(value/60)                                                                                                                                              from v$parameter where name = 'archive_lag_target';
select 'DB_ARCH_LAG_TARGET_HOURS........: ' || ltrim(to_char(round(value/60/60, 2)))                                                                                                                          from v$parameter where name = 'archive_lag_target';
select 'DB_ARCH_LAG_TARGET_DAYS.........: ' || ltrim(to_char(round(value/60/60/24, 2)))                                                                                                                       from v$parameter where name = 'archive_lag_target';
select 'DB_ARCH_LOG_FORMAT..............: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'log_archive_format';
select case when log_mode = 'ARCHIVELOG' then 'DB_ARCHIVE_MODE.................: YES' else 'DB_ARCHIVE_MODE.................: NO' end                                                                         from v$DATABASE;
select 'DB_GOLDENGATE...................: ' || case when value = 'TRUE' then 'YES' when value = 'FALSE' then 'NO' end                                                                                         from v$parameter where name = 'enable_goldengate_replication';
select decode(count(*), 0, 'DB_PARTITION....................: NO', 'DB_PARTITION....................: YES') Partitioning                                                                                      from dba_part_tables where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM');
select distinct case when a.DETECTED_USAGES = 0 then 'DB_SQL_TUNING...................: NO' else 'DB_SQL_TUNING...................: YES' end                                                                  from dba_feature_usage_statistics a, v$instance b where a.name = 'SQL Tuning Advisor' and a.version = b.version;
select case when value = 'TRUE' then 'DB_SPATIAL......................: YES' else 'DB_SPATIAL......................: NO' end                                                                                  from v$option where parameter = 'Spatial';
select distinct case when DETECTED_USAGES = 0 then 'DB_MULTIMEDIA...................: NO' else 'DB_MULTIMEDIA...................: YES' end                                                                    from dba_feature_usage_statistics a, v$instance b where name  = 'Oracle Multimedia' and a.version = b.version;
select distinct case when DETECTED_USAGES = 0 then 'DB_TEXT.........................: NO' else 'DB_TEXT.........................: YES' end                                                                    from dba_feature_usage_statistics a, v$instance b where name  = 'Oracle Text' and a.version = b.version;
select 'DB_DATAGUARD....................: ' || case when value = 'TRUE' then 'YES' when value = 'FALSE' then 'NO' end                                                                                         from v$parameter where name = 'dg_broker_start';
select 'DB_STBY_FILE_MANAGEMENT.........: ' || value                                                                                                                                                          from v$parameter where name = 'standby_file_management';
select case when FORCE_LOGGING = 'YES' then 'DB_FORCE_LOGGING................: YES' else 'DB_FORCE_LOGGING................: NO' end                                                                           from v$DATABASE;
select case when FLASHBACK_ON = 'YES' then 'DB_FLASBBACK_ON.................: YES' else 'DB_FLASBBACK_ON.................: NO' end                                                                            from v$DATABASE;
select 'DB_FLASH_SIZE_M.................: ' || ltrim(to_char(space_limit/1024/1024, '9G999G999D999'))                                                                                                         from v$recovery_file_dest;
select 'DB_FLASH_SIZE_G.................: ' || ltrim(to_char(space_limit/1024/1024/1024, '9G999G999D999'))                                                                                                    from v$recovery_file_dest;
select 'DB_FLASH_SIZE_T.................: ' || ltrim(to_char(space_limit/1024/1024/1024/1024, '9G999G999D999'))                                                                                               from v$recovery_file_dest;
select 'DB_FLASH_RETENTION_MINUTES......: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'db_flashback_retention_target';
select 'DB_FLASH_RETENTION_HOURS........: ' || ltrim(value/60)                                                                                                                                                from v$parameter where name = 'db_flashback_retention_target';
select 'DB_FLASH_RETENTION_DAYS.........: ' || ltrim(value/60/24)                                                                                                                                             from v$parameter where name = 'db_flashback_retention_target';
select 'DB_PROTECTION_MODE..............: ' || ltrim(protection_mode)                                                                                                                                         from v$database;
select 'DB_RECOVERY_FILE_DEST_G.........: ' || ltrim(to_char(value/1024/1024/1024, '9G999G999D999'))                                                                                                          from v$parameter where name = 'db_recovery_file_dest_size';
select 'DB_RECOVERY_FILE_DEST_T.........: ' || ltrim(to_char(value/1024/1024/1024/1024, '9G999G999D999'))                                                                                                     from v$parameter where name = 'db_recovery_file_dest_size';
select 'DB_RECOVERY_FILE_DEST_PERC......: ' || ltrim(to_char(decode(nvl(space_used, 0), 0, 0, ceil((space_used/space_limit) * 100)))) || '%'                                                                  from v$recovery_file_dest;
select 'DB_UNDO_RETENTION_SECONDS.......: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'undo_retention';
select 'DB_UNDO_RETENTION_MINUTES.......: ' || ltrim(value/60)                                                                                                                                                from v$parameter where name = 'undo_retention';
select 'DB_UNDO_RETENTION_HOURS.........: ' || ltrim(value/60/60)                                                                                                                                             from v$parameter where name = 'undo_retention';
select 'DB_OPEN_CURSORS.................: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'open_cursors';
select 'DB_PROCESSES....................: ' || ltrim(value)                                                                                                                                                   from v$parameter where name = 'processes';
select 'DB_RECYCLEBIN...................: ' || upper(value)                                                                                                                                                   from v$parameter where name = 'recyclebin';
select 'DB_ORA-0600.....................: ' || count(*)                                                                                                                                                       from sys.X$DBGALERTEXT where MESSAGE_TEXT like '%ORA-00600%' and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select 'DB_ORA_ERRORS...................: ' || count(*)                                                                                                                                                       from sys.X$DBGALERTEXT where (lower(MESSAGE_TEXT) like '%ora-%' or lower(MESSAGE_TEXT) like '%error%' or lower(MESSAGE_TEXT) like '%checkpoint not complete%' or lower(MESSAGE_TEXT) like '%fail%') and ORIGINATING_TIMESTAMP > sysdate-30 and rownum = 1;
select case when used_percent >= 80 then 'DB_TBS_SPACE.................: WARNING' when used_percent >= 90 then 'DB_TBS_SPACE.................: CRITICAL' else 'DB_TBS_SPACE....................: SIZE OK' end from dba_tablespace_usage_metrics where rownum = 1;
SELECT 'DB_COMPONENTS...................: ' || comp_name || ' ---> ' || case when status = 'VALID' then 'YES' when status = 'OPTION OFF' then 'NO' else status end                                            from dba_registry order by comp_name;