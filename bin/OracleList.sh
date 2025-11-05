#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.35"
DateCreation="18/09/2023"
DateModification="05/11/2025"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/DBNitro"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# Verify OS Parameters and Variables
#
ORA_HOMES_IGNORE_0="^#|^$|REMOVED|REFHOME|DEPHOME|PLUGINS|/usr/lib/oracle/sbin"
ORA_HOMES_IGNORE_1="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware|agent|OracleHome1"
ORA_HOMES_IGNORE_2="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|middleware"
ORA_HOMES_IGNORE_3="${ORA_HOMES_IGNORE_0}|middleware|agent"
ORA_HOMES_IGNORE_4="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|agent"
ORA_HOMES_IGNORE_5="${ORA_HOMES_IGNORE_0}|goldengate|ogg|gg|agent"
#
if [[ "$(uname)" == "SunOS" ]]; then
  OS="Solaris"
  if [[ -f "/var/opt/oracle/oratab" ]];      then ORATAB="/var/opt/oracle/oratab";           else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE DATABASE INSTALLED YET --"; exit 1; fi
  if [[ -f "/var/opt/oracle/oraInst.loc" ]]; then ORA_INST="/var/opt/oracle/oraInst.loc";    else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --";       exit 1; fi
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"            | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq              | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'            | uniq                         | sort               | wc -l             | xargs)"
  ORDS_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'ords.war'            | uniq                         | sort               | wc -l             | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"            | awk '{ print $9 }'           | uniq               | sort              | wc -l | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon|db_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | sed s/db_pmon_//g | uniq  | sort  | wc -l | xargs)"
  DGOBS_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'observer'            | uniq                         | sort               | wc -l             | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl"         | uniq                         | sort               | wc -l             | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  WLS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"             | uniq                         | sort               | wc -l             | xargs)"
  MYSQL_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/mysqld"          | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  PSQL_PROC="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/postgres"        | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  DB2_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "ibm/db2"             | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraGI|CRS="        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  WLS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OracleHome"        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  ORDS_HOME="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "ords.war"            | awk '{ print $9 }'           | sed s/-Doracle.dbtools.cmdline.home=//g | uniq | sort)"
elif [[ "$(uname)" == "AIX" ]]; then
  OS="AIX"
  if [[ -f "/etc/oratab" ]];                 then ORATAB="/etc/oratab";                      else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE DATABASE INSTALLED YET --"; exit 1; fi
  if [[ -f "/opt/oracle/etc/oraInst.loc" ]]; then ORA_INST="/opt/oracle/etc/oraInst.loc";    else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --";       exit 1; fi
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"            | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq              | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'            | uniq                         | sort               | wc -l             | xargs)"
  ORDS_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'ords.war'            | uniq                         | sort               | wc -l             | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"            | awk '{ print $9 }'           | uniq               | sort              | wc -l | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon|db_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | sed s/db_pmon_//g | uniq  | sort  | wc -l | xargs)"
  DGOBS_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'observer'            | uniq                         | sort               | wc -l             | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl"         | uniq                         | sort               | wc -l             | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  WLS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"             | uniq                         | sort               | wc -l             | xargs)"
  MYSQL_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/mysqld"          | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  PSQL_PROC="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/postgres"        | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  DB2_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "ibm/db2"             | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraGI|CRS="        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  WLS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OracleHome"        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  ORDS_HOME="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "ords.war"            | awk '{ print $9 }'           | sed s/-Doracle.dbtools.cmdline.home=//g | uniq | sort)"
elif [[ "$(uname)" == "Linux" ]]; then
  OS="Linux"
  if [[ -f "/etc/oratab" ]];            then ORATAB="/etc/oratab";                           else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE DATABASE INSTALLED YET --"; exit 1; fi
  if [[ -f "/etc/oraInst.loc" ]];       then ORA_INST="/etc/oraInst.loc";                    else echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --";       exit 1; fi
  ORA_INVENTORY="$(cat ${ORA_INST}      | egrep -i "inventory_loc"                           | cut -f2 -d '=')/ContentsXML/inventory.xml"
  ASM_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "asm_pmon"            | awk '{ print $NF }'          | sed s/asm_pmon_//g | uniq              | sort  | wc -l | xargs)"
  CRSD_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'crsd.bin'            | uniq                         | sort               | wc -l             | xargs)"
  ORDS_PROC="$(ps -ef                   | egrep -i -v 'grep|egrep'                           | egrep -i 'ords.war'            | uniq                         | sort               | wc -l             | xargs)"
  OCSSD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ocssd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  OHASD_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'ohasd.bin'           | uniq                         | sort               | wc -l             | xargs)"
  LISTENER_PROC="$(ps -ef               | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "listener"            | awk '{ print $9 }'           | uniq               | sort              | wc -l | xargs)"
  DATABASE_PROC="$(ps -ef               | egrep -i -v "grep|egrep|sed"                       | egrep -i "ora_pmon|db_pmon"    | awk '{ print $NF }'          | sed s/ora_pmon_//g | sed s/db_pmon_//g | uniq  | sort  | wc -l | xargs)"
  DGOBS_PROC="$(ps -ef                  | egrep -i -v 'grep|egrep'                           | egrep -i 'observer'            | uniq                         | sort               | wc -l             | xargs)"
  AGENT_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "agent_|perl"         | uniq                         | sort               | wc -l             | xargs)"
  OMS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  WLS_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|webmin"             | egrep -i "wlserver"            | uniq                         | sort               | wc -l             | xargs)"
  OGG_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|zabbix|qmgr|clmgrs|dgmgrl" | egrep -i "mgr|prm"             | uniq                         | sort               | wc -l             | xargs)"
  MYSQL_PROC="$(ps -ef                  | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/mysqld"          | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  PSQL_PROC="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "bin/postgres"        | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  DB2_PROC="$(ps -ef                    | egrep -i -v "grep|egrep|sed"                       | egrep -i "ibm/db2"             | awk '{ print $NF }'          | sort               | wc -l             | uniq | xargs)"
  ASM_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraGI|CRS="        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  DATABASE_HOME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_1}"                | egrep -i "LOC"                 | egrep -i "OraDB|OraHome"     | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  CLIENT_HOME="$(cat ${ORA_INVENTORY}   | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OraClient"         | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  AGENT_HOME="$(cat ${ORA_INVENTORY}    | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "agent"             | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OMS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "oms"               | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  WLS_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "OracleHome"        | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  OGG_HOME="$(cat ${ORA_INVENTORY}      | egrep -i -v "${ORA_HOMES_IGNORE_0}"                | egrep -i "LOC"                 | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '='    | cut -f2 -d '"' | uniq | sort)"
  ORDS_HOME="$(ps -ef                   | egrep -i -v "grep|egrep|sed"                       | egrep -i "ords.war"            | awk '{ print $9 }'           | sed s/-Doracle.dbtools.cmdline.home=//g | uniq | sort)"
else
  echo " -- OS Not Supported --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Verify oraInst.loc file
#
if [[ ! -f "${ORA_INST}" ]]; then echo " -- THIS SERVER DOES NOT HAVE AN ORACLE INSTALLATION YET --"; continue; fi
#
# ------------------------------------------------------------------------
# Verify ORACLE Inventory
#
if [[ ! -f "${ORA_INVENTORY}" ]]; then
  echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
  echo " -- PLEASE CHECK YOUR CONFIGURATION --"
  exit 1
fi
#
# ------------------------------------------------------------------------
# Verify ORACLE Services
#
# if [[ "${ORA_SERVICES} | xargs" == "0" ]]; then
#   echo " -- YOU DO NOT HAVE THE ORACLE INVENTORY IN YOUR ENVIRONMENT --"
#   echo " -- PLEASE CHECK YOUR CONFIGURATION --"
#   exit 1
# fi
#
# ------------------------------------------------------------------------
# Function to display Oracle service status
# USE BREAK ON IFs BECAUSE IT IS A FUNCTION
#
OracleServices() {
#
# ASM OK
# CRSD OK
# OCSSD OK
# OHASD OK
# LISTENERS OK
# AGENT OK
# DG OBS OK
# MIDDLEWARE OK
# WEBLOGIC OK
# GOLDENGATE OK
# ORDS OK
# DATABASE OK
#
if [[ "${ASM_PROC}" != "0" ]] || [[ "${CRSD_PROC}" != "0" ]] || [[ "${OCSSD_PROC}" != "0" ]] || [[ "${OHASD_PROC}" != "0" ]] || [[ "${DGOBS_PROC}" != "0" ]] || [[ "${LISTENER_PROC}" != "0" ]] || [[ "${AGENT_PROC}" != "0" ]] || [[ "${OMS_PROC}" != "0" ]] || [[ "${WLS_PROC}" != "0" ]] || [[ "${OGG_PROC}" != "0" ]] || [[ "${DATABASE_PROC}" != "0" ]]; then
#
printf "+%-31s+\n"    "-------------------------------"
printf "|%-31s%-s|\n" " ORACLE SERVICES RUNNING       "
printf "+%-31s+\n"    "-------------------------------"
#
printf "+%-31s+%-25s+%-25s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
printf "|%-31s|%-25s|%-25s|%-50s|\n" " SERVICE                       " " STATUS                        " " INFO                          " " ORACLE HOME                                                "
printf "+%-31s+%-25s+%-25s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
#
# ASM
#
if [[ "${ASM_PROC}" != "0" ]]; then
  ASM_SERVICE="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "asm_pmon" | awk '{ print $NF }' | sed s/asm_pmon_//g | uniq | sort)"
  ASM_STARTED="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "asm_pmon" | awk '{ print $5 }'  | uniq               | tail -2)"
    ASM_HOMES="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "oraagent.bin" | awk '{ print $8 }' | sed 's#/bin/oraagent\.bin##')"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${ASM_SERVICE} " " RUNNING " " UP SINCE: ${ASM_STARTED} " " ${ASM_HOMES}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
# CRSD
#
if [[ "${CRSD_PROC}" != "0" ]]; then
  CRSD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "crsd.bin" | awk '{ print $8 }' | uniq | sort)"
  CRSD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "crsd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " CRSD " " RUNNING " " UP SINCE: ${CRSD_STARTED} " " ${CRSD_SERVICE}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
# OCSSD
#
if [[ "${OCSSD_PROC}" != "0" ]]; then
  OCSSD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "ocssd.bin" | awk '{ print $8 }' | uniq | sort)"
  OCSSD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "ocssd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " OCSSD " " RUNNING " " UP SINCE: ${OCSSD_STARTED} " " ${OCSSD_SERVICE}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
# OHASD
#
if [[ "${OHASD_PROC}" != "0" ]]; then
  OHASD_SERVICE="$(ps -ef | egrep -v "grep|egrep" | egrep "ohasd.bin" | awk '{ print $8 }' | uniq | sort)"
  OHASD_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "ohasd.bin" | awk '{ print $5 }' | uniq | tail -2)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " OHASD " " RUNNING " " UP SINCE: ${OHASD_STARTED} " " ${OHASD_SERVICE}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
# LISTENER
#
if [[ "${LISTENER_PROC}" != "0" ]]; then
  USING_GRID="$(cat ${ORA_INVENTORY} | egrep "CRS=" | wc -l)"
  for LISTENER_SERVICE in $(ps -ef | egrep -i -v "sshd|grep|egrep|zabbix|java" | egrep -i "listener"               | awk '{ print $9 }' | uniq | sort); do
           LISTENER_HOME="$(ps -ef | egrep -i -v "sshd|grep|egrep|zabbix|java" | egrep -i -w "${LISTENER_SERVICE}" | awk '{ print $8 }' | uniq | sort | sed 's/\/bin\/tnslsnr.*//')"
        LISTENER_STARTED="$(ps -ef | egrep -i -v "sshd|grep|egrep|zabbix|java" | egrep -i -w "${LISTENER_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
           if [[ "${USING_GRID}" == "0" ]]; then
              LISTENER_PORT="$(${LISTENER_HOME}/bin/lsnrctl status ${LISTENER_SERVICE} | egrep -i "PORT=" | sed -n 's/.*(PORT=\([0-9]*\)).*/\1/p' | uniq)"
            else
              LISTENER_PORT="$(${LISTENER_HOME}/bin/srvctl config listener -listener ${LISTENER_SERVICE} | egrep "End points:" | awk '{ print $3 }')"
            fi
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${LISTENER_SERVICE} [${LISTENER_PORT}]" " RUNNING " " UP SINCE: ${LISTENER_STARTED} " " ${LISTENER_HOME}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# DGMGRL OBSERVER
#
if [[ "${DGOBS_PROC}" != "0" ]]; then
  for DGOBS_SERVICE in $(ps -ef | egrep -v "grep|egrep" | egrep "observer" | awk '{ print $15 }' | uniq | sort); do
    DGOBS_STARTED="$(ps -ef | egrep -v "grep|egrep" | egrep "${DGOBS_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " OBSERVER " " RUNNING " " UP SINCE: ${DGOBS_STARTED} " " ${DGOBS_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# AGENT
#
if [[ "${AGENT_PROC}" != "0" ]]; then
  for AGENT_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "agent" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    AGENT_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${AGENT_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " AGENT " " RUNNING " " UP SINCE: ${LISTENER_STARTED} " " ${AGENT_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# MIDDLEWARE
#
if [[ "${OMS_PROC}" != "0" ]]; then
  for OMS_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "oms" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    OMS_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${OMS_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " OMS " " RUNNING " " UP SINCE: ${OMS_STARTED} " " ${OMS_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# WEBLOGIC
#
if [[ "${WLS_PROC}" != "0" ]]; then
  for WLS_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "OracleHome1" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    WLS_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${WLS_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " WEBLOGIC " " RUNNING " " UP SINCE: ${WLS_STARTED} " " ${WLS_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# GOLDENGATE
#
if [[ "${OGG_PROC}" != "0" ]]; then
  for OGG_SERVICE in $(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "goldengate|ogg|gg" | awk '{ print $3 }' | cut -f2 -d '=' | cut -f2 -d '"' | uniq | sort); do
    OGG_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${OGG_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " OGG " " RUNNING " " UP SINCE: ${OGG_STARTED} " " ${OGG_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# ORDS
#
if [[ "${ORDS_PROC}" != "0" ]]; then
  for ORDS_SERVICE in $(ps -ef | egrep -i -v "grep|egrep" | egrep -i "ords.war" | awk '{ print $9 }' | sed s/-Doracle.dbtools.cmdline.home=//g | uniq | sort); do
    ORDS_STARTED="$(ps -ef | egrep -i "grep|egrep|zabbix" | egrep -i -w "${ORDS_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
    printf "|%-31s|%-31s|%-31s|%-60s|\n" " ORDS " " RUNNING " " UP SINCE: ${ORDS_STARTED} " " ${ORDS_SERVICE}"
    printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
  done
fi
#
# DATABASE
#
if [[ "$(whoami)" == "oracle" ]] || [[ "$(whoami)" == "grid" ]] ; then
  if [[ "${DATABASE_PROC}" != "0" ]]; then
    for DATABASE_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ora_pmon|db_pmon" | awk '{ print $NF }' | sed s/ora_pmon_//g | sed s/db_pmon_//g | uniq | sort); do
      if [[ $(cat ${ORATAB} | egrep -v "^#|^$" | awk '{ print $1 }' | cut -f1 -d ':' | sed 's/_.*//' | egrep -w "${DATABASE_SERVICE}") != ${DATABASE_SERVICE} ]]; then
        DATABASE_STARTED="$(ps -ef | egrep -i "ora_pmon|db_pmon" | egrep -i "${DATABASE_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
           DATABASE_TYPE="$(ps -ef | egrep -i "ora_mrp" | egrep -i "${DATABASE_SERVICE}" | sort | wc -l | xargs | uniq)"
           DATABASE_ROLE="$(if [[ "${DATABASE_TYPE}" == "0" ]]; then echo "[ PRIMARY ]"; else echo "[ STANDBY ]"; fi)"
        printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED} " " ${DATABASE_TYPE} ${DATABASE_ROLE}"
        printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
      else
ORAENV_ASK=NO
ORACLE_SID=${DATABASE_SERVICE}
. /usr/local/bin/oraenv <<< ${ORACLE_SID} > /dev/null
#
# DATABASE STATUS
#
DATABASE_STATUS="$(echo "select status || ' ' || (select case when value = 'TRUE' then '[ RAC ]' else '[ SING ]' end from v\$parameter where name = 'cluster_database') as status from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE ROLE
#
DATABASE_ROLE="$(echo "select database_role from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE OPEN MODE
#
DATABASE_MODE="$(echo "select case when OPEN_MODE = 'READ WRITE' then '[ RW ]' when OPEN_MODE = 'READ ONLY' then '[ RO ]' when OPEN_MODE = 'READ ONLY WITH APPLY' THEN '[ RO-WA ]' when OPEN_MODE = 'MOUNTED' then '[ MO ]' when OPEN_MODE = 'MIGRATE' then '[ MI ]' end as OPEN_MODE from v\$database;" | sqlplus -S / as sysdba | tail -2)"
#
# DATABASE STARTED UP
#
DATABASE_STARTED="$(echo "select to_char(startup_time, 'YYYY-MM-DD') from v\$instance;" | sqlplus -S / as sysdba | tail -2)"
#
# DB RESULT
#
      printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${DATABASE_SERVICE} " " ${DATABASE_STATUS} " " ${DATABASE_ROLE} ${DATABASE_MODE}" " ${ORACLE_HOME}"
      printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
    fi
    done
  fi
else 
  if [[ "${DATABASE_PROC}" != "0" ]]; then
    for DATABASE_SERVICE in $(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ora_pmon|db_pmon" | awk '{ print $NF }' | sed s/ora_pmon_//g | sed s/db_pmon_//g | uniq | sort); do
      DATABASE_STARTED="$(ps -ef | egrep -i "ora_pmon|db_pmon" | egrep -i "${DATABASE_SERVICE}" | awk '{ print $5 }' | uniq | tail -2)"
         DATABASE_TYPE="$(ps -ef | egrep -i "ora_mrp" | egrep -i "${DATABASE_SERVICE}" | sort | wc -l | xargs | uniq)"
         DATABASE_ROLE="$(if [[ "${DATABASE_TYPE}" == "0" ]]; then echo "[ PRIMARY ]"; else echo "[ STANDBY ]"; fi)"
      if [[ "$(cat ${ORATAB} | egrep -v "^#|^$" | awk '{ print $1 }' | cut -f1 -d ':' | sed 's/_.*//' | egrep -w "${DATABASE_SERVICE}" | wc -l | xargs | uniq)" == "0" ]]; then
        printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED} " " ${DATABASE_ROLE} "
        printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
      else
        DATABASE_HOMES="$(cat ${ORATAB} | egrep -v "^#|^$" | sed 's/_.*//' | egrep -w "${DATABASE_SERVICE}" | cut -f2 -d ':' | uniq)"
        printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${DATABASE_SERVICE} " " RUNNING " " UP SINCE: ${DATABASE_STARTED} " " ${DATABASE_HOMES} ${DATABASE_ROLE} "
        printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
      fi
    done
  fi
fi
# printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
}
#
# --------------------------------------------------------------------------------------------------------------------------------------------
#
OracleProducts() {
#
# ASM OK
# DATABASE OK
# CLIENT OK
# AGENT OK
# MIDDLEWARE OK
# WEBLOGIC OK
# GOLDENGATE OK
# ORDS OK
#
if [[ "$(echo ${ASM_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${DATABASE_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${CLIENT_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${AGENT_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${OMS_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${WLS_HOME} | wc -l | xargs)" != "0" ]] || [[ "$(echo ${OGG_HOME} | wc -l | xargs)" != "0" ]]; then
#
printf "+%-31s+\n"    "-------------------------------"
printf "|%-31s%-s|\n" " ORACLE PRODUCTS INSTALLED     "
printf "+%-31s+\n"    "-------------------------------"
#
printf "+%-30s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
printf "|%-30s|%-50s|%-16s|\n" " HOME NAME                     " " HOME PATH                                                  " " OWNER                "
printf "+%-30s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
#
# ASM HOME AND OWNER
#
if [[ "$(echo ${ASM_HOME} | wc -l | xargs)" != "0" ]]; then
  for ASM_INVENTORY in ${ASM_HOME}; do
        ASM_OWNER="$(ls -l ${ASM_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    ASM_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${ASM_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${ASM_HOME_NAME} " " ${ASM_INVENTORY} " " ${ASM_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# DB HOME AND OWNER
#
if [[ "$(echo ${DATABASE_HOME} | wc -l | xargs)" != "0" ]]; then
  for DATABASE_INVENTORY in ${DATABASE_HOME}; do
        DB_OWNER="$(ls -l ${DATABASE_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    DB_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${DATABASE_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${DB_HOME_NAME} " " ${DATABASE_INVENTORY} " " ${DB_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# CLIENT HOME AND OWNER
#
if [[ "$(echo ${CLIENT_HOME} | wc -l | xargs)" != "0" ]]; then
  for CLIENT_INVENTORY in ${CLIENT_HOME}; do
        CLIENT_OWNER="$(ls -l ${CLIENT_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    CLIENT_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${CLIENT_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${CLIENT_HOME_NAME} " " ${CLIENT_INVENTORY} " " ${CLIENT_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# AGENT HOME AND OWNER
#
if [[ "$(echo ${AGENT_HOME} | wc -l | xargs)" != "0" ]]; then
  for AGENT_INVENTORY in ${AGENT_HOME}; do
        AGENT_OWNER="$(ls -l ${AGENT_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    AGENT_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${AGENT_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${AGENT_HOME_NAME} " " ${AGENT_INVENTORY} " " ${AGENT_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# MIDDLEWARE HOME AND OWNER
#
if [[ "$(echo ${OMS_HOME} | wc -l | xargs)" != "0" ]]; then
  for OMS_INVENTORY in ${OMS_HOME}; do
        OMS_OWNER="$(ls -l ${OMS_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    OMS_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${OMS_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${OMS_HOME_NAME} " " ${OMS_INVENTORY} " " ${OMS_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# WEBLOGIC HOME AND OWNER
#
if [[ "$(echo ${WLS_HOME} | wc -l | xargs)" != "0" ]]; then
  for WLS_INVENTORY in ${WLS_HOME}; do
        WLS_OWNER="$(ls -l ${WLS_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    WLS_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${WLS_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${WLS_HOME_NAME} " " ${WLS_INVENTORY} " " ${WLS_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
# GOLDENGATE HOME AND OWNER
#
if [[ "$(echo ${OGG_HOME} | wc -l | xargs)" != "0" ]]; then
  for OGG_INVENTORY in ${OGG_HOME}; do
        OGG_OWNER="$(ls -l ${OGG_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    OGG_HOME_NAME="$(cat ${ORA_INVENTORY} | egrep -i -v "${ORA_HOMES_IGNORE_0}" | egrep -i "LOC" | egrep -i "${OGG_INVENTORY}" | awk '{ print $2 }' | cut -f2 -d '=' | cut -f2 -d '"')"
    printf "|%-31s|%-60s|%-22s|\n" " ${OGG_HOME_NAME} " " ${OGG_INVENTORY} " " ${OGG_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
#
# ORDS HOME
#
if [[ "$(echo ${ORDS_HOME} | wc -l | xargs)" != "0" ]]; then
  for ORDS_INVENTORY in $(echo ${ORDS_HOME}); do
        ORDS_OWNER="$(ls -l ${ORDS_INVENTORY} | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)"
    printf "|%-31s|%-60s|%-22s|\n" " ORDS " " ${ORDS_INVENTORY} " " ${ORDS_OWNER}"
    printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
  done
fi
#
fi
}
#
# --------------------------------------------------------------------------------------------------------------------------------------------
# 
nonOracleServices() {
#
# MYSQL OK
# POSTGRES OK
# DB2 OK
#
if [[ "${MYSQL_PROC}" != "0" ]] || [[ "${PSQL_PROC}" != "0" ]] || [[ "${DB2_PROC}" != "0" ]]; then
#
printf "+%-31s+\n"    "-------------------------------"
printf "|%-31s%-s|\n" " NON ORACLE SERVICES RUNNING   "
printf "+%-31s+\n"    "-------------------------------"
#
printf "+%-31s+%-25s+%-25s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
printf "|%-31s|%-25s|%-25s|%-50s|\n" " SERVICE                       " " STATUS                        " " INFO                          " " NON ORACLE HOME                                            "
printf "+%-31s+%-25s+%-25s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
#
if [[ "${MYSQL_PROC}" != "0" ]]; then
  MYSQL_SERVICE="$(command -v mysql)"
  MYSQL_STARTED="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "bin/mysqld" | awk '{ print $5 }'  | uniq | tail -2)"
     MYSQL_HOME="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "bin/mysqld" | awk '{ print $NF }' | uniq | sort)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${MYSQL_SERVICE} " " RUNNING " " UP SINCE: ${MYSQL_STARTED} " " ${MYSQL_HOME}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
if [[ "${PSQL_PROC}" != "0" ]]; then
  PSQL_SERVICE="$(command -v psql)"
  PSQL_STARTED="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "bin/postgres" | awk '{ print $5 }'  | uniq | tail -2)"
     PSQL_HOME="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "bin/postgres" | awk '{ print $NF }' | uniq | sort)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${PSQL_SERVICE} " " RUNNING " " UP SINCE: ${PSQL_STARTED} " " ${PSQL_HOME}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
#
if [[ "${DB2_PROC}" != "0" ]]; then
  DB2_SERVICE="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ibm/db2" | awk '{ print $8 }'  | uniq | tail -2)"
  DB2_STARTED="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ibm/db2" | awk '{ print $5 }'  | uniq | tail -2)"
     DB2_HOME="$(ps -ef | egrep -i -v "grep|egrep|sed" | egrep -i "ibm/db2" | awk '{ print $NF }' | uniq | sort)"
  printf "|%-31s|%-31s|%-31s|%-60s|\n" " ${DB2_SERVICE} " " RUNNING " " UP SINCE: ${DB2_STARTED} " " ${DB2_HOME}"
  printf "+%-31s+%-31s+%-31s+%-50s+\n" "-------------------------------" "-------------------------------" "-------------------------------" "------------------------------------------------------------"
fi
#
fi
}
#
# --------------------------------------------------------------------------------------------------------------------------------------------
#
nonOracleProducts() {
#
# MYSQL OK
# POSTGRES OK
# DB2 OK
#
### if [[ "$(command -v mysql | wc -l | xargs)" != "0" ]] || [[ "$(command -v psql | wc -l | xargs)" != "0" ]] || [[ "$(db2ls | tail -1 | wc -l | xargs)" != 0 ]]; then
if [[ "$(command -v mysql | wc -l | xargs)" != "0" ]] || [[ "$(command -v psql | wc -l | xargs)" != "0" ]] || [[ "$(command -v db2ls | tail -1 | wc -l | xargs)" != 0 ]]; then
#
printf "+%-31s+\n"    "-------------------------------"
printf "|%-31s%-s|\n" " NON ORACLE PRODUCTS INSTALLED "
printf "+%-31s+\n"    "-------------------------------"
#
printf "+%-30s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
printf "|%-30s|%-50s|%-16s|\n" " PRODUCT NAME                  " " PRODUCT PATH                                               " " OWNER                "
printf "+%-30s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
#
if [[ "$(command -v mysql | wc -l | xargs)" != 0 ]]; then
     MYSQL_PATH=$(command -v mysql)
  MYSQL_VERSION=$(mysql --version | awk '{ print $3 }' | cut -d. -f1)
    MYSQL_OWNER=$(ls -l "${MYSQL_PATH}" | awk '{ print $3 }')
  printf "|%-31s|%-60s|%-22s|\n" " MYSQL-${MYSQL_VERSION} " " ${MYSQL_PATH} " " ${MYSQL_OWNER} "
  printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
fi
#
if [[ "$(command -v psql | wc -l | xargs)" != 0 ]]; then
     PSQL_PATH=$(command -v psql)
  PSQL_VERSION=$(psql --version | awk '{ print $3 }' | cut -d. -f1)
    PSQL_OWNER=$(ls -l "${PSQL_PATH}" | awk '{ print $3 }')
  printf "|%-31s|%-60s|%-22s|\n" " POSTGRES-${PSQL_VERSION} " " ${PSQL_PATH} " " ${PSQL_OWNER} "
  printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
fi
#
### if [[ "$(db2ls | tail -1 | wc -l | xargs)" != 0 ]]; then
if [[ "$(command -v db2ls | tail -1 | wc -l | xargs)" != 0 ]]; then
     DB2_PATH=$(db2ls | tail -1 | awk '{ print $1 }')
  DB2_VERSION=$(db2ls | tail -1 | awk '{ print $2 }')
    DB2_OWNER=$(ls -l "${DB2_PATH}/bin" | awk '{ print $3 }' | egrep -i -v "root" | egrep -Ev "^$" | uniq)
  printf "|%-31s|%-60s|%-22s|\n" " DB2-${DB2_VERSION} " " ${DB2_PATH} " " ${DB2_OWNER} "
  printf "+%-31s+%-50s+%-16s+\n" "-------------------------------" "------------------------------------------------------------" "----------------------"
fi
#
fi
}
#
OracleServices
OracleProducts
nonOracleServices
nonOracleProducts
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
#
