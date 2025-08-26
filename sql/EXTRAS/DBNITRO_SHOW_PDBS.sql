-- Author...........: Andre Augusto Ribas"
-- SoftwareVersion..: 1.0.1"
-- DateCreation.....: 28/04/2025
-- DateModification.: 28/04/2025
-- EMAIL_1..........: dba.ribas@gmail.com
-- EMAIL_2..........: andre.ribas@icloud.com
-- WEBSITE..........: http://dbnitro.net


set pages 700 lines 700 timing off long 9999999 numwidth 20 heading off echo off verify off feedback off colsep '|'
SELECT LISTAGG(pdb_name || ' [' || status || ']', ', ') WITHIN GROUP (ORDER BY CASE WHEN pdb_name = 'PDB$SEED' THEN 0 ELSE 1 END, pdb_name) AS pdbs_status
FROM (SELECT pdb.NAME AS pdb_name,
      CASE
        WHEN pdb.OPEN_MODE = 'READ WRITE' THEN 'RW'
        WHEN pdb.OPEN_MODE = 'READ ONLY' THEN 'RO'
        WHEN pdb.OPEN_MODE = 'MOUNTED' THEN 'MO'
        ELSE 'UNKNOWN'
      END AS status
    FROM V$PDBS pdb);