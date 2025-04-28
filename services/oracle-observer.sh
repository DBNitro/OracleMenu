#!/bin/sh
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.1"
DateCreation="23/07/2024"
DateModification="23/07/2024"
EMAIL_1="dba.ribas@gmail.com"
EMAIL_2="andre.ribas@icloud.com"
WEBSITE="http://dbnitro.net"
#
export LOG=/var/log/oracle_fsfoi_???_init.log
export LOCK=/var/lock/subsys/oracle_fsfoi_???.lock
export DATE=$(date +%d\/%m\/%Y\ %H\:%M)
export ORACLE_VERSION="19.3.0.1"
export ORACLE_BASE="/u01/app/oracle"
export ORACLE_HOME="${ORACLE_BASE}/product/${ORACLE_VERSION}/db_EE_01"

#
if [[ $1 == "" ]]; then
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
elif [[ $1 == "start" ]]; then

  dgmgrl -silent /@${SID} "start observer ${HOST} File is ${DAT} LogFile is ${LOG}" &

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "stop" ]]; then

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "restart" ]]; then

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Stop Successfully." >> /var/log/oracle-observer.log
  #

  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully."
  echo "$(date +%Y-%m-%d_%H\:%M) - Oracle Dataguard Observer Start Successfully." >> /var/log/oracle-observer.log
elif [[ $1 == "status" ]]; then

else
  echo "Usage: oracle {start|stop|restart|status}"
  exit 1
fi
