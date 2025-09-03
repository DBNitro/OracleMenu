#!/bin/sh
#
Author="Andre Augusto Ribas"
SoftwareVersion="1.0.25"
DateCreation="26/04/2024"
DateModification="07/02/2025"
EMAIL="ribas@dbnitro.net"
GITHUB="https://github.com/DBNitro"
WEBSITE="http://dbnitro.net"
#
# ------------------------------------------------------------------------
# This script will do that:
# Prepare Unix/Linux for Oracle Products like: Grid, Database, Agent, Enterprise Manager, Golden Gate
# 
# ------------------------------------------------------------------------
# Separate Line Function
#
SepLine() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - 
}
#
# ------------------------------------------------------------------------
# Title Function
#
SetTitle() {
  printf "+%-100s+\n" "----------------------------------------------------------------------------------------------------"
}
#
# ------------------------------------------------------------------------
# Clear Screen Function
#
SetClear() {
  printf "\033c"
}
#
# ------------------------------------------------------------------------
# First Checks
#
if [[ "$(whoami)" != "root" ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- YOU ARE NOT ROOT, YOU MUST BE ROOT TO EXECUTE THIS SCRIPT --"
  SetTitle
  exit 1
fi
#
if [[ "$(which wget | wc -l | awk '{ print $1 }')" == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- You need to install wget app --"
  SetTitle
  exit 1
fi
#
if [[ "$(which unzip | wc -l | awk '{ print $1 }')" == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- You need to install unzip app --"
  SetTitle
  exit 1
fi
#
if [[ "$(which bc | wc -l | awk '{ print $1 }')" == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- You need to install bc app --"
  SetTitle
  exit 1
fi
#
if [[ "$(which sshpass | wc -l | awk '{ print $1 }')" == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- You need to install sshpass app --"
  SetTitle
  exit 1
fi
#
if [[ "$(uname -i)" == "x86_64" ]]; then
  ARCHITECTURE="x86_64"
elif [[ "$(uname -i)" == "aarch64" ]]; then
  ARCHITECTURE="ARM-64"
else
  SetClear
  SepLine
  SetTitle
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  SetTitle
  exit 1
fi
#
# ------------------------------------------------------------------------
# Variables
#           # ===> HERE YOU HAVE TO CONFIGURE THE PATH OF DBNITRO, WHERE IT WILL BE INSTALLED
       FOLDER="/opt"
      DBNITRO="${FOLDER}/dbnitro"
         LOGS="${DBNITRO}/logs"
        TOOLS="${DBNITRO}/tools"
       BACKUP="${DBNITRO}/backup"
      REPORTS="${DBNITRO}/reports"
     BINARIES="${DBNITRO}/bin"
     SERVICES="${DBNITRO}/services"
    VARIABLES="${DBNITRO}/var"
    FUNCTIONS="${DBNITRO}/functions"
  ENVIRONMENT="${DBNITRO}/environments"
   STATEMENTS="${DBNITRO}/sql"
          PCT="90"
          PRC="3000"
          MNI="4096"
         PROC="$(echo "${PRC} + 50" | bc)"
          MEM="$(free -m | egrep -i "Mem:" | awk '{ print $2 }')"
        MEM_G="$(free -g | egrep -i "Mem:" | awk '{ print $2 }')"
          SGA="$(echo "${MEM}   * ${PCT} / 100" | bc)"
        SGA_G="$(echo "${MEM_G} * ${PCT} / 100" | bc)"
          PGA="$(echo "${SGA}   * 10     / 100" | bc)"
        PGA_G="$(echo "${SGA_G} * 10     / 100" | bc)"
          MAX="$(echo "${SGA}   * 1024 * 1024 * 1024" | bc)"
          ALL="$(echo "(${SGA}  * 1024 * 1024 * 1024) / ${MNI}" | bc)"
          HPG="$(echo "(${SGA}  * 1024 * 1024 * 1024) / 2048 / 1024 / 1024" | bc)"    ### => 90% OF PHYSICAL MEMORY = SGA_G * 1024 / 2 + 1 = HPG ===> IT MUST BE BIGGER THEN THE SGA
   OS_VERSION="$(cat /etc/os-release | egrep "VERSION_ID=" | cut -f2 -d '=' -d '"')"
   PACKAGES_8="atop avahi-libs bc beakerlib-vim-syntax bind-libs bind-license bind-utils binutils bzip2 bzip2-devel bzip2-libs chrony cockpit cpp dialog elfutils-libelf elfutils-libelf-devel firefox fontconfig fontconfig-devel freetype fstrm fzf gcc gcc-c++ glances glibc glibc-common glibc-devel glibc-headers glibc-utils graphite2 gssproxy harfbuzz htop iftop iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio kernel-headers keyutils ksh libaio libaio-devel libgcc libgfortran libibverbs libiscsi libnsl libnsl2 libnfsidmap librdmacm libstdc++ libstdc++-devel libICE libSM libX11 libX11-common libX11-xcb libXau libXcomposite libXext libXi libXinerama libXmu libXrandr libXrender libXt libXv libXtst libdmx libev libXtst-devel libXxf86dga libXxf86vm libxcb libpkgconf libpng libtirpc libuv libverto-libev libXp libXp-devel libXpm libXpm-devel libxcrypt-devel lm_sensors lm_sensors-libs lsof lsscsi make mlocate nawk ncurses ncurses-base.noarch ncurses-c++-libs ncurses-compat-libs ncurses-devel ncurses-libs ncurses-term.noarch neofetch net-tools nfs-utils nmap numactl perl perl-CGI perl-CPAN perl-DBI perl-ExtUtils-MakeMaker perl-TermReadKey perl-URI.noarch policycoreutils policycoreutils-python-utils psmisc readline-devel rlwrap rsync pcp-conf pcp-libs pkgconf pkgconf-m4 pkgconf-pkg-config protobuf-c quota quota-nls rpcbind smartmontools smem sos sshpass strace sssd-nfs-idmap sysstat targetcli telnet tmux tuned tuned-utils tar unixODBC unixODBC-devel unzip vim-common vim-enhanced vim-filesystem vim-minimal vim-X11 wget whois xml-common xorg-x11-server-common xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xauth xterm"
   PACKAGES_9="atop avahi-libs bc beakerlib-vim-syntax bind-libs bind-license bind-utils binutils bzip2 bzip2-devel bzip2-libs chrony cockpit cpp dialog elfutils-libelf elfutils-libelf-devel firefox fontconfig fontconfig-devel freetype fstrm fzf gcc gcc-c++ glances glibc glibc-common glibc-devel               glibc-utils graphite2 gssproxy harfbuzz htop iftop iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio kernel-headers keyutils ksh libaio libaio-devel libgcc libgfortran libibverbs libiscsi libnsl libnsl2 libnfsidmap librdmacm libstdc++ libstdc++-devel libICE libSM libX11 libX11-common libX11-xcb libXau libXcomposite libXext libXi libXinerama libXmu libXrandr libXrender libXt libXv libXtst libdmx libev libXtst-devel libXxf86dga libXxf86vm libxcb libpkgconf libpng libtirpc libuv libverto-libev libXp libXp-devel libXpm libXpm-devel libxcrypt-devel lm_sensors lm_sensors-libs lsof lsscsi make mlocate      ncurses ncurses-base.noarch ncurses-c++-libs ncurses-compat-libs ncurses-devel ncurses-libs ncurses-term.noarch neofetch net-tools nfs-utils nmap numactl perl perl-CGI perl-CPAN perl-DBI perl-ExtUtils-MakeMaker perl-TermReadKey perl-URI.noarch policycoreutils policycoreutils-python-utils psmisc readline-devel rlwrap rsync pcp-conf pcp-libs pkgconf pkgconf-m4 pkgconf-pkg-config protobuf-c quota quota-nls rpcbind smartmontools smem sos sshpass strace sssd-nfs-idmap sysstat targetcli telnet tmux tuned tuned-utils tar unixODBC                unzip vim-common vim-enhanced vim-filesystem vim-minimal vim-X11 wget whois xml-common xorg-x11-server-common xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xauth xterm"
  PACKAGES_10="atop avahi-libs bc beakerlib-vim-syntax bind-libs bind-license bind-utils binutils bzip2 bzip2-devel bzip2-libs chrony cockpit cpp dialog elfutils-libelf elfutils-libelf-devel firefox fontconfig fontconfig-devel freetype fstrm fzf gcc gcc-c++ glances glibc glibc-common glibc-devel               glibc-utils graphite2 gssproxy harfbuzz htop iftop iotop iptraf-ng iscsi-initiator-utils iscsi-initiator-utils-iscsiuio kernel-headers keyutils ksh libaio libaio-devel libgcc libgfortran libibverbs libiscsi libnsl libnsl2 libnfsidmap librdmacm libstdc++ libstdc++-devel libICE libSM libX11 libX11-common libX11-xcb libXau libXcomposite libXext libXi libXinerama libXmu libXrandr libXrender libXt libXv libXtst libdmx libev libXtst-devel libXxf86dga libXxf86vm libxcb libpkgconf libpng libtirpc libuv libverto-libev libXp libXp-devel libXpm libXpm-devel libxcrypt-devel lm_sensors lm_sensors-libs lsof lsscsi make mlocate      ncurses ncurses-base.noarch ncurses-c++-libs ncurses-compat-libs ncurses-devel ncurses-libs ncurses-term.noarch neofetch net-tools nfs-utils nmap numactl perl perl-CGI perl-CPAN perl-DBI perl-ExtUtils-MakeMaker perl-TermReadKey perl-URI.noarch policycoreutils policycoreutils-python-utils psmisc readline-devel rlwrap rsync pcp-conf pcp-libs pkgconf pkgconf-m4 pkgconf-pkg-config protobuf-c quota quota-nls rpcbind smartmontools smem sos sshpass strace sssd-nfs-idmap sysstat targetcli telnet tmux tuned tuned-utils tar unixODBC                unzip vim-common vim-enhanced vim-filesystem vim-minimal vim-X11 wget whois xml-common xorg-x11-server-common xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xauth xterm"
# rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_8} | egrep "is not installed"
# dnf -y install $PACKAGES_8
# ------------------------------------------------------------------------
# Help to use this script
#
HELP() {
  SetClear
  SepLine
  printf "+%-30s+%-100s+\n" "------------------------------" "----------------------------------------------------------------------------------------------------"
  printf "|%-16s|%-100s|\n" " DBNITRO.net                  " " ORACLE :: HELP "
  printf "+%-30s+%-100s+\n" "------------------------------" "----------------------------------------------------------------------------------------------------"
  printf "|%-16s|%-100s|\n" "               LinuxConfigure " " YOU WILL CONFIGURE THE LINUX FOR ORACLE PRODUCTS"
  printf "|%-16s|%-100s|\n" "                  LinuxUpdate " " YOU WILL UPDATE YOUR LINUX SERVER"
  printf "|%-16s|%-100s|\n" "                 PackageCheck " " YOU WILL CHECK THE LINUX PACKAGES"
  printf "|%-16s|%-100s|\n" "               PackageInstall " " YOU WILL INSTALL THE LINUX PACKAGES"
  printf "|%-16s|%-100s|\n" "                  LinuxKernel " " YOU WILL CONFIGURE THE LINUX KERNEL FOR ORACLE PRODUCTS"
  printf "|%-16s|%-100s|\n" "                 DBNitroSetup " " YOU WILL INSTALL THE DBNITRO SOFTWARE"
  printf "|%-16s|%-100s|\n" "                DBNitroUpdate " " YOU WILL UPDATE THE DBNITRO SOFTWARE"
  printf "|%-16s|%-100s|\n" "                DBNitroRemove " " YOU WILL REMOVE THE DBNITRO SOFTWARE"
  printf "|%-16s|%-100s|\n" "                   Oracle_19c " " YOU WILL DOWNLOAD THE ORACLE 19c Enterprise Version"
  printf "|%-16s|%-100s|\n" "                   Oracle_21c " " YOU WILL DOWNLOAD THE ORACLE 21c Enterprise Version"
  printf "|%-16s|%-100s|\n" "                  Oracle_23ai " " YOU WILL DOWNLOAD THE ORACLE 23ai Enterprise Version"
  printf "|%-16s|%-100s|\n" "              Oracle_23aiFree " " YOU WILL DOWNLOAD THE ORACLE 23ai Free Version"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_JAN_2023 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From JANUARY 2023"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_APR_2023 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From APRIL 2023"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_JUL_2023 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From JULY 2023"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_OCT_2023 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From OCTOBER 2023"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_JAN_2024 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From JANUARY 2024"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_APR_2024 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From APRIL 2024"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_JUL_2024 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From JULY 2024"
  printf "|%-16s|%-100s|\n" "          Oracle_19C_OCT_2024 " " YOU WILL DOWNLOAD THE ORACLE 19c Patches From OCTOBER 2024"
  printf "|%-16s|%-100s|\n" "                         HELP " " YOU CAN CHECK THE OPTIONS"
  printf "|%-16s|%-100s|\n" "                         QUIT " " QUIT THIS SCRITP"
  printf "+%-30s+%-100s+\n" "------------------------------" "----------------------------------------------------------------------------------------------------"
}
#
# ------------------------------------------------------------------------
# Configure the Linux Users
#
ConfigureLinuxUsers() {
  SetClear
  SepLine
  echo " -- CONFIGURING ROOT PASSWORDLESS --"
  echo ""
  read -s -p "Enter ROOT Password: " ROOT_PASSWORD
  echo ""
  echo " -- CONFIGURING GRID PASSWORDLESS --"
  echo ""
  read -s -p "Enter GRID Password: " GRID_PASSWORD
  echo ""
  echo " -- CONFIGURING ORACLE PASSWORDLESS --"
  echo ""
  read -s -p "Enter ORACLE Password: " ORACLE_PASSWORD
  echo ""
  SetTitle
}
#
# ------------------------------------------------------------------------
# Configure the DBNITRO Folders
#
ConfigureFolders() {
  SetClear
  SepLine
  SetTitle
  echo " -- CREATING DBNITRO FOLDERS --"
  SetTitle
if [[ ! -d ${FOLDER}/dbnitro ]];       then mkdir -p ${FOLDER}/dbnitro;       fi
if [[ ! -d ${DBNITRO}/bin ]];          then mkdir -p ${DBNITRO}/bin;          fi
if [[ ! -d ${DBNITRO}/var ]];          then mkdir -p ${DBNITRO}/var;          fi
if [[ ! -d ${DBNITRO}/sql ]];          then mkdir -p ${DBNITRO}/sql;          fi
if [[ ! -d ${DBNITRO}/logs ]];         then mkdir -p ${DBNITRO}/logs;         fi
if [[ ! -d ${DBNITRO}/tools ]];        then mkdir -p ${DBNITRO}/tools;        fi
if [[ ! -d ${DBNITRO}/backup ]];       then mkdir -p ${DBNITRO}/backup;       fi
if [[ ! -d ${DBNITRO}/backup/logs ]];  then mkdir -p ${DBNITRO}/backup/logs;  fi
if [[ ! -d ${DBNITRO}/services ]];     then mkdir -p ${DBNITRO}/services;     fi
if [[ ! -d ${DBNITRO}/reports ]];      then mkdir -p ${DBNITRO}/reports;      fi
if [[ ! -d ${DBNITRO}/functions ]];    then mkdir -p ${DBNITRO}/functions;    fi
if [[ ! -d ${DBNITRO}/environments ]]; then mkdir -p ${DBNITRO}/environments; fi
}
#
# ------------------------------------------------------------------------
# ROOT PROFILE SETUP 
#
SetUpLinuxRoot() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP ROOT BASH_PROFILE --"
  echo " -- SELECT THE GRID INFRASTRUCTURE VERSION --"
  SetTitle
PS3="Select the Option: "
select GI_VERSION in "19c" "21c" "23ai"; do
if [[ "${GI_VERSION}" == "19c" ]]; then
  SetClear
  SetTitle
  echo " -- GRID VERSION SELECTED: ${GRID_VER_INST} --"
  SetTitle
  GRID_VER_INST="19.3.0.1"
elif [[ "${GI_VERSION}" == "21c" ]]; then
  SetClear
  SetTitle
  echo " -- GRID VERSION SELECTED: ${GRID_VER_INST} --"
  SetTitle
  GRID_VER_INST="21.3.0.1"
elif [[ "${GI_VERSION}" == "23ai" ]]; then
  SetClear
  SetTitle
  echo " -- GRID VERSION SELECTED: ${GRID_VER_INST} --"
  SetTitle
  GRID_VER_INST="23.4.0.1"
else
  SepLine
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
#
cat > ${DBNITRO}/environments/root_profile <<EOF
# User specific environment and startup programs
export GRID_VERSION=${GRID_VER_INST}
export ORACLE_BASE=/u01/app/grid
export GRID_HOME=/u01/app/\${GRID_VERSION}/grid
export ORACLE_HOME=\${GRID_HOME}
export LD_LIBRARY_PATH=\${ORACLE_HOME}/lib
export OPATCH=\${ORACLE_HOME}/OPatch
export JAVA_HOME=\${ORACLE_HOME}/jdk
### export JAVA_HOME=/usr/lib/jvm/jdk-11.0.24-oracle-aarch64/bin/java
export PATH=\${PATH}:\${HOME}/bin:\${GRID_HOME}/bin:\${OPATCH}:\${JAVA_HOME}/bin
export CRSLOG=\$(echo "set base \${ORACLE_BASE}; show homes" | adrci | egrep -i -v "crs_|_root" | egrep -i "/crs/")
export ALERTCRS=\$(adrci exec="set base \${ORACLE_BASE}; set home \${CRSLOG}; show tracefile" | egrep "alert.log" | tail -1 | awk '{ print \$1 }')
export PS1=$'[ \${LOGNAME}@\h:\$(pwd): ]\$ '
export OH=\${ORACLE_HOME}'
alias oh='\${ORACLE_HOME}'
alias p='ps -ef | egrep -v "grep|egrep|ruby" | egrep "pmon|ohasd|d.bin|weblogic" | sort'
alias hpg='grep HugePages_ /proc/meminfo'
alias lsm='lsmod | egrep oracle'
alias crslog='tail -f -n 100 \${ORACLE_BASE}/\${ALERTCRS}'
alias crslogv='vim \${ORACLE_BASE}/\${ALERTCRS}'
alias res='crsctl stat res -t'
alias rest='crsctl stat res -t -init'
alias resp='crsctl stat res -p -init'
alias rac-status='${DBNITRO}/bin/rac-status.sh -a'
alias rac-monitor='while true; do ${DBNITRO}/bin/rac-status.sh -a; sleep 5; done'
alias list='${DBNITRO}/bin/OracleList.sh'
alias list-monitor='while true; do ${DBNITRO}/bin/OracleList.sh; sleep 5; done'
alias nonoracle='${DBNITRO}/bin/nonOracle.sh
alias oratcp='java -jar ${DBNITRO}/bin/oratcptest.jar'
alias grid='su - grid'
alias oracle='su - oracle'
umask 0022
EOF
#
if [[ $(cat /root/.bash_profile | egrep "root_profile" | wc -l) == 0 ]]; then
  SetTitle
  echo " -- Configuring ROOT Profile --"
  SetTitle
  echo ". ${DBNITRO}/environments/root_profile" >> /root/.bash_profile
else
  SetTitle
  echo " -- ROOT Profile is Already Configured --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# Disable IPTABLES/FIREWALL
#
SetUpLinuxFirewall() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX FIREWALL --"
  SetTitle
  systemctl stop firewalld
  systemctl disable firewalld
}
#
# ------------------------------------------------------------------------
# Configure UTF-8 for SSH
#
SetUpLinuxUTF8() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX UTF-8 --"
  SetTitle
if [[ $(cat /etc/environment | egrep -i "LANG|LANGUAGE" | wc -l) == 0 ]]; then
cat >> /etc/environment <<EOF
### localectl set-locale LANG=en_US.UTF-8
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_COLLATE=C
EOF
else
  SepLine
  SetTitle 
  echo " -- LINUX ENVIRONMENT ALREADY CONFIGURED --"
  SetTitle 
fi
}
#
# ------------------------------------------------------------------------
# Configure NO ZERO CONF on NETWORK
#
SetUpLinuxNOZEROCONF() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX NO ZERO CONF NETWORK --"
  SetTitle
if [[ $(cat /etc/sysconfig/network | egrep -i "NOZEROCONF" | wc -l) == 0 ]]; then
  echo "NOZEROCONF=YES" >> /etc/sysconfig/network
else
  SepLine
  SetTitle 
  echo " -- LINUX NETWORK ALREADY CONFIGURED --"
  SetTitle 
fi
}
#
# ------------------------------------------------------------------------
# Configure SCP Problems
#
SetUpLinuxSCP() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX SCP --"
  SetTitle
  mv /usr/bin/scp /usr/bin/scp.orig
  echo "/usr/bin/scp.orig -T \$*" > /usr/bin/scp
  chmod 555 /usr/bin/scp
}
#
# ------------------------------------------------------------------------
# Setup /etc/hosts
#
SetUpLinuxHosts() {
  SetClear
  SepLine
  SetTitle
  echo " -- SELECT THE ORACLE TYPE OF INSTALLATION --"
  SetTitle
PS3="Select the Option: "
select TYPE in "Single Instances" "Cluster Instances"; do
if [[ "${TYPE}" == "Single Instances" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE TYPE SELECTED: ${TYPE} --"
  SetTitle
  echo "$(ip a | egrep -v "inet6|127.0.0.1" | egrep "inet" | awk '{ print $2 }' | cut -f1 -d '/')   $(hostname)   $(hostname -s)" >> /etc/hosts
elif [[ "${TYPE}" == "Cluster Instances" ]]; then
  if [[ $(cat /etc/hosts | egrep -i "Public|Private|Virtual" | wc -l) == 0 ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE TYPE SELECTED: ${TYPE} --"
  SetTitle
cat >> /etc/hosts <<EOF
#
# Public
#
10.0.1.21         srv01.dbnitro.net          srv01
10.0.1.22         srv02.dbnitro.net          srv02
10.0.1.23         srv03.dbnitro.net          srv03
10.0.1.24         srv04.dbnitro.net          srv04
10.0.1.25         srv05.dbnitro.net          srv05
10.0.1.26         srv06.dbnitro.net          srv06
#
# Private
#
172.16.2.21          srv01-priv.dbnitro.net          srv01-priv
172.16.2.22          srv02-priv.dbnitro.net          srv02-priv
172.16.2.23          srv03-priv.dbnitro.net          srv03-priv
172.16.2.24          srv04-priv.dbnitro.net          srv04-priv
172.16.2.25          srv05-priv.dbnitro.net          srv05-priv
172.16.2.26          srv06-priv.dbnitro.net          srv06-priv
#
# Virtual
#
10.0.1.31          srv01-vip.dbnitro.net          srv01-vip
10.0.1.32          srv02-vip.dbnitro.net          srv02-vip
10.0.1.33          srv03-vip.dbnitro.net          srv03-vip
10.0.1.34          srv04-vip.dbnitro.net          srv04-vip
10.0.1.35          srv05-vip.dbnitro.net          srv05-vip
10.0.1.36          srv06-vip.dbnitro.net          srv06-vip
#
# PRODUCTION SCAN
#
10.0.1.41          production-scan.dbnitro.net          production-scan
10.0.1.42          production-scan.dbnitro.net          production-scan
10.0.1.43          production-scan.dbnitro.net          production-scan
#
# STANDBY SCAN
#
10.0.1.51          standby-scan.dbnitro.net          standby-scan
10.0.1.52          standby-scan.dbnitro.net          standby-scan
10.0.1.53          standby-scan.dbnitro.net          standby-scan
#
# STORAGES
#
10.0.1.251        stg01.dbnitro.net          stg01
10.0.1.252        stg02.dbnitro.net          stg02
#
EOF
  else
    SepLine
    SetTitle 
    echo " -- LINUX HOSTS ALREADY CONFIGURED --"
    SetTitle 
  fi
#
else
  SepLine
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
}
#
# ------------------------------------------------------------------------
# Disable SELINUX
#
SetUpLinuxSeLinux() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX SE LINUX --"
  SetTitle
cat > /etc/sysconfig/selinux <<EOF
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these two values:
#     targeted - Targeted processes are protected,
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
EOF
}
#
# ------------------------------------------------------------------------
# Configure limits.conf
#
SetUpLinuxSecurityLimits() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX SECURITY LIMITS --"
  SetTitle
if [[ $(cat /etc/security/limits.conf | egrep -i "# Oracle" | wc -l) == 0 ]]; then
cat >> /etc/security/limits.conf <<EOF
#
# Oracle Limits Configuration
#
 * soft nproc 4096
 * hard nproc 16384
 * soft nofile 65536
 * hard nofile 65536
 * soft stack 10240
 * hard stack 32768
 * soft memlock 60397977
 * hard memlock 60397977
EOF
else 
  SepLine
  SetTitle 
  echo " -- LINUX SECURITY LIMITS ALREADY CONFIGURED --"
  SetTitle 
fi
}
#
# ------------------------------------------------------------------------
# Linux Groups
#
SetUpLinuxGroups() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX GROUPS --"
  SetTitle
/usr/sbin/groupadd -g 54321 oinstall
/usr/sbin/groupadd -g 54322 dba
/usr/sbin/groupadd -g 54323 oper
/usr/sbin/groupadd -g 54324 backupdba
/usr/sbin/groupadd -g 54325 dgdba
/usr/sbin/groupadd -g 54326 kmdba
/usr/sbin/groupadd -g 54327 asmdba
/usr/sbin/groupadd -g 54328 asmoper
/usr/sbin/groupadd -g 54329 asmadmin
/usr/sbin/groupadd -g 54330 racdba
/usr/sbin/groupadd -g 54331 racoper
}
#
# ------------------------------------------------------------------------
# Linux Users
#
SetUpLinuxUsers() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX USERS --"
  SetTitle
/usr/sbin/useradd -u 54321 -g oinstall -G oinstall,dba,asmdba,asmadmin,asmoper,racdba,racoper grid
/usr/sbin/useradd -u 54322 -g oinstall -G oinstall,dba,oper,backupdba,asmdba,dgdba,kmdba,racoper,racdba oracle
#
/usr/sbin/usermod -u 54321 -g oinstall -G oinstall,dba,asmdba,asmadmin,asmoper,racdba,racoper grid
/usr/sbin/usermod -u 54322 -g oinstall -G oinstall,dba,oper,backupdba,asmdba,dgdba,kmdba,racoper,racdba oracle
#
cat /etc/group | egrep -i "oracle|grid"
#
echo 'grid:grid'     | chpasswd
echo 'oracle:oracle' | chpasswd
#
ssh-keygen  -f /root/.ssh/id_rsa -N ''
su - grid   -c "ssh-keygen -f /home/grid/.ssh/id_rsa   -N ''"
su - oracle -c "ssh-keygen -f /home/oracle/.ssh/id_rsa -N ''"
#
# ConfigureLinuxUsers
}
#
# ------------------------------------------------------------------------
# Create Users Password
#
SetUpLinuxUsersPasswords() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX USERS PASSWORDS --"
  SetTitle
  echo 'grid:grid'     | chpasswd
  echo 'oracle:oracle' | chpasswd
  # Root User
  ssh-keygen -f /root/.ssh/id_rsa -N ''
  # Grid and Oracle Users
  su - grid   -c "ssh-keygen -f /home/grid/.ssh/id_rsa -N ''"
  su - oracle -c "ssh-keygen -f /home/oracle/.ssh/id_rsa -N ''"
  #
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX USERS PASSWORDS FOR CLUSTER --"
  SetTitle
PS3="Select the Option: "
select TYPE in "Single Instances" "Cluster Instances"; do
if [[ "${TYPE}" == "Single Instances" ]]; then
  SetClear
  SetTitle
  echo " -- ALREADY CONFIGURED --"
  SetTitle
elif [[ "${TYPE}" == "Cluster Instances" ]]; then
  SetClear
  SetTitle
  echo " -- SETING UP LINUX USERS PASSWORDS FOR RAC ENVIRONMENT --"
  SetTitle
  echo " -- Please Insert the Server Names Separated by SPACE --"
  echo " -- EX: srv01 srv02 srv03 srv04 srv05 srv06 ..."
  echo ""
  read -r SERVERS
  echo ""
  if [[ "${SERVERS}" == "" ]]; then
    SetClear
    SetTitle
    echo " -- THE SERVER LIST CANNOT BE EMPTY, PLEASE TRY AGAIN --"
    break
  else
  for SERVER in ${SERVERS}; do
    ping -c1 -W1 -q ${SERVER} &>/dev/null
    PING=$( echo $? )
    if [[ "${PING}" == 0 ]]; then
      SetClear
      SetTitle
      sshpass -p ssh-copy-id -o StrictHostKeyChecking=no root@${SERVER}
      su - grid   -c "sshpass -p "${GRID_PASSWORD}"   ssh-copy-id -o StrictHostKeyChecking=no grid@${SERVER}"
      su - oracle -c "sshpass -p "${ORACLE_PASSWORD}" ssh-copy-id -o StrictHostKeyChecking=no oracle@${SERVER}"
    else
      SetClear
      SetTitle
      echo " -- SERVER: [ ${SERVER} ] NOT AVAILABLE --"
    fi
  done
  fi
else
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
}
#
# ------------------------------------------------------------------------
# Creating Directories to Grid and Database Installation
#
SetUpLinuxFolders() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX FOLDERS --"
  echo " -- SELECT THE ORACLE DATABASE VERSION --"
  SetTitle
PS3="Select the Option: "
select VERSION in "19c" "21c" "23ai"; do
if [[ "${VERSION}" == "19c" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE DATABASE VERSION SELECTED: ${VERSION} --"
  SetTitle
  ORA_VER_INST="19.3.0.1"
elif [[ "${VERSION}" == "21c" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE DATABASE VERSION SELECTED: ${VERSION} --"
  SetTitle
  ORA_VER_INST="21.3.0.1"
elif [[ "${VERSION}" == "23ai" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE DATABASE VERSION SELECTED: ${VERSION} --"
  SetTitle
  ORA_VER_INST="23.4.0.1"
else
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
#
  SetClear
  SepLine
  SetTitle
  echo " -- SELECT THE ORACLE DATABASE RELEASE --"
  SetTitle
PS3="Select the Option: "
select RELEASE in "Enterprise Edition" "Standard Edition 2"; do
if [[ "${RELEASE}" == "Enterprise Edition" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE DATABASE EDITION SELECTED: ${RELEASE} --"
  SetTitle
  ORA_EDITION="db_EE_01"
elif [[ "${RELEASE}" == "Standard Edition 2" ]]; then
  SetClear
  SetTitle
  echo " -- ORACLE DATABASE EDITION SELECTED: ${RELEASE} --"
  SetTitle
  ORA_EDITION="db_SE2_01"
else
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
#
mkdir -p /var/tmp/.oracle
mkdir -p /u01/app/oraInventory
chmod -R 775 /u01/app/oraInventory
chmod -R g+w /u01/app/oraInventory
#
mkdir -p /u01/app/grid
mkdir -p /u01/app/grid/diag
#
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/diag
#
chown -R grid.oinstall /u01
chown -R grid.oinstall /u01/app/grid
chown -R grid.oinstall /u01/app/grid/diag
#
chown -R oracle.oinstall /u01/app/oracle
chown -R oracle.oinstall /u01/app/oracle/diag
#
chmod -R 775 /u01/
#
mkdir -p /u01/app/grid
mkdir -p /u01/app/${ORA_VER_INST}/grid
mkdir -p /u01/app/oraInventory/
#
mkdir -p /opt/oracle/wallet
mkdir -p /opt/oracle/wallet/logs
mkdir -p /opt/oracle/wallet/keystore
mkdir -p /opt/oracle/wallet/downloads
chmod -R 775 /opt/oracle/wallet
chown -R oracle.oinstall /opt/oracle/wallet
#
mkdir -p /opt/oracle/network/admin
#
chown grid.oinstall -R /u01/app/grid
chown grid.oinstall -R /u01/app/${ORA_VER_INST}
#
chmod -R g+w /u01/app/oraInventory
#
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle/product/${ORA_VER_INST}/${ORA_EDITION}
#
chown oracle.oinstall -R /u01/app/oracle
chown oracle.oinstall -R /u01/app/oracle/product/${ORA_VER_INST}
#
chown oracle.oinstall -R /opt/oracle/wallet
chown oracle.oinstall -R /opt/oracle/network
#
}
#
# ------------------------------------------------------------------------
# Creating Directories to Weblogic
SetUpLinuxFoldersWeblogic() {
mkdir -p /u01/app/oracle/product/24.1.0.1/emcc24ai
mkdir -p /u01/app/oracle/product/24.1.0.1/agent
# /u01/app/oracle/product/24.1.0.1/emcc24ai/oms_home/sysman/install/ConfigureGC.sh - to configure the emcc24ai
}
#
# ------------------------------------------------------------------------
# Creating Directories to Enterprise Manager Cloud Control and Agent
SetUpLinuxFoldersWeblogic() {
mkdir -p /u01/app/oracle/product/14.1.1.0/weblogic
mkdir -p /u01/app/oracle/product/14.1.1.0/Base_Domain/
}
#
# ------------------------------------------------------------------------
# Enabling Sudoers for Grid and Oracle Users
#
SetUpLinuxSudoers() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX SUDOERS --"
  SetTitle
  sed -i "s/^.*requiretty/#Defaults requiretty/"  /etc/sudoers
  echo "grid ALL=(ALL) NOPASSWD: ALL"           > /etc/sudoers.d/grid
  echo "oracle ALL=(ALL) NOPASSWD: ALL"         > /etc/sudoers.d/oracle
}
#
# ------------------------------------------------------------------------
# Mount tmpfs automatically on Linux
#
SetUpLinuxTMPFS() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX TMPFS --"
  SetTitle
if [[ $(cat /etc/fstab | egrep -i "tmpfs" | wc -l) == 0 ]]; then
  FULL_MEM=$(free -g | egrep -i "Mem:" | awk '{ print $2}')
  #
  echo "tmpfs                                     /dev/shm                tmpfs   size=${FULL_MEM}g        0 0" >> /etc/fstab
  #
  cat /etc/fstab
  #
  mount -a
  #
  df -Th
else
  SetTitle
  echo " -- LINUX TMPFS ALREADY CONFIGURED --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# SETUP DISK MANAGEMENT
#
SetUpLinuxDiskManagement() {
  SetClear
  SepLine
  SetTitle
  echo " -- SELECT THE DISK MANAGEMENT --"
  SetTitle
PS3="Select the Option: "
select DM in "File System" "RAW Devices" "ASMLib" "ASMFD"; do
if [[ "${DM}" == "File System" ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- Nothing to DO"
  SetTitle
elif [[ "${DM}" == "RAW Devices" ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- Check this file: /etc/udev/rules.d/99-oracle-asm-raw-devices.rules"
  echo " -- Check this file: /etc/udev/rules.d/99-iscsi-asm-raw-devices.rules"
  echo " -- Modify as your installation needs"
  SetTitle
  echo 'KERNEL=="sd?",NAME="DISK01",OWNER="grid",GROUP="asmadmin",MODE="0660"' > /etc/udev/rules.d/99-oracle-asm-raw-devices.rules
  echo 'KERNEL=="sda", SUBSYSTEM=="block", ENV{ID_SERIAL}=="0x6589cfc0000004ef2daffd3fb42387fe", SYMLINK+="sda", OWNER="grid", GROUP="asmadmin", MODE="0660"' >  /etc/udev/rules.d/99-iscsi-asm-raw-devices.rules
elif [[ "${DM}" == "ASMLib" ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- You must to see this result: Dependint on your OS Version"
  echo "oracleasm-support-???"
  echo "oracleasmlib-???"
  echo "kmod-oracleasm-???"
  SetTitle
  echo " -- If you do not see that, you must to install this 3 packages"
  SetTitle
  rpm -qa | grep oracleasm
elif [[ "${DM}" == "ASMFD" ]]; then
cat > /etc/oracleafd.conf <<EOF
afd_diskstring='/dev/sd*'
afd_filtering=enable
EOF
cp -r /etc/oracleafd.conf /etc/afd.conf
#
chmod 664 /etc/afd.conf
chmod 664 /etc/oracleafd.conf
chown grid.oinstall /etc/afd.conf
chown grid.oinstall /etc/oracleafd.conf
#
cat >> /etc/rc.d/rc.local <<EOF
/u01/app/${GRID_VER_INST}/grid/bin/afdroot install
/u01/app/${GRID_VER_INST}/grid/bin/acfsload start -s
/u01/app/${GRID_VER_INST}/grid/bin/asmcmd -p afd_refresh
/u01/app/${GRID_VER_INST}/grid/bin/asmcmd -p afd_scan
/u01/app/${GRID_VER_INST}/grid/bin/asmcmd -p afd_lslbl
/u01/app/${GRID_VER_INST}/grid/bin/asmcmd -p afd_lsdsk
/u01/app/${GRID_VER_INST}/grid/bin/asmcmd -p afd_state
EOF
#
chmod +x /etc/rc.d/rc.local
#
  SetClear
  SepLine
  SetTitle
  echo " -- Check this file: /etc/oracleafd.conf"
  echo " -- Modify as your installation needs --"
  echo " -- Can be: [ /dev/sd* ], [ /dev/nvm* ], [ /dev/mapper/* ], [ /dev/something ] --"
  SetTitle
else
  SetClear
  SepLine
  SetTitle
  echo " -- Invalid Option --"
  SetTitle
  continue
fi
break
done
}
#
# ------------------------------------------------------------------------
# Install and Enable the CHRONY (Substitute of NTP SYSTEM) 
#
SetUpLinuxChrony() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX CHRONY --"
  SetTitle
  dnf -y install chrony
  systemctl enable chronyd.service
  systemctl status chronyd.service
  systemctl start chronyd.service
  systemctl restart chronyd.service
  systemctl status chronyd.service
}
#
# ------------------------------------------------------------------------
# INSTALL Linux Epel
#
SetUpLinuxEpel() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX EPEL --"
  SetTitle
if [[ ${OS_VERSION} == "8".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
elif [[ ${OS_VERSION} == "9".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
elif [[ ${OS_VERSION} == "10".* ]]; then 
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
fi
}
#
# ------------------------------------------------------------------------
# INSTALL Linux RLWRAP
#
SetUpLinuxLRLWRAP() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX RLWRAP --"
  SetTitle
  dnf -y install rlwrap
}
#
# ------------------------------------------------------------------------
# INSTALL JAVA OPEN JDK
#
SetUpLinuxJava() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX JAVA --"
  SetTitle
  ### dnf -y install java-1.8.0-openjdk-devel java-1.8.0-openjdk jdk1.8 java-latest-openjdk java-latest-openjdk-devel oracle-java-jdk-release-el8
  dnf -y install java-latest-openjdk java-latest-openjdk-devel oracle-java-jdk-release
}
#
# ------------------------------------------------------------------------
# Setup Purge Logs
#
SetUpLinuxPurgeLogs() {
  SetClear
  SepLine
  SetTitle
  echo " -- Setup Purge Logs --"
  SetTitle
if [[ ${OS_VERSION} == "8".* ]]; then 
  rpm -Uvh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el8.x86_64.rpm
  wget -O /usr/local/sbin/purgeLogs    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs
  wget -O /etc/cron.daily/purgeLogs.sh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs.sh
  chmod a+x /usr/local/sbin/purgeLogs
  chmod a+x /etc/cron.daily/purgeLogs.sh
elif [[ ${OS_VERSION} == "9".* ]]; then 
  rpm -Uvh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el9.x86_64.rpm
  wget -O /usr/local/sbin/purgeLogs    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs
  wget -O /etc/cron.daily/purgeLogs.sh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs.sh
  chmod a+x /usr/local/sbin/purgeLogs
  chmod a+x /etc/cron.daily/purgeLogs.sh
elif [[ ${OS_VERSION} == "10".* ]]; then 
  rpm -Uvh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el10.x86_64.rpm
  wget -O /usr/local/sbin/purgeLogs    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs
  wget -O /etc/cron.daily/purgeLogs.sh https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs.sh
  chmod a+x /usr/local/sbin/purgeLogs
  chmod a+x /etc/cron.daily/purgeLogs.sh
fi
#
  SetClear
  SepLine
  SetTitle
  echo " -- Setup Purge Logs on Crontab --"
  SetTitle
  echo "# ROOT Crontab"
  echo "# Purge Logs GI"
  echo "# 00 20 * * * /opt/purgelogs/purgelogs.bin cleanup --orcl 30 --aud --lsnr --automigrate"
  echo "# Purge Logs DB"
  echo "# 00 21 * * * /opt/purgelogs/purgelogs.bin cleanup --days 30 --aud --lsnr --automigrate"
  SetTitle
}
#
# ------------------------------------------------------------------------
# UPDATE THE LINUX
#
UpdateLinux() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX UPGRADE --"
  SetTitle
  dnf -y upgrade && dnf -y upgrade
}
#
# ------------------------------------------------------------------------
# Install and Enable the CHRONY (Substitute of NTP SYSTEM)
#
CheckLinuxPackages() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP CHECK LINUX PACKAGES --"
  SetTitle
if [[ ${OS_VERSION} == "8".* ]]; then 
  rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_8} | egrep "is not installed"
elif [[ ${OS_VERSION} == "9".* ]]; then 
  rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_9} | egrep "is not installed"
elif [[ ${OS_VERSION} == "10".* ]]; then 
  rpm -q --qf '%{NAME}-%{VERSION}-%{RELEASE} (%{ARCH})\n' ${PACKAGES_10} | egrep "is not installed"
fi
}
#
# ------------------------------------------------------------------------
# Install Linux Packages
#
InstallLinuxPackages() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP INSTALL LINUX PACKAGES --"
  SetTitle
if [[ ${OS_VERSION} == "8".* ]]; then 
  # dnf -y install ${PACKAGES_8}
  for PACKAGE in ${PACKAGES_8}; do dnf -y install ${PACKAGE}; done
elif [[ ${OS_VERSION} == "9".* ]]; then 
  # dnf -y install ${PACKAGES_9}
  for PACKAGE in ${PACKAGES_9}; do dnf -y install ${PACKAGE}; done
elif [[ ${OS_VERSION} == "10".* ]]; then 
  # dnf -y install ${PACKAGES_10}
  for PACKAGE in ${PACKAGES_10}; do dnf -y install ${PACKAGE}; done
fi
}
#
# ------------------------------------------------------------------------
# Disable Transparent HugePages
#
SetUpLinuxDisableTransparentHugePages() {
  echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
  echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
#
  ### if grep -q "transparent_hugepage" /etc/default/grub; then
  ###   echo "Transparent HugePages already disabled in GRUB"
  ### else
  ###  echo "Adding Transparent HugePages to GRUB config..."
  ###  sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="transparent_hugepage=never /' /etc/default/grub
  ### grub2-mkconfig -o /boot/grub2/grub.cfg
  ### fi
#
}
# ------------------------------------------------------------------------
# Kernel Parameters Setup
#
SetUpLinuxKernel() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP LINUX KERNEL --"
  SetTitle
echo -e "\
+----------------+-----------------------+
| Option         | Value                 |
+----------------+-----------------------+
TOTAL_MEMORY    = ${MEM} MB | ${MEM_G} GB
PCT_MEMORY      = ${PCT} %
SGA_TARGET      = ${SGA} MB | ${SGA_G} GB
PGA_TARGET      = ${PGA} MB | ${PGA_G} GB
PROCESSES       = ${PROC}
kernel.sem      = 250 ${PROC} 128 2048
+----------------------------------------+
kernel.shmmax   = ${MAX}
kernel.shmmni   = ${MNI}
kernel.shmall   = ${ALL}
vm.nr_hugepages = ${HPG} ===> IT MUST BE BIGGER THEN THE SGA"
#
echo "session    required     pam_limits.so" >> /etc/pam.d/login
#
if [[ $(cat /etc/sysctl.conf | egrep -i "# ORACLE" | wc -l) == 0 ]]; then
cat >> /etc/sysctl.conf <<EOF
#
# ORACLE PARAMETERS FOR SINGLE/RAC/MAA/RESTART/ODG/OGG
#
fs.file-max = 6815744
fs.aio-max-nr = 1048576
vm.swappiness = 10
vm.dirty_background_ratio = 3
vm.dirty_ratio = 85
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
# vm.min_free_kbytes = 5248000
# vm.hugetlb_shm_group = 54322
# vm.nr_hugepages = ${HPG}
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 4194304
net.ipv4.tcp_rmem = 4096 262144 4194304
net.ipv4.tcp_wmem = 4096 262144 4194304
net.ipv4.ip_local_port_range = 9000 65500
# net.ipv4.ip_local_port_range = 11000 65500
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
net.ipv4.tcp_keepalive_time = 30
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
# kernel.io_uring_disabled = 0
kernel.panic_on_oops = 1
kernel.sem = 250 60000 128 2048
kernel.shmmax = ${MAX}
kernel.shmmni = 4096
kernel.shmall = ${ALL}
EOF
else
  SepLine
  SetTitle 
  echo " -- LINUX KERNEL PARAMETERS ALREADY CONFIGURED --"
  SetTitle 
fi
#
/sbin/sysctl -p
#
sysctl -p
#
egrep HugePages_ /proc/meminfo
#
}
#
# ------------------------------------------------------------------------
# Oracle Parameters Recomendation
#
OracleParameter() {
  SetClear
  SepLine
  SetTitle
  echo " -- SETING UP ORACLE KERNEL PARAMETERS --"
  SetTitle
echo -e "\
ALTER SYSTEM SET processes = ${PRC} SID = '*' SCOPE = SPFILE;
ALTER SYSTEM SET memory_max_target = 0 SID = '*' SCOPE = SPFILE;
ALTER SYSTEM SET memory_target = 0 SID = '*' SCOPE = SPFILE;
ALTER SYSTEM SET sga_target = ${SGA}M SID = '*' SCOPE = SPFILE;
ALTER SYSTEM SET pga_aggregate_target = ${PGA}M SID = '*' SCOPE = SPFILE;
ALTER SYSTEM SET use_large_pages = ONLY SID = '*' SCOPE = SPFILE;   --->   To Enable Hugepges on the database (NOT MANDATORY)"
  SetTitle
#
/sbin/sysctl -p
#
sysctl -p
}
#
# ------------------------------------------------------------------------
# Add the Content on Grid Profile
#
SetUpLinuxGrid() {
  SetClear
  SepLine
  SetTitle
  echo " -- Seting UP GRID User --"
  SetTitle
if [[ $(cat /etc/passwd | egrep grid | wc -l) != 0 ]]; then
cat > ${DBNITRO}/environments/grid_profile <<EOF
# User specific environment and startup programs
# export _JAVA_OPTIONS='-Dsun.java2d.xrender=false'
export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/grid/.local/bin:/home/grid/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]$ '
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
alias list='${DBNITRO}/bin/OracleList.sh'
alias oratcp='java -jar ${DBNITRO}/bin/oratcptest.jar'
umask 0022
EOF
#
if [[ $(cat /home/grid/.bash_profile | egrep "grid_profile" | wc -l) == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- Configuring GRID Profile --"
  SetTitle
  echo ". ${DBNITRO}/environments/grid_profile" >> /home/grid/.bash_profile
else
  SetTitle
  echo " -- GRID Profile is Already Configured --"
  SetTitle
fi
#
else
  SetTitle
  echo " -- Your Environment does not have Grid User --"
  SetTitle
  break
fi
}
#
# ------------------------------------------------------------------------
# Add the Content on Oracle Profile
#
SetUpLinuxOracle() {
  SetClear
  SepLine
  SetTitle
  echo " -- Seting UP ORACLE User --"
  SetTitle
if [[ $(cat /etc/passwd | egrep oracle | wc -l) != 0 ]]; then
cat > ${DBNITRO}/environments/oracle_profile <<EOF
# User specific environment and startup programs
# export _JAVA_OPTIONS='-Dsun.java2d.xrender=false'
export PATH=/usr/local/bin:/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin
export PS1=\$'[ \${LOGNAME}@\h:\$(pwd): ]$ '
alias db='. ${DBNITRO}/bin/OracleMenu.sh'
alias list='${DBNITRO}/bin/OracleList.sh'
alias oratcp='java -jar ${DBNITRO}/bin/oratcptest.jar'
umask 0022
EOF
#
if [[ $(cat /home/oracle/.bash_profile | egrep "oracle_profile" | wc -l) == 0 ]]; then
  SetClear
  SepLine
  SetTitle
  echo " -- Configuring ORACLE Profile --"
  SetTitle
  echo ". ${DBNITRO}/environments/oracle_profile" >> /home/oracle/.bash_profile
else
  SetTitle
  echo " -- ORACLE Profile is Already Configured --"
  SetTitle
fi
#
else
  SetTitle
  echo " -- Your Environment does not have Oracle User --"
  SetTitle
  break
fi
}
#
# ------------------------------------------------------------------------
# Setup DBNitro OLD
#
SetUpDBNitroOLD() {
  SetClear
  SepLine
  SetTitle
  echo " -- Downloading DBNITRO Files --"
  SetTitle
  wget -O ${FOLDER}/DBNitro.zip https://github.com/dbaribas/dbnitro.net/archive/refs/heads/main.zip
  cd ${FOLDER}/
  unzip DBNitro.zip
  mv ${FOLDER}/dbnitro.net-main ${FOLDER}/dbnitro
  rm -f ${FOLDER}/DBNitro.zip
  #
  chmod a+x ${DBNITRO}/bin/*.sh
  chmod a+x ${DBNITRO}/bin/oraenv++
  chmod a+x ${DBNITRO}/backup/*.sh
  #
  chmod -R 775 ${DBNITRO}/
  chown -R oracle.oinstall ${DBNITRO}/
}
#
# ------------------------------------------------------------------------
# Setup DBNitro 
#
SetUpDBNitro() {
  SetClear
  SepLine
  SetTitle
  echo " -- Downloading DBNITRO Files --"
  SetTitle
#
# Backup
wget -O ${DBNITRO}/backup/backup.sh                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/backup/backup.sh
# BIN
wget -O ${DBNITRO}/bin/passwordless.sh                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/passwordless.sh
wget -O ${DBNITRO}/bin/asmdu.sh                                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/asmdu.sh
wget -O ${DBNITRO}/bin/cell-status.sh                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/cell-status.sh
wget -O ${DBNITRO}/bin/crs.sh                                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/crs.sh
wget -O ${DBNITRO}/bin/dg-status.sh                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/dg-status.sh
wget -O ${DBNITRO}/bin/DGDiagnostic.sh                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/DGDiagnostic.sh
wget -O ${DBNITRO}/bin/exa-howsmart.sh                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/exa-howsmart.sh
wget -O ${DBNITRO}/bin/exa-iblinkinfo.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/exa-iblinkinfo.sh
wget -O ${DBNITRO}/bin/exa-racklayout.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/exa-racklayout.sh
wget -O ${DBNITRO}/bin/exa-versions.sh                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/exa-versions.sh
wget -O ${DBNITRO}/bin/gg-afterstop.sh                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/gg-afterstop.sh
wget -O ${DBNITRO}/bin/gg-info.sh                                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/gg-info.sh
wget -O ${DBNITRO}/bin/gg-start.sh                                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/gg-start.sh
wget -O ${DBNITRO}/bin/gg-status.sh                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/gg-status.sh
wget -O ${DBNITRO}/bin/gg-stop.sh                                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/gg-stop.sh
wget -O ${DBNITRO}/bin/list-ohpatches.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/list-ohpatches.sh
wget -O ${DBNITRO}/bin/lspatches.sh                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/lspatches.sh
wget -O ${DBNITRO}/bin/many-exa-racklayout.sh                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/many-exa-racklayout.sh
wget -O ${DBNITRO}/bin/nfs-status.sh                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/nfs-status.sh
wget -O ${DBNITRO}/bin/oci-check-backups.sh                               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/oci-check-backups.sh
wget -O ${DBNITRO}/bin/Oracle_Check_Instance.pl                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_Check_Instance.pl
wget -O ${DBNITRO}/bin/Oracle_Data_Guard_Monitor.sh                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_Data_Guard_Monitor.sh
wget -O ${DBNITRO}/bin/Oracle_DBA_Check_Hugepages.sh                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_DBA_Check_Hugepages.sh
wget -O ${DBNITRO}/bin/Oracle_DBA_Daily_Check.sh                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_DBA_Daily_Check.sh
wget -O ${DBNITRO}/bin/Oracle_Golden_Gate_Monitor.sh                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/Oracle_Golden_Gate_Monitor.sh
wget -O ${DBNITRO}/bin/OracleGetProducts.sh                               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/OracleGetProducts.sh
wget -O ${DBNITRO}/bin/OracleList.sh                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/OracleList.sh
wget -O ${DBNITRO}/bin/OracleMenu.sh                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/OracleMenu.sh
wget -O ${DBNITRO}/bin/oradblogs                                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/oradblogs
wget -O ${DBNITRO}/bin/oratcptest.jar                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/oratcptest.jar
wget -O ${DBNITRO}/bin/oraenv++                                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/oraenv++
wget -O ${DBNITRO}/bin/purgeLogs                                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs
wget -O ${DBNITRO}/bin/purgeLogs.sh                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeLogs.sh
wget -O ${DBNITRO}/bin/purgeTFA.sh                                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/purgeTFA.sh
wget -O ${DBNITRO}/bin/rac-mon.sh                                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rac-mon.sh
wget -O ${DBNITRO}/bin/rac-on_all_db.sh                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rac-on_all_db.sh
wget -O ${DBNITRO}/bin/rac-status_5_6.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rac-status_5_6.sh
wget -O ${DBNITRO}/bin/rac-status_new.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rac-status_new.sh
wget -O ${DBNITRO}/bin/rac-status.sh                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rac-status.sh
wget -O ${DBNITRO}/bin/rcctl.install.pl                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rcctl.install.pl
wget -O ${DBNITRO}/bin/ribas_20200211.sh                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/ribas_20200211.sh
wget -O ${DBNITRO}/bin/ribas.sh                                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/ribas.sh
wget -O ${DBNITRO}/bin/rman-backup.sh                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/rman-backup.sh
wget -O ${DBNITRO}/bin/srdc_DGlogicalStby_diag.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/srdc_DGlogicalStby_diag.sql
wget -O ${DBNITRO}/bin/srdc_DGPhyStby_diag.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/srdc_DGPhyStby_diag.sql
wget -O ${DBNITRO}/bin/srdc_DGPrimary_diag.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/srdc_DGPrimary_diag.sql
wget -O ${DBNITRO}/bin/svc-set-failback-yes.sh                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/svc-set-failback-yes.sh
wget -O ${DBNITRO}/bin/svc-show-config.sh                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/svc-show-config.sh
wget -O ${DBNITRO}/bin/test_services.sh                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/test_services.sh
wget -O ${DBNITRO}/bin/tuning.pl                                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/tuning.pl
wget -O ${DBNITRO}/bin/yal.sh                                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/bin/yal.sh
# Functions 
wget -O ${DBNITRO}/functions/Oracle_ASM_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ASM_Functions
wget -O ${DBNITRO}/functions/Oracle_DBA_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_DBA_Functions
wget -O ${DBNITRO}/functions/Oracle_EXA_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_EXA_Functions
wget -O ${DBNITRO}/functions/Oracle_OGG_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_OGG_Functions
wget -O ${DBNITRO}/functions/Oracle_ODG_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ODG_Functions
wget -O ${DBNITRO}/functions/Oracle_ODA_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ODA_Functions
wget -O ${DBNITRO}/functions/Oracle_PDB_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_PDB_Functions
wget -O ${DBNITRO}/functions/Oracle_RMAN_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_RMAN_Functions
wget -O ${DBNITRO}/functions/Oracle_RAC_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_RAC_Functions
wget -O ${DBNITRO}/functions/Oracle_STR_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_STR_Functions
wget -O ${DBNITRO}/functions/Oracle_UNIX_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_UNIX_Functions
wget -O ${DBNITRO}/functions/Oracle_WALL_Functions                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_WALL_Function
wget -O ${DBNITRO}/functions/Oracle_ZDL_Functions                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/functions/Oracle_ZDL_Functions
# SQL 
wget -O ${DBNITRO}/sql/glogin_pdb.sql                                               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/glogin_pdb.sql
wget -O ${DBNITRO}/sql/glogin.sql                                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/glogin.sql
#
wget -O ${DBNITRO}/sql/DBA_CREATE_DASHBOARD.sql                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_CREATE_DASHBOARD.sql
wget -O ${DBNITRO}/sql/DBA_CHECK_HUGEPAGES.sql                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_CHECK_HUGEPAGES.sql
wget -O ${DBNITRO}/sql/DBA_CHECK_MEMORY_USAGE_BY_SID.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_CHECK_MEMORY_USAGE_BY_SID.sql
wget -O ${DBNITRO}/sql/DBA_DATAGUARD_GAPS.sql                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_DATAGUARD_GAPS.sql
wget -O ${DBNITRO}/sql/DBA_DATAGUARD_STATUS.sql                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_DATAGUARD_STATUS.sql
wget -O ${DBNITRO}/sql/DBA_CHECK_DATA_DICTIONARY.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_CHECK_DATA_DICTIONARY.sql
wget -O ${DBNITRO}/sql/DBA_INFO.sql                                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_INFO.sql
wget -O ${DBNITRO}/sql/DBA_OPTIONS_PACKS_USAGE_STATISTICS.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_OPTIONS_PACKS_USAGE_STATISTICS.sql
wget -O ${DBNITRO}/sql/DBA_COMPONENTS.sql                                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_COMPONENTS.sql
wget -O ${DBNITRO}/sql/DBA_REPORT_V.3.0.1.sql                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_REPORT_V.3.0.1.sql
wget -O ${DBNITRO}/sql/DBA_SNAPPER.sql                                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_SNAPPER.sql
wget -O ${DBNITRO}/sql/DBA_ID.sql                                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_ID.sql
wget -O ${DBNITRO}/sql/DBA_PID_SID.sql                                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_PID_SID.sql
wget -O ${DBNITRO}/sql/DBA_SID_PID.sql                                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_SID_PID.sql
wget -O ${DBNITRO}/sql/DBA_LOCKS.sql                                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_LOCKS.sql
wget -O ${DBNITRO}/sql/DBA_SHOW_LIST_PDBS.sql                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_SHOW_LIST_PDBS.sql
#
wget -O ${DBNITRO}/sql/DBA_EXECUTE_STATISTICS_COLLECTION.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_EXECUTE_STATISTICS_COLLECTION.sql
wget -O ${DBNITRO}/sql/DBA_SETUP_STATISTICS_COLLECTION.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_SETUP_STATISTICS_COLLECTION.sql
wget -O ${DBNITRO}/sql/DBA_VERIFY_STATISTICS_COLLECTION.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_VERIFY_STATISTICS_COLLECTION.sql
#
wget -O ${DBNITRO}/sql/ASM_001_VERIFY_INSTANCE_PARAMETERS.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_001_VERIFY_INSTANCE_PARAMETERS.sql
wget -O ${DBNITRO}/sql/ASM_002_VERIFY_OPERATION.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_002_VERIFY_OPERATION.sql
wget -O ${DBNITRO}/sql/ASM_003_VERIFY_DISKS_AND_GROUPS.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_003_VERIFY_DISKS_AND_GROUPS.sql
wget -O ${DBNITRO}/sql/ASM_004_VERIFY_DISK_STATE_AND_COMPATIBILITY.sql              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_004_VERIFY_DISK_STATE_AND_COMPATIBILITY.sql
wget -O ${DBNITRO}/sql/ASM_005_VERIFY_GENERAL_INFO.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_005_VERIFY_GENERAL_INFO.sql
wget -O ${DBNITRO}/sql/ASM_006_VERIFY_LIBRARY.sql                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_006_VERIFY_LIBRARY.sql
wget -O ${DBNITRO}/sql/ASM_007_VERIFY_DISK_GROUP_SUMMARY.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_007_VERIFY_DISK_GROUP_SUMMARY.sql
wget -O ${DBNITRO}/sql/ASM_008_VERIFY_DISK_GROUP_USAGE.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_008_VERIFY_DISK_GROUP_USAGE.sql
wget -O ${DBNITRO}/sql/ASM_009_REMOVE_ALL_ARCHIVELOGS_FROM_ASM.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_009_REMOVE_ALL_ARCHIVELOGS_FROM_ASM.sql
wget -O ${DBNITRO}/sql/ASM_010_VERIFY_DISK_GROUP_SIZE_AND_USAGE.sql                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_010_VERIFY_DISK_GROUP_SIZE_AND_USAGE.sql
wget -O ${DBNITRO}/sql/ASM_011_VERIFY_DISK_GROUP_SIZE_AND_USAGE_DETAILS.sql         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_011_VERIFY_DISK_GROUP_SIZE_AND_USAGE_DETAILS.sql
wget -O ${DBNITRO}/sql/ASM_012_VERIFY_ALL_DISKGROUPS_CONTENTS.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_012_VERIFY_ALL_DISKGROUPS_CONTENTS.sql
wget -O ${DBNITRO}/sql/ASM_013_VERIFY_OPERATION_DETAILS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_013_VERIFY_OPERATION_DETAILS.sql
wget -O ${DBNITRO}/sql/ASM_014_VERIFY_DISKS_SIZE_AND_STATUS.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_014_VERIFY_DISKS_SIZE_AND_STATUS.sql
wget -O ${DBNITRO}/sql/ASM_015_FILES_THAT_ARE_NOT_IN_USE_CURRENTLY_ON_ASM_DISKS.sql https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_015_FILES_THAT_ARE_NOT_IN_USE_CURRENTLY_ON_ASM_DISKS.sql
wget -O ${DBNITRO}/sql/ASM_016_VERIFY_DISKS_TYPE_AND_STATUS.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_016_VERIFY_DISKS_TYPE_AND_STATUS.sql
wget -O ${DBNITRO}/sql/ASM_017_VERIFY_DISKS_READ_AND_WRITE_VALUES.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_017_VERIFY_DISKS_READ_AND_WRITE_VALUES.sql
wget -O ${DBNITRO}/sql/ASM_018_VERIFY_FILES_IN_ASM_NOT_KNOWN_TO_DATABASE.sql        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_018_VERIFY_FILES_IN_ASM_NOT_KNOWN_TO_DATABASE.sql
wget -O ${DBNITRO}/sql/ASM_019_VERIFY_DISK_GROUP_\%_USAGE.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_019_VERIFY_DISK_GROUP_\%_USAGE.sql
wget -O ${DBNITRO}/sql/ASM_020_VERIFY_DISK_GROUP_FREE_SPACE.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_020_VERIFY_DISK_GROUP_FREE_SPACE.sql
wget -O ${DBNITRO}/sql/ASM_021_VERIFY_CANDIDATE_DISKS.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_021_VERIFY_CANDIDATE_DISKS.sql
wget -O ${DBNITRO}/sql/ASM_022_VERIFY_PATH_AND_ALOCATED_SIZE.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_022_VERIFY_PATH_AND_ALOCATED_SIZE.sql
wget -O ${DBNITRO}/sql/ASM_023_EACH_FOLDER_UTILIZATION_IN_MB_BY_DISKGROUP.sql       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_023_EACH_FOLDER_UTILIZATION_IN_MB_BY_DISKGROUP.sql
wget -O ${DBNITRO}/sql/ASM_024_BLOCKERS_IN_ASM.sql                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ASM_024_BLOCKERS_IN_ASM.sql
#
wget -O ${DBNITRO}/sql/DBA_001_VERIFY_DATABASE_VERSION.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_001_VERIFY_DATABASE_VERSION.sql
wget -O ${DBNITRO}/sql/DBA_002_VERIFY_INSTALLED_PATCHES_DETAILS.sql                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_002_VERIFY_INSTALLED_PATCHES_DETAILS.sql
wget -O ${DBNITRO}/sql/DBA_003_INSTANCE_INFORMATION_PGA_SGA.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_003_INSTANCE_INFORMATION_PGA_SGA.sql
wget -O ${DBNITRO}/sql/DBA_004_GENERAL_TUNING_VIEW.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_004_GENERAL_TUNING_VIEW.sql
wget -O ${DBNITRO}/sql/DBA_005_DATABASE_GROWN_ON_LASTS_MONTHS.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_005_DATABASE_GROWN_ON_LASTS_MONTHS.sql
wget -O ${DBNITRO}/sql/DBA_006_CONNECTIONS_AVERAGE_PER_HOUR.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_006_CONNECTIONS_AVERAGE_PER_HOUR.sql
wget -O ${DBNITRO}/sql/DBA_007_TOP_20_DB_CPU_ACTIVITY.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_007_TOP_20_DB_CPU_ACTIVITY.sql
wget -O ${DBNITRO}/sql/DBA_008_VERIFY_SESSIONS_PER_MEMORY.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_008_VERIFY_SESSIONS_PER_MEMORY.sql
wget -O ${DBNITRO}/sql/DBA_009_DATABASE_SIZE.sql                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_009_DATABASE_SIZE.sql
wget -O ${DBNITRO}/sql/DBA_010_VERIFY_SESSIONS_PER_IO.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_010_VERIFY_SESSIONS_PER_IO.sql
wget -O ${DBNITRO}/sql/DBA_011_HIT_RATIO_THE_LASTS_30_DAYS.sql                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_011_HIT_RATIO_THE_LASTS_30_DAYS.sql
wget -O ${DBNITRO}/sql/DBA_012_ACTIVE_SESSIONS_AND_SQL_STATEMENTS.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_012_ACTIVE_SESSIONS_AND_SQL_STATEMENTS.sql
wget -O ${DBNITRO}/sql/DBA_013_INVALIDS_OBJECTS.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_013_INVALIDS_OBJECTS.sql
wget -O ${DBNITRO}/sql/DBA_014_JOBS_CONTROL_OF_THE_CLIENT.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_014_JOBS_CONTROL_OF_THE_CLIENT.sql
wget -O ${DBNITRO}/sql/DBA_015_MATERIALIZEDS_VIEWS_DISABLED.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_015_MATERIALIZEDS_VIEWS_DISABLED.sql
wget -O ${DBNITRO}/sql/DBA_016_VERIFY_RUNNING_JOBS.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_016_VERIFY_RUNNING_JOBS.sql
wget -O ${DBNITRO}/sql/DBA_017_KILL_A_RUNNING_SESSION.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_017_KILL_A_RUNNING_SESSION.sql
wget -O ${DBNITRO}/sql/DBA_018_VERIFY_PROFILE_INFORMATION.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_018_VERIFY_PROFILE_INFORMATION.sql
wget -O ${DBNITRO}/sql/DBA_019_BACKUP_STATISTICS.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_019_BACKUP_STATISTICS.sql
wget -O ${DBNITRO}/sql/DBA_020_QTD_OF_ARCHIVES_PER_HOUR.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_020_QTD_OF_ARCHIVES_PER_HOUR.sql
wget -O ${DBNITRO}/sql/DBA_021_LAST_FILE_OF_LAST_BACKUP_ARCH.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_021_LAST_FILE_OF_LAST_BACKUP_ARCH.sql
wget -O ${DBNITRO}/sql/DBA_022_LAST_FILE_OF_LAST_BACKUP_FULL.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_022_LAST_FILE_OF_LAST_BACKUP_FULL.sql
wget -O ${DBNITRO}/sql/DBA_023_ARCHIVES_GENERATED_PER_DAY.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_023_ARCHIVES_GENERATED_PER_DAY.sql
wget -O ${DBNITRO}/sql/DBA_024_BACKUP_LOG_OF_LAST_BACKUP_FULL.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_024_BACKUP_LOG_OF_LAST_BACKUP_FULL.sql
wget -O ${DBNITRO}/sql/DBA_025_BACKUP_LOG_OF_LASTS_ARCHIVES.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_025_BACKUP_LOG_OF_LASTS_ARCHIVES.sql
wget -O ${DBNITRO}/sql/DBA_026_ERRORS_ON_ALERT_LOG_FILE.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_026_ERRORS_ON_ALERT_LOG_FILE.sql
wget -O ${DBNITRO}/sql/DBA_027_ORACLE_ENTERPRISE_MANAGER_ALERT.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_027_ORACLE_ENTERPRISE_MANAGER_ALERT.sql
wget -O ${DBNITRO}/sql/DBA_028_CAPTURE_STATISTICS_OF_DATA_DICTIONARY.sql            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_028_CAPTURE_STATISTICS_OF_DATA_DICTIONARY.sql
wget -O ${DBNITRO}/sql/DBA_029_CAPTURE_STATISTICS_OF_ALL_DATABASE.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_029_CAPTURE_STATISTICS_OF_ALL_DATABASE.sql
wget -O ${DBNITRO}/sql/DBA_030_BLOCKING_LOCKS.sql                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_030_BLOCKING_LOCKS.sql
wget -O ${DBNITRO}/sql/DBA_031_LOCKED_OBJECTS.sql                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_031_LOCKED_OBJECTS.sql
wget -O ${DBNITRO}/sql/DBA_032_BLOCKING_LOCKS_SUMARY.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_032_BLOCKING_LOCKS_SUMARY.sql
wget -O ${DBNITRO}/sql/DBA_033_BLOCKING_LOCKS_USER_DETAILS.sql                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_033_BLOCKING_LOCKS_USER_DETAILS.sql
wget -O ${DBNITRO}/sql/DBA_034_BLOCKING_LOCKS_WAITING_SQL.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_034_BLOCKING_LOCKS_WAITING_SQL.sql
wget -O ${DBNITRO}/sql/DBA_035_LOCKED_OBJECTS_DETAILS.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_035_LOCKED_OBJECTS_DETAILS.sql
wget -O ${DBNITRO}/sql/DBA_036_DML_AND_DDL_LOCKS.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_036_DML_AND_DDL_LOCKS.sql
wget -O ${DBNITRO}/sql/DBA_037_DML_TABLE_LOCKS_TIME.sql                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_037_DML_TABLE_LOCKS_TIME.sql
wget -O ${DBNITRO}/sql/DBA_038_VERIFY_SESSIONS.sql                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_038_VERIFY_SESSIONS.sql
wget -O ${DBNITRO}/sql/DBA_039_TOP_20_DATABASE_SESSIONS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_039_TOP_20_DATABASE_SESSIONS.sql
wget -O ${DBNITRO}/sql/DBA_040_TABLESPACES.sql                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_040_TABLESPACES.sql
wget -O ${DBNITRO}/sql/DBA_041_VERIFY_STATISTICS_TABLES.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_041_VERIFY_STATISTICS_TABLES.sql
wget -O ${DBNITRO}/sql/DBA_042_VERIFY_STATISTICS_INDEXES.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_042_VERIFY_STATISTICS_INDEXES.sql
wget -O ${DBNITRO}/sql/DBA_043_CAPTURE_STATISTICS_OWNER.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_043_CAPTURE_STATISTICS_OWNER.sql
wget -O ${DBNITRO}/sql/DBA_044_VALIDATE_OBJECTS_FROM_ONE_OWNER.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_044_VALIDATE_OBJECTS_FROM_ONE_OWNER.sql
wget -O ${DBNITRO}/sql/DBA_045_VERIFY_TABLES_SIZE_VALIDATE_OBJ_OWNERS.sql           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_045_VERIFY_TABLES_SIZE_VALIDATE_OBJ_OWNERS.sql
wget -O ${DBNITRO}/sql/DBA_046_OWNER_X_OBJECTS_X_TYPE_X_QTD.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_046_OWNER_X_OBJECTS_X_TYPE_X_QTD.sql
wget -O ${DBNITRO}/sql/DBA_047_VERIFY_INSTANCE_CHARACTERSET.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_047_VERIFY_INSTANCE_CHARACTERSET.sql
wget -O ${DBNITRO}/sql/DBA_048_CACHE_HIT_RATIO_GOOD_90\%.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_048_CACHE_HIT_RATIO_GOOD_90\%.sql
wget -O ${DBNITRO}/sql/DBA_049_VERIFY_INSTANCE_INSTALLED_PRODUCTS.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_049_VERIFY_INSTANCE_INSTALLED_PRODUCTS.sql
wget -O ${DBNITRO}/sql/DBA_050_INSTANCE_PROPERTIES.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_050_INSTANCE_PROPERTIES.sql
wget -O ${DBNITRO}/sql/DBA_051_INSTANCE_OPTIONS.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_051_INSTANCE_OPTIONS.sql
wget -O ${DBNITRO}/sql/DBA_052_INSTANCE_DIFFERENTS_PARAMETERS.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_052_INSTANCE_DIFFERENTS_PARAMETERS.sql
wget -O ${DBNITRO}/sql/DBA_053_INSTANCE_MODIFICABLES_PARAMETERS.sql                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_053_INSTANCE_MODIFICABLES_PARAMETERS.sql
wget -O ${DBNITRO}/sql/DBA_054_WHICH_SESSION_IS_BLOCKING_OTHER_SESSION.sql          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_054_WHICH_SESSION_IS_BLOCKING_OTHER_SESSION.sql
wget -O ${DBNITRO}/sql/DBA_055_VERIFY_DEAD_LOCKS.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_055_VERIFY_DEAD_LOCKS.sql
wget -O ${DBNITRO}/sql/DBA_056_VERIFY_SESSIONS_PER_IO_CONSUME.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_056_VERIFY_SESSIONS_PER_IO_CONSUME.sql
wget -O ${DBNITRO}/sql/DBA_057_VERIFY_FREE_SEGMENTS_ON_DATAFILES.sql                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_057_VERIFY_FREE_SEGMENTS_ON_DATAFILES.sql
wget -O ${DBNITRO}/sql/DBA_058_VERIFY_WHICH_DATAFILE_CAN_BE_RESIZED.sql             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_058_VERIFY_WHICH_DATAFILE_CAN_BE_RESIZED.sql
wget -O ${DBNITRO}/sql/DBA_059_VERIFY_RECYCLEBIN.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_059_VERIFY_RECYCLEBIN.sql
wget -O ${DBNITRO}/sql/DBA_060_PURGE_RECYCLEBIN.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_060_PURGE_RECYCLEBIN.sql
wget -O ${DBNITRO}/sql/DBA_061_VERIFY_DATABASE_SESSIONS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_061_VERIFY_DATABASE_SESSIONS.sql
wget -O ${DBNITRO}/sql/DBA_062_VERIFY_ACTIVES_SESSIONS_PER_OWNER.sql                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_062_VERIFY_ACTIVES_SESSIONS_PER_OWNER.sql
wget -O ${DBNITRO}/sql/DBA_063_UNLOCKING_A_USER.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_063_UNLOCKING_A_USER.sql
wget -O ${DBNITRO}/sql/DBA_064_LOCKING_A_USER.sql                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_064_LOCKING_A_USER.sql
wget -O ${DBNITRO}/sql/DBA_065_REDO_GROUPS_INFORMATIONS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_065_REDO_GROUPS_INFORMATIONS.sql
wget -O ${DBNITRO}/sql/DBA_066_SHOW_ALL_CORRUPTED_OBJECTS.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_066_SHOW_ALL_CORRUPTED_OBJECTS.sql
wget -O ${DBNITRO}/sql/DBA_067_VERIFY_SPACE_OF_FLASH_RECOVERY_AREA.sql              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_067_VERIFY_SPACE_OF_FLASH_RECOVERY_AREA.sql
wget -O ${DBNITRO}/sql/DBA_068_TOTAL_USERS_COUNT_ON_DATABASE.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_068_TOTAL_USERS_COUNT_ON_DATABASE.sql
wget -O ${DBNITRO}/sql/DBA_069_VERIFY_CONSUME_PER_CPU.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_069_VERIFY_CONSUME_PER_CPU.sql
wget -O ${DBNITRO}/sql/DBA_070_QUICK_TUNE.sql                                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_070_QUICK_TUNE.sql
wget -O ${DBNITRO}/sql/DBA_071_VERIFY_RECOMENDATIONS_TUNING_TOP_20.sql              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_071_VERIFY_RECOMENDATIONS_TUNING_TOP_20.sql
wget -O ${DBNITRO}/sql/DBA_072_VERIFY_TOP_20_TUNING_HISTORY.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_072_VERIFY_TOP_20_TUNING_HISTORY.sql
wget -O ${DBNITRO}/sql/DBA_073_VERIFY_BACKGROUND_PROCESSESS.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_073_VERIFY_BACKGROUND_PROCESSESS.sql
wget -O ${DBNITRO}/sql/DBA_074_VERIFY_DYNAMICS_PARAMETERS_SPFILE.sql                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_074_VERIFY_DYNAMICS_PARAMETERS_SPFILE.sql
wget -O ${DBNITRO}/sql/DBA_075_VERIFY_DBA_FEATURES_USAGE_STATISTICS.sql             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_075_VERIFY_DBA_FEATURES_USAGE_STATISTICS.sql
wget -O ${DBNITRO}/sql/DBA_076_VERIFY_DBA_HIGH_WATER_MARK_STATISTICS.sql            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_076_VERIFY_DBA_HIGH_WATER_MARK_STATISTICS.sql
wget -O ${DBNITRO}/sql/DBA_077_REPORT_SQL_MONITOR.sql                               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_077_REPORT_SQL_MONITOR.sql
wget -O ${DBNITRO}/sql/DBA_078_WHICH_SEG_HAVE_TOP_LOGICAL_IO_PHYSICAL_IO.sql        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_078_WHICH_SEG_HAVE_TOP_LOGICAL_IO_PHYSICAL_IO.sql
wget -O ${DBNITRO}/sql/DBA_079_DATABASE_LINKS.sql                                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_079_DATABASE_LINKS.sql
wget -O ${DBNITRO}/sql/DBA_080_DATABASE_FOLDERS.sql                                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_080_DATABASE_FOLDERS.sql
wget -O ${DBNITRO}/sql/DBA_081_IDENTIFYING_WHEN_A_PASSWORD_WAS_LAST_CHANGED.sql     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_081_IDENTIFYING_WHEN_A_PASSWORD_WAS_LAST_CHANGED.sql
wget -O ${DBNITRO}/sql/DBA_082_VERIFY_UNDO_SEGMENTS.sql                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_082_VERIFY_UNDO_SEGMENTS.sql
wget -O ${DBNITRO}/sql/DBA_083_VERIFY_ALL_SQL_STATEMENTS.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_083_VERIFY_ALL_SQL_STATEMENTS.sql
wget -O ${DBNITRO}/sql/DBA_084_CLONE_USER_COMMANDS.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_084_CLONE_USER_COMMANDS.sql
wget -O ${DBNITRO}/sql/DBA_085_AWR_RETENTION_TIME.sql                               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_085_AWR_RETENTION_TIME.sql
wget -O ${DBNITRO}/sql/DBA_086_VERIFY_ALL_INFOS_ABOUT_IO_\&_LATENCY.sql             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_086_VERIFY_ALL_INFOS_ABOUT_IO_\&_LATENCY.sql
wget -O ${DBNITRO}/sql/DBA_087_VERIFY_MAIN_TOP_WAIT_EVENTS_PER_WEEK.sql             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_087_VERIFY_MAIN_TOP_WAIT_EVENTS_PER_WEEK.sql
wget -O ${DBNITRO}/sql/DBA_088_SIZE_BY_OWNER.sql                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_088_SIZE_BY_OWNER.sql
wget -O ${DBNITRO}/sql/DBA_089_VERIFY_LARGESTS_OBJECTS.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_089_VERIFY_LARGESTS_OBJECTS.sql
wget -O ${DBNITRO}/sql/DBA_090_GENERAL_DATABASE_OVERVIEW.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_090_GENERAL_DATABASE_OVERVIEW.sql
wget -O ${DBNITRO}/sql/DBA_091_SQL_SESSION_MONITOR.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_091_SQL_SESSION_MONITOR.sql
wget -O ${DBNITRO}/sql/DBA_092_VERIFY_ALL_SQL_IDS_STATEMENTS.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_092_VERIFY_ALL_SQL_IDS_STATEMENTS.sql
wget -O ${DBNITRO}/sql/DBA_093_VERIFY_NLS_CONFIGURATION.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_093_VERIFY_NLS_CONFIGURATION.sql
wget -O ${DBNITRO}/sql/DBA_094_VERIFY_FAILED_LOGIN.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_094_VERIFY_FAILED_LOGIN.sql
wget -O ${DBNITRO}/sql/DBA_095_VERIFY_ALL_SQL_IDS_STATEMENTS.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_095_VERIFY_ALL_SQL_IDS_STATEMENTS.sql
wget -O ${DBNITRO}/sql/DBA_096_SHOW_INFORMATION_ABOUT_PATCHES.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_096_SHOW_INFORMATION_ABOUT_PATCHES.sql
wget -O ${DBNITRO}/sql/DBA_097_VERIFY_CPU_USAGE_BY_MINUTE.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_097_VERIFY_CPU_USAGE_BY_MINUTE.sql
wget -O ${DBNITRO}/sql/DBA_098_VERIFY_STANDBY_CONFIGURATION.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_098_VERIFY_STANDBY_CONFIGURATION.sql
wget -O ${DBNITRO}/sql/DBA_099_VERIFY_GRANTS_AND_PERMISSIONS_BY_OWNER.sql           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_099_VERIFY_GRANTS_AND_PERMISSIONS_BY_OWNER.sql
wget -O ${DBNITRO}/sql/DBA_100_USER_DETAILS_SESSIONS.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_100_USER_DETAILS_SESSIONS.sql
wget -O ${DBNITRO}/sql/DBA_101_VERIFY_BACKUP_RUNNING_ON_REAL_TIME.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_101_VERIFY_BACKUP_RUNNING_ON_REAL_TIME.sql
wget -O ${DBNITRO}/sql/DBA_102_VERIFY_DATABASE_COMPONENTS_FROM_REGISTRY.sql         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_102_VERIFY_DATABASE_COMPONENTS_FROM_REGISTRY.sql
wget -O ${DBNITRO}/sql/DBA_103_VERIFY_ORACLE_NET_SEND_AND_RECEIVE_SIZE_VOLUME.sql   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_103_VERIFY_ORACLE_NET_SEND_AND_RECEIVE_SIZE_VOLUME.sql
wget -O ${DBNITRO}/sql/DBA_104_START_AN_ADVISOR_TASK.sql                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_104_START_AN_ADVISOR_TASK.sql
wget -O ${DBNITRO}/sql/DBA_105_VERIFY_CONTROLFILES.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_105_VERIFY_CONTROLFILES.sql
wget -O ${DBNITRO}/sql/DBA_106_PREPARE_FOR_PATCHING.sql                             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_106_PREPARE_FOR_PATCHING.sql
wget -O ${DBNITRO}/sql/DBA_107_SHOW_LIST_OF_DATABASE_GRANTS.sql                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_107_SHOW_LIST_OF_DATABASE_GRANTS.sql
wget -O ${DBNITRO}/sql/DBA_108_REDO_LOG_RECOMMENDED_SIZE.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_108_REDO_LOG_RECOMMENDED_SIZE.sql
wget -O ${DBNITRO}/sql/DBA_109_SHOW_CONNECTION_CLIENT_VERSIONS.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_109_SHOW_CONNECTION_CLIENT_VERSIONS.sql
wget -O ${DBNITRO}/sql/DBA_110_CHECK_SYSAUX_TABLESPACE.sql                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_110_CHECK_SYSAUX_TABLESPACE.sql
wget -O ${DBNITRO}/sql/DBA_111_ARCHIVELOG_DELETION_POLICY.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_111_ARCHIVELOG_DELETION_POLICY.sql
wget -O ${DBNITRO}/sql/DBA_112_TABLESPACE_CHECKS.sql                                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_112_TABLESPACE_CHECKS.sql
wget -O ${DBNITRO}/sql/DBA_113_IDENTIFYING_CLIENT_DRIVE_SESSIONS.sql                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/DBA_113_IDENTIFYING_CLIENT_DRIVE_SESSIONS.sql
# OGG
wget -O ${DBNITRO}/sql/ODG_001.sql                                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/ODG_001.sql
wget -O ${DBNITRO}/sql/OGG_001_VERIFY_GOLDEN_GATE_PARAMETERS.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_001_VERIFY_GOLDEN_GATE_PARAMETERS.sql
wget -O ${DBNITRO}/sql/OGG_002_VERIFY_GOLDEN_GATE_CAPTURES_QUEUE_AND_STATUS.sql     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_002_VERIFY_GOLDEN_GATE_CAPTURES_QUEUE_AND_STATUS.sql
wget -O ${DBNITRO}/sql/OGG_003_VERIFY_GOLDEN_GATE_STATE.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_003_VERIFY_GOLDEN_GATE_STATE.sql
wget -O ${DBNITRO}/sql/OGG_004_VERIFY_GOLDEN_GATE_CAPTURE.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_004_VERIFY_GOLDEN_GATE_CAPTURE.sql
wget -O ${DBNITRO}/sql/OGG_005_VERIFY_GOLDEN_GATE_CAPTURE_DETAILS.sql               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_005_VERIFY_GOLDEN_GATE_CAPTURE_DETAILS.sql
wget -O ${DBNITRO}/sql/OGG_006_VERIFY_GOLDEN_GATE_SCN.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_006_VERIFY_GOLDEN_GATE_SCN.sql
wget -O ${DBNITRO}/sql/OGG_007_VERIFY_GOLDEN_GATE_LOGMNR_STATS.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_007_VERIFY_GOLDEN_GATE_LOGMNR_STATS.sql
wget -O ${DBNITRO}/sql/OGG_008_VERIFY_GOLDEN_GATE_OWNER_LOG_GROUP_LOG_TYPE.sql      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/OGG_008_VERIFY_GOLDEN_GATE_OWNER_LOG_GROUP_LOG_TYPE.sql
# PDBs
wget -O ${DBNITRO}/sql/PDB_001_VERIFY_PLUGGABLE_DATABASES.sql                       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_001_VERIFY_PLUGGABLE_DATABASES.sql
wget -O ${DBNITRO}/sql/PDB_002_VERIFY_VIOLATIONS_ON_PDBS.sql                        https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_002_VERIFY_VIOLATIONS_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_003_VERIFY_PROPERTIES_OF_SNAPTHOTS_ON_PDBS.sql           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_003_VERIFY_PROPERTIES_OF_SNAPTHOTS_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_004_VERIFY_AVAILABILITY_OF_SNAPTHOTS_ON_PDBS.sql         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_004_VERIFY_AVAILABILITY_OF_SNAPTHOTS_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_005_VERIFY_SNAPSHOTS_ON_PDBS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_005_VERIFY_SNAPSHOTS_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_006_VERIFY_SNAPTSHOT_JOBS_ON_PDBS.sql                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_006_VERIFY_SNAPTSHOT_JOBS_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_007_VERIFY_SNAPSHOT_REFRESH_ON_PDBS.sql                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_007_VERIFY_SNAPSHOT_REFRESH_ON_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_008_VERIFY_HISTORY_OF_PDBS.sql                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_008_VERIFY_HISTORY_OF_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_009_CHECK_UNDO_MODE.sql                                  https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_009_CHECK_UNDO_MODE.sql
wget -O ${DBNITRO}/sql/PDB_010_CHECK_STARTUP_AND_UPTIME_OF_ALL_PDBS.sql             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_010_CHECK_STARTUP_AND_UPTIME_OF_ALL_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_011_CHECK_UPTIME_OF_ALL_PDBS.sql                         https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_011_CHECK_UPTIME_OF_ALL_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_012_CHECK_CREATION_TIME_AND_STATUS.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_012_CHECK_CREATION_TIME_AND_STATUS.sql
wget -O ${DBNITRO}/sql/PDB_013_VERIFY_SIZE_AND_STATUS_OF_PDBS.sql                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_013_VERIFY_SIZE_AND_STATUS_OF_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_014_VERIFY_SIZE_BY_PDBS.sql                              https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_014_VERIFY_SIZE_BY_PDBS.sql
wget -O ${DBNITRO}/sql/PDB_015_CHECK_PROPERTIES_AND_VALUES.sql                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/sql/PDB_015_CHECK_PROPERTIES_AND_VALUES.sql
# SERVICES
wget -O ${DBNITRO}/services/kill_mining.sh                                          https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/kill_mining.sh
wget -O ${DBNITRO}/services/oracle-observer.sh                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/oracle-observer.sh
wget -O ${DBNITRO}/services/oracle-afd.sh                                           https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/oracle-afd.sh
wget -O ${DBNITRO}/services/oracle-afd.service                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/oracle-afd.service
wget -O ${DBNITRO}/services/emcc-server.service                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/emcc-server.service
wget -O ${DBNITRO}/services/oracle-ohasd.service                                    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/oracle-ohasd.service
wget -O ${DBNITRO}/services/ords.service                                            https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/ords.service
wget -O ${DBNITRO}/services/wls-server.service                                      https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/wls-server.service
wget -O ${DBNITRO}/services/Grid_19c_RU_19_RAC_3_NODES_AFD_1_Disk_Production.rsp    https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/Grid_19c_RU_19_RAC_3_NODES_AFD_1_Disk_Production.rsp
wget -O ${DBNITRO}/services/Grid_19c_RU_19_RAC_3_NODES_AFD_1_Disk_Standby.rsp       https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/Grid_19c_RU_19_RAC_3_NODES_AFD_1_Disk_Standby.rsp
wget -O ${DBNITRO}/services/Oracle_19c_RU_19_RAC_3_Nodes_Production.rsp             https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/Oracle_19c_RU_19_RAC_3_Nodes_Production.rsp
wget -O ${DBNITRO}/services/Oracle_19c_RU_19_RAC_3_Nodes_Standby.rsp                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/services/Oracle_19c_RU_19_RAC_3_Nodes_Standby.rsp
# TOOLS
wget -O ${DBNITRO}/tools/PurgeLogs/p36518442_201_Linux-x86-64.zip                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/p36518442_201_Linux-x86-64.zip
wget -O ${DBNITRO}/tools/PurgeLogs/p36580161_201_Linux-x86-64.zip                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/p36580161_201_Linux-x86-64.zip
wget -O ${DBNITRO}/tools/PurgeLogs/p36580169_201_Linux-x86-64.zip                   https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/p36580169_201_Linux-x86-64.zip
wget -O ${DBNITRO}/tools/PurgeLogs/purgelogs-2.0.1-x.el7.x86_64.rpm                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el7.x86_64.rpm
wget -O ${DBNITRO}/tools/PurgeLogs/purgelogs-2.0.1-x.el8.x86_64.rpm                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el8.x86_64.rpm
wget -O ${DBNITRO}/tools/PurgeLogs/purgelogs-2.0.1-x.el9.x86_64.rpm                 https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/PurgeLogs/purgelogs-2.0.1-x.el9.x86_64.rpm
wget -O ${DBNITRO}/tools/ASMLib/oracleasmlib-3.0.0-13.el8.aarch64.rpm               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/ASMLib/oracleasmlib-3.0.0-13.el8.aarch64.rpm
wget -O ${DBNITRO}/tools/ASMLib/oracleasmlib-3.0.0-13.el8.x86_64.rpm                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/ASMLib/oracleasmlib-3.0.0-13.el8.x86_64.rpm
wget -O ${DBNITRO}/tools/ASMLib/oracleasmlib-3.0.0-13.el9.aarch64.rpm               https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/ASMLib/oracleasmlib-3.0.0-13.el9.aarch64.rpm
wget -O ${DBNITRO}/tools/ASMLib/oracleasmlib-3.0.0-13.el9.x86_64.rpm                https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/ASMLib/oracleasmlib-3.0.0-13.el9.x86_64.rpm
wget -O ${DBNITRO}/tools/AutoUpgrade/autoupgrade.jar                                https://download.oracle.com/otn-pub/otn_software/autoupgrade.jar
wget -O ${DBNITRO}/tools/CheckASMDiskGroups.zip                                     https://raw.githubusercontent.com/dbaribas/dbnitro.net/main/tools/CheckASMDiskGroups.zip
#
chmod a+x ${DBNITRO}/bin/*.sh
chmod a+x ${DBNITRO}/bin/oraenv++
chmod a+x ${DBNITRO}/backup/*.sh
#
chmod -R 775 ${DBNITRO}/
chown -R oracle.oinstall ${DBNITRO}/
}
#
# ------------------------------------------------------------------------
# Setup of Logon Banner
#
SetupLogonBanner() {
  SetClear
  SepLine
  SetTitle
  echo " -- Seting Up The Banner Logon --"
  SetTitle
cat > /etc/motd.d/dbnitro <<EOF
--------------------------------------------------------------------------------------------------------------------

 -- https://www.dbnitro.net
 -- https://github.com/dbaribas/dbnitro.net
 -- ribas@dbnitro.net

 -- Welcome to the Oracle Database Server.
 -- This Server has 2 different users to manage the Oracle System: grid and oracle
 -- User Grid is responsible for the GRID Infrastructure, Listener, Network, Services, Diskgroups and so on.
 -- User Oracle is resposible for all RDBMS Systems and Database Instances.
 -- On both users, you just need to execute " db ", choose an option you what to work and done.

--------------------------------------------------------------------------------------------------------------------
EOF
}
#
# ------------------------------------------------------------------------
# Remove DBNitro Folder
#
RemoveFolder() {
  SetClear
  SepLine
  SetTitle
  echo " -- Removing DBNITRO Folder --"
  SetTitle
if [[ -d ${DBNITRO} ]]; then 
  mv ${DBNITRO} /tmp/dbnitro_$(date +%Y%m%d_%H_%M)
else
  SetTitle
  echo " -- Your Server Does Not Have This Folder: ${DBNITRO} --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# Oracle MOS Account
#
oracleMOS() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle MOS Account --"
  SetTitle
  if [[ ${Username} == "" ]]; then read -p    "Username: " Username; else echo " -- Oracle MOS Account Already Informed --"; fi
  if [[ ${Password} == "" ]]; then read -s -p "Password: " Password else; echo " -- Oracle MOS Password Already Informed --"; fi
}
#
# ------------------------------------------------------------------------
# Oracle 19c
#
Oracle19c() {
  SetClear
  SepLine
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  SetTitle
  echo " -- Oracle 19c Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.X64_193000_db_home.zip"   "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V982063-01.zip&token=SkF0OHZvK1lDT3NKYlJvNnkyOVEzUSE6OiFmaWxlSWQ9MTA0NDg4MDA2JmZpbGVTZXRDaWQ9OTAxMzc3JnJlbGVhc2VDaWRzPTg5NDk4MiZwbGF0Zm9ybUNpZHM9MzUmZG93bmxvYWRUeXBlPTk1NzY0JmFncmVlbWVudElkPTEwNzIyNzg4JmVtYWlsQWRkcmVzcz1hbmRyZS5yaWJhc0B1bWIuY2gmdXNlck5hbWU9RVBELUFORFJFLlJJQkFTQFVNQi5DSCZpcEFkZHJlc3M9MTc4LjM4LjIxOS4yNDEmdXNlckFnZW50PU1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40LjEgU2FmYXJpLzYwNS4xLjE1JmNvdW50cnlDb2RlPUNIJmRscENpZHM9MTA2MzIwOQ"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.X64_193000_grid_home.zip" "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V982068-01.zip&token=d0h3RDh4cnhTdlpvVmF0blZUVzdQZyE6OiFmaWxlSWQ9MTA0NDg4MDA5JmZpbGVTZXRDaWQ9OTAxMzI3JnJlbGVhc2VDaWRzPTg5OTMzMiZwbGF0Zm9ybUNpZHM9MzUmZG93bmxvYWRUeXBlPTk1NzY0JmFncmVlbWVudElkPTEwNzIyNzg4JmVtYWlsQWRkcmVzcz1hbmRyZS5yaWJhc0B1bWIuY2gmdXNlck5hbWU9RVBELUFORFJFLlJJQkFTQFVNQi5DSCZpcEFkZHJlc3M9MTc4LjM4LjIxOS4yNDEmdXNlckFnZW50PU1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40LjEgU2FmYXJpLzYwNS4xLjE1JmNvdW50cnlDb2RlPUNIJmRscENpZHM9MTA2MzIwOQ"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  SetTitle
  echo " -- Oracle 19c Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.ARM64_1919000_db_home.zip"   "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1036132-01.zip&token=aTAwWHNTL0lUY0hBTEVpUm9HcG5ndyE6OiFmaWxlSWQ9MTE2OTE0NDQ4JmZpbGVTZXRDaWQ9MTEyMzE4NSZyZWxlYXNlQ2lkcz04OTQ5ODImcGxhdGZvcm1DaWRzPTM2MDg5NiZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTA3MjI3ODgmZW1haWxBZGRyZXNzPWFuZHJlLnJpYmFzQHVtYi5jaCZ1c2VyTmFtZT1FUEQtQU5EUkUuUklCQVNAVU1CLkNIJmlwQWRkcmVzcz0xNzguMzguMjE5LjI0MSZ1c2VyQWdlbnQ9TW96aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTVfNykgQXBwbGVXZWJLaXQvNjA1LjEuMTUgKEtIVE1MLCBsaWtlIEdlY2tvKSBWZXJzaW9uLzE3LjQuMSBTYWZhcmkvNjA1LjEuMTUmY291bnRyeUNvZGU9Q0gmZGxwQ2lkcz0xMDYzMjA5"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.ARM64_1919000_grid_home.zip" "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1036135-01.zip&token=TWtUVHp2UXpkZVVld3Ntc3RWTEd4dyE6OiFmaWxlSWQ9MTE2OTE0NTE5JmZpbGVTZXRDaWQ9MTEyMzIyNiZyZWxlYXNlQ2lkcz04OTkzMzImcGxhdGZvcm1DaWRzPTM2MDg5NiZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTA3MjI3ODgmZW1haWxBZGRyZXNzPWFuZHJlLnJpYmFzQHVtYi5jaCZ1c2VyTmFtZT1FUEQtQU5EUkUuUklCQVNAVU1CLkNIJmlwQWRkcmVzcz0xNzguMzguMjE5LjI0MSZ1c2VyQWdlbnQ9TW96aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTVfNykgQXBwbGVXZWJLaXQvNjA1LjEuMTUgKEtIVE1MLCBsaWtlIEdlY2tvKSBWZXJzaW9uLzE3LjQuMSBTYWZhcmkvNjA1LjEuMTUmY291bnRyeUNvZGU9Q0gmZGxwQ2lkcz0xMDYzMjA5"
else
  SetTitle
  echo " -- Your platform architecture ${PLATFORM} is not supported!!!"
  SetTitle
  return 1
fi
}
#
# ------------------------------------------------------------------------
# Oracle 21c
#
Oracle21c() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 21c Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.X64_213000_db_home.zip"   "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1011496-01.zip&token=UnFKQTU1cDB4eXN4VGpJT216RjhaUSE6OiFmaWxlSWQ9MTEyNzEwMDcwJmZpbGVTZXRDaWQ9MTA2MTA2NCZyZWxlYXNlQ2lkcz0xMDI1NjE0JnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTA3MjMwMzYmZW1haWxBZGRyZXNzPWFuZHJlLnJpYmFzQHVtYi5jaCZ1c2VyTmFtZT1FUEQtQU5EUkUuUklCQVNAVU1CLkNIJmlwQWRkcmVzcz0xNzguMzguMjE5LjI0MSZ1c2VyQWdlbnQ9TW96aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTVfNykgQXBwbGVXZWJLaXQvNjA1LjEuMTUgKEtIVE1MLCBsaWtlIEdlY2tvKSBWZXJzaW9uLzE3LjQuMSBTYWZhcmkvNjA1LjEuMTUmY291bnRyeUNvZGU9Q0gmZGxwQ2lkcz0xMDYxMjE5LCAxMDU4OTY2LCAxMDYxMzY2"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate -O "LINUX.X64_213000_grid_home.zip" "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1011504-01.zip&token=b3c2TEdnQVQzNU52YUU5bTJLdVNTQSE6OiFmaWxlSWQ9MTEyNzEwNDAxJmZpbGVTZXRDaWQ9MTA2MDg2MSZyZWxlYXNlQ2lkcz0xMDQ5ODY3JnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTA3MjMwMzYmZW1haWxBZGRyZXNzPWFuZHJlLnJpYmFzQHVtYi5jaCZ1c2VyTmFtZT1FUEQtQU5EUkUuUklCQVNAVU1CLkNIJmlwQWRkcmVzcz0xNzguMzguMjE5LjI0MSZ1c2VyQWdlbnQ9TW96aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTVfNykgQXBwbGVXZWJLaXQvNjA1LjEuMTUgKEtIVE1MLCBsaWtlIEdlY2tvKSBWZXJzaW9uLzE3LjQuMSBTYWZhcmkvNjA1LjEuMTUmY291bnRyeUNvZGU9Q0gmZGxwQ2lkcz0xMDYxMjE5LCAxMDU4OTY2"
}
#
# ------------------------------------------------------------------------
# Oracle 21cExpress
#
Oracle21cExpress() {
  SetClear
  SepLine
if [[ ${OS_VERSION} == "8".* ]]; then 
  if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 21c Express Downloading --"
    SetTitle
    wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
  else
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 21c Express Is Not Available For This Archtecture: ${ARCHITECTURE} Yet --"
    SetTitle
  fi
elif [[ ${OS_VERSION} == "9".* ]]; then 
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 21c Express Is Not Available Yet --"
  SetTitle
else
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 21c Express Is Not Available Yet --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# Oracle 23ai
#
Oracle23ai() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 23ai Is Not Available Yet --"
  SetTitle
}
#
# ------------------------------------------------------------------------
# Oracle 23ai Free
#
Oracle23aiFree() {
  SetClear
  SepLine
if [[ "${OS_VERSION}" == "8".* ]]; then 
  if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 23ai Free Downloading --"
    SetTitle
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm
  else
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 23ai Free Downloading --"
    SetTitle
    wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/aarch64/getPackage/oracle-database-preinstall-23ai-1.0-3.el8.aarch64.rpm
  fi
elif [[ "${OS_VERSION}" == "9".* ]]; then 
  if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 23ai Free Downloading --"
    SetTitle
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23ai-1.0-1.el9.x86_64.rpm
  else
    SetClear
    SepLine
    SetTitle
    echo " -- Oracle 23ai Free Downloading --"
    SetTitle
    wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23ai-1.0-1.el8.aarch64.rpm
  fi
else
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 23ai Free Is Not Available Yet --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# 
#
Oracle19cJan2023() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c January 2023 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34416665_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p34416665_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34419443_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p34419443_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34113634_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p34113634_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34411846_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p34411846_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p33912872_190000_Linux-${ARCHITECTURE}_PERL.zip" "https://updates.oracle.com/Orion/Download/download_patch/p33912872_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34734035_1917000DBRU_Generic.zip"               "https://updates.oracle.com/Orion/Download/download_patch/p34734035_1917000DBRU_Generic.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c April 2023
#
Oracle19cApr2023() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c April 2023 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"                  "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35037840_190000_Linux-${ARCHITECTURE}_GI.zip"              "https://updates.oracle.com/Orion/Download/download_patch/p35037840_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35042068_190000_Linux-${ARCHITECTURE}_DB.zip"              "https://updates.oracle.com/Orion/Download/download_patch/p35042068_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p29511771_190000_Linux-${ARCHITECTURE}.zip"                 "https://updates.oracle.com/Orion/Download/download_patch/p29511771_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p30432118_190000_Linux-${ARCHITECTURE}.zip"                 "https://updates.oracle.com/Orion/Download/download_patch/p30432118_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p34777391_190000_Linux-${ARCHITECTURE}_JDK.zip"             "https://updates.oracle.com/Orion/Download/download_patch/p34777391_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35050341_190000_Linux-${ARCHITECTURE}_OJVM.zip"            "https://updates.oracle.com/Orion/Download/download_patch/p35050341_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p33912872_190000_Linux-${ARCHITECTURE}_PERL.zip"            "https://updates.oracle.com/Orion/Download/download_patch/p33912872_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p30971231_196000OCWRU_Linux-${ARCHITECTURE}.zip"            "https://updates.oracle.com/Orion/Download/download_patch/p30971231_196000OCWRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35068505_1919000ACFSRU_Linux-${ARCHITECTURE}_GI_FIRST.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35068505_1919000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35261302_1919000DBRU_Generic.zip"                          "https://updates.oracle.com/Orion/Download/download_patch/p35261302_1919000DBRU_Generic.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c July 2023
#
Oracle19cJul2023() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c July 2023 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35319490_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p35319490_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35320081_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p35320081_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35336174_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p35336174_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35354406_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35354406_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c October 2023
#
Oracle19cOct2023() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c October 2023 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"         "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35642822_190000_Linux-${ARCHITECTURE}_GI.zip"     "https://updates.oracle.com/Orion/Download/download_patch/p35642822_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35643107_190000_Linux-${ARCHITECTURE}_DB.zip"     "https://updates.oracle.com/Orion/Download/download_patch/p35643107_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35638318_190000_Linux-${ARCHITECTURE}_JDK.zip"    "https://updates.oracle.com/Orion/Download/download_patch/p35638318_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35648110_190000_Linux-${ARCHITECTURE}_OJVM.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p35648110_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35988503_1921000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35988503_1921000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c January 2024
#
Oracle19cJan2024() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c January 2024 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"         "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35940989_190000_Linux-${ARCHITECTURE}_GI.zip"     "https://updates.oracle.com/Orion/Download/download_patch/p35940989_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35943157_190000_Linux-${ARCHITECTURE}_DB.zip"     "https://updates.oracle.com/Orion/Download/download_patch/p35943157_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35949090_190000_Linux-${ARCHITECTURE}_JDK.zip"    "https://updates.oracle.com/Orion/Download/download_patch/p35949090_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35926646_190000_Linux-${ARCHITECTURE}_OJVM.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p35926646_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${UsernameE}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p35988503_1922000ACFSRU_Linux-${ARCHITECTURE}.zip" "https://updates.oracle.com/Orion/Download/download_patch/p35988503_1922000ACFSRU_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c April 2024
#
Oracle19cApr2024() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c April 2024 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36233126_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36233126_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36233263_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36233263_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36195566_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p36195566_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36199232_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36199232_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c April 2024
#
Oracle19cJul2024() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c July 2024 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36582629_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36582629_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36582781_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36582781_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36538667_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p36538667_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36414915_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36414915_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c October 2024
#
Oracle19cOct2024() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c October 2024 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36916690_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36916690_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36912597_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p36912597_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36866578_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p36866578_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36878697_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p36878697_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c January 2025
#
Oracle19cJan2025() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c January 2025 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37257886_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p37257886_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37260974_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p37260974_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37213431_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p37213431_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37102264_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p37102264_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#
# ------------------------------------------------------------------------
# Oracle Patch 19c April 2025
#
Oracle19cApr2025() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle 19c April 2025 Patches Downloading --"
  SetTitle
  oracleMOS
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p6880880_190000_Linux-${ARCHITECTURE}.zip"       "https://updates.oracle.com/Orion/Download/download_patch/p6880880_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37641958_190000_Linux-${ARCHITECTURE}_GI.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p37641958_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37642901_190000_Linux-${ARCHITECTURE}_DB.zip"   "https://updates.oracle.com/Orion/Download/download_patch/p37642901_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37542054_190000_Linux-${ARCHITECTURE}_JDK.zip"  "https://updates.oracle.com/Orion/Download/download_patch/p37542054_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p37499406_190000_Linux-${ARCHITECTURE}_OJVM.zip" "https://updates.oracle.com/Orion/Download/download_patch/p37499406_190000_Linux-${ARCHITECTURE}.zip?patch_password=patch_password"
}
#


# ------------------------------------------------------------------------
# Setup AutoUpgrade
#
autoup() {
      #  JAVA="/usr/bin/java"
      # JAVA="/opt/homebrew/opt/java11/bin/java"
        JAVA="/u01/app/oracle/product/19.3.0.1/db_EE_01/jdk/bin/java"
      WALLET="/opt/oracle/wallet"
         LOG="${WALLET}/log"
         KEY="${WALLET}/keystore"
      FOLDER="${WALLET}/downloads"
ARCHITECTURE="$(uname -m)"


SetClear
SepLine
PS3="Select the Architecture/Platform: "
select ARCH in "ARM.x64" "LINUX.X64"; do
  if [[ ${ARCH} == "ARM.x64" ]]; then
    PLATFORM="ARM.x64"
  elif [[ ${ARCH} == "LINUX.X64" ]]; then
    PLATFORM="LINUX.X64"
  else
    echo " -- Invalid Option --"
    continue
  fi
break
done


SetClear
SepLine
PS3="Select the Version: "
select ORA_VERSION in 19c 21c 23ai; do
  if [[ ${ORA_VERSION} == "19c" ]]; then
    VERSION="19"
  elif [[ ${ORA_VERSION} == "21c" ]]; then
    VERSION="21"
  elif [[ ${ORA_VERSION} == "23ai" ]]; then
    VERSION="23"
  else
    echo " -- Invalid Option --"
    continue
  fi
break
done


cat > ${WALLET}/linux_${PLATFORM}_download.cfg <<EOF
# Created by AutoUpgrade Composer
# Patch, ExecMode: Download
#
global.global_log_dir=${LOG}
global.keystore=${KEY}
#
patch1.log_dir=${LOG}
patch1.folder=${FOLDER}
patch1.patch=OPATCH,RECOMMENDED,RU,OCW,DPBP,OJVM
patch1.target_version=${VERSION}
patch1.platform=${PLATFORM}
patch1.download=YES
EOF


SetClear
SepLine
PS3="Select the Option: "
select OPT in download_autoupgrade configure_autoupgrade download_patches QUIT; do
  if [[ ${OPT} == "download_autoupgrade" ]]; then
    mkdir -p ${WALLET} ${FOLDER} ${LOG}
    wget -O ${WALLET}/autoupgrade.jar https://download.oracle.com/otn-pub/otn_software/autoupgrade.jar
    continue
  elif [[ ${OPT} == "configure_autoupgrade" ]]; then
    mkdir -p ${WALLET} ${FOLDER} ${LOG}
    ${JAVA} -jar ${WALLET}/autoupgrade.jar -config ${WALLET}/linux_${PLATFORM}_download.cfg -patch -load_password 
    continue
  elif [[ ${OPT} == "download_patches" ]]; then
    mkdir -p ${WALLET} ${FOLDER} ${LOG}
    ${JAVA} -jar ${WALLET}/autoupgrade.jar -config ${WALLET}/linux_${PLATFORM}_download.cfg -patch -mode download
    continue
  elif [[ "${OPT}" == "QUIT" ]]; then
    echo " -- Exit Menu --"
    return 1
  else
    echo " -- Invalid Option --"
    continue
  fi
break
done
}
#
# ------------------------------------------------------------------------
# Setup Purge Logs ZIP
#
OraclePurgeLogsZip() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle PurgeLogs Downloading --"
  SetTitle
  oracleMOS
if [[ ${OS_VERSION} == "8".* ]]; then 
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36580161_201_Linux-x86-64.zip" "https://updates.oracle.com/Orion/Services/download/p36580161_OL8-x86-64.zip?aru=25667843"
elif [[ ${OS_VERSION} == "9".* ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="/tmp/p36580169_201_Linux-x86-64.zip" "https://updates.oracle.com/Orion/Services/download/p36580169_OL9-x86-64.zip?aru=25667974"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF May 2024
#
OracleAHF_24_4() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle AHF May 2024 Downloading --"
  SetTitle
  oracleMOS
if [[ -d /opt/oracle.ahf ]]; then
  AHF_FOLDER="/opt/oracle.ahf"
else
  AHF_FOLDER="/tmp"
  SetTitle
  echo " -- Oracle AHF May 2024 Downloading on: ${AHF_FOLDER} --"
  SetTitle
fi
#
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX_v24.4.0.zip"       "https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v24.4.0.zip?aru=25668321&patch_file=AHF-LINUX_v24.4.0.zip"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX.ARM64_v24.4.0.zip" "https://updates.oracle.com/Orion/Services/download/AHF-LINUX.ARM64_v24.4.0.zip?aru=25668320&patch_file=AHF-LINUX.ARM64_v24.4.0.zip"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF June 2024
#
OracleAHF_24_5() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle AHF June 2024 Downloading --"
  SetTitle
  oracleMOS
if [[ -d /opt/oracle.ahf ]]; then
  AHF_FOLDER="/opt/oracle.ahf"
else
  AHF_FOLDER="/tmp"
  SetTitle
  echo " -- Oracle AHF June 2024 Downloading on: ${AHF_FOLDER} --"
  SetTitle
fi
#
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX_v24.5.0.zip"       "https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v24.5.0.zip?aru=25668321&patch_file=AHF-LINUX_v24.5.0.zip"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX.ARM64_v24.5.0.zip" "https://updates.oracle.com/Orion/Services/download/AHF-LINUX.ARM64_v24.5.0.zip?aru=25668320&patch_file=AHF-LINUX.ARM64_v24.5.0.zip"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF July 2024
#
OracleAHF_24_6() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle AHF July 2024 Downloading --"
  SetTitle
  oracleMOS
if [[ -d /opt/oracle.ahf ]]; then
  AHF_FOLDER="/opt/oracle.ahf"
else
  AHF_FOLDER="/tmp"
  SetTitle
  echo " -- Oracle AHF july 2024 Downloading on: ${AHF_FOLDER} --"
  SetTitle
fi
#
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX_v24.6.0.zip"       "https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v24.6.0.zip?aru=25668321&patch_file=AHF-LINUX_v24.6.0.zip"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX.ARM64_v24.6.0.zip" "https://updates.oracle.com/Orion/Services/download/AHF-LINUX.ARM64_v24.6.0.zip?aru=25668320&patch_file=AHF-LINUX.ARM64_v24.6.0.zip"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF August 2024
#
OracleAHF_24_7() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle AHF August 2024 Downloading --"
  SetTitle
  oracleMOS
if [[ -d /opt/oracle.ahf ]]; then
  AHF_FOLDER="/opt/oracle.ahf"
else
  AHF_FOLDER="/tmp"
  SetTitle
  echo " -- Oracle AHF August 2024 Downloading on: ${AHF_FOLDER} --"
  SetTitle
fi
#
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX_v24.7.0.zip"       "https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v24.7.0.zip?aru=25668321&patch_file=AHF-LINUX_v24.7.0.zip"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX.ARM64_v24.7.0.zip" "https://updates.oracle.com/Orion/Services/download/AHF-LINUX.ARM64_v24.7.0.zip?aru=25668320&patch_file=AHF-LINUX.ARM64_v24.7.0.zip"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF September 2024
#
OracleAHF_24_8() {
  SetClear
  SepLine
  SetTitle
  echo " -- Oracle AHF September 2024 Downloading --"
  SetTitle
  oracleMOS
if [[ -d /opt/oracle.ahf ]]; then
  AHF_FOLDER="/opt/oracle.ahf"
else
  AHF_FOLDER="/tmp"
  SetTitle
  echo " -- Oracle AHF September 2024 Downloading on: ${AHF_FOLDER} --"
  SetTitle
fi
#
if [[ "${ARCHITECTURE}" == "x86_64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX_v24.8.0.zip"       "https://updates.oracle.com/Orion/Services/download/AHF-LINUX_v24.8.0.zip?aru=25808805&patch_file=AHF-LINUX_v24.8.0.zip"
elif [[ "${ARCHITECTURE}" == "ARM-64" ]]; then
  wget --http-user="${Username}" --http-password="${Password}" --no-check-certificate --output-document="${AHF_FOLDER}/AHF-LINUX.ARM64_v24.8.0.zip" "https://updates.oracle.com/Orion/Services/download/AHF-LINUX.ARM64_v24.8.0.zip?aru=25808804&patch_file=AHF-LINUX.ARM64_v24.8.0.zip"
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF May 2024
#
OracleAHF_Upgrade() {
  SetClear
  SepLine
if [[ -d /opt/oracle.ahf ]]; then
  SetTitle
  echo " -- Oracle AHF Upgrade --"
  SetTitle
  ahfctl version
  ahfctl upgrade
  ahfctl version
else
  SetTitle
  echo " -- Oracle AHF Is Saved on: /tmp --"
  echo " -- You Can Install AHF Now --"
  SetTitle
fi
}
#
# ------------------------------------------------------------------------
# Oracle AHF May 2024
#
OracleAHF_Configure() {
  SetClear
  SepLine
if [[ -d /opt/oracle.ahf ]]; then
  SetTitle
  echo " -- Oracle AHF May 2024 Setup Upgrade --"
  SetTitle
  ahfctl version
  ahfctl setupgrade -autoupgrade on -swstage /opt/oracle.ahf -frequency 15 -autoupdate on
fi
}
#
# ------------------------------------------------------------------------
# Oracle Main Menu
#
MainMenu() {
  SetClear
PS3="Select the Option: "
select OPT in LinuxConfigure LinuxUpdate PackageCheck PackageInstall LinuxKernel DBNitroSetup DBNitroUpdate DBNitroRemove Oracle_19c Oracle_21c Oracle_21c_XE Oracle_23ai Oracle_23aiFree AutoUpgrade AHF_CONFIGURE AHF_UPGRADE HELP QUIT; do
if [[ "${OPT}" == "QUIT" ]]; then
  SetTitle
  echo " -- Exit Menu --"
  SetTitle
  exit 1
elif [[ "${OPT}" == "LinuxConfigure" ]]; then
  ConfigureFolders
  SetUpLinuxRoot
  SetUpLinuxFirewall
  SetUpLinuxUTF8
  SetUpLinuxNOZEROCONF
  SetUpLinuxSCP
  SetUpLinuxHosts
  SetUpLinuxSeLinux
  SetUpLinuxSecurityLimits
  SetUpLinuxGroups
  SetUpLinuxUsers
  # SetUpLinuxUsersPasswords
  SetUpLinuxFolders
  SetUpLinuxSudoers
  SetUpLinuxGrid
  SetUpLinuxOracle
  SetUpLinuxTMPFS
  SetUpLinuxDiskManagement
  SetUpLinuxChrony
  SetUpLinuxEpel
  SetUpLinuxLRLWRAP
  SetUpLinuxJava
  SetUpLinuxPurgeLogs
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "LinuxUpdate" ]]; then
  UpdateLinux
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "PackageCheck" ]]; then
  CheckLinuxPackages
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "PackageInstall" ]]; then
  InstallLinuxPackages
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "LinuxKernel" ]]; then
  SetUpLinuxDisableTransparentHugePages
  SetUpLinuxKernel
  OracleParameter
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "DBNitroSetup" ]]; then
  ConfigureFolders
  SetUpLinuxGrid
  SetUpLinuxOracle
  SetUpDBNitro
  SetupLogonBanner
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "DBNitroUpdate" ]]; then
  RemoveFolder
  ConfigureFolders
  SetUpLinuxGrid
  SetUpLinuxOracle
  SetUpDBNitro
  SetupLogonBanner
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "DBNitroRemove" ]]; then
  RemoveFolder
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "Oracle_19c" ]]; then
  Oracle19c
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "Oracle_21c" ]]; then
  Oracle21c
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "Oracle_21c_XE" ]]; then
  Oracle21cExpress
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "Oracle_23ai" ]]; then
  Oracle23ai
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "Oracle_23aiFree" ]]; then
  Oracle23aiFree
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "AutoUpgrade" ]]; then
  AutoUpgrade
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "AHF_CONFIGURE" ]]; then
  OracleAHF_Configure
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "AHF_UPGRADE" ]]; then
  OracleAHF_Upgrade
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
elif [[ "${OPT}" == "HELP" ]]; then
  HELP
  SetTitle
  echo " -- Press ENTER to continue --"
  read
  continue
else
  SetTitle
  echo " -- Invalid Option --"
  continue
fi
break
done
}
#
MainMenu
#
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# THE SCRIPT FINISHES HERE
# --------------//--------------//--------------//--------------//--------------//--------------//--------------//-----
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
# dnf -y install wget vim bc unzip tar sshpass rlwrap