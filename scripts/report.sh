#!/bin/bash
### Devoloped and maintained by Cygate Cloud Services - Linux team ###
DATE=`date`
log_file="/tmp/`hostname`.txt"
ARCH=`arch`
VER="1.0"
HOSTNAME=`hostname`

## Checking basic stuffs ##
BASIC_CHECK() {
if [ ! -f $log_file ]; then
   touch $log_file
else
   echo > $log_file
fi
}

## Checking Ubuntu Security patches #
UB_SEC_CHECK(){
  echo "" >> $log_file 2>&1
  sec_count=`/usr/lib/update-notifier/apt-check 2>&1 | cut -d ';' -f 2`
  echo "====== Security Updates ========" >> $log_file 2>&1
  echo "$sec_count updates are security updates." >> $log_file 2>&1
}

## Checking Debian Security patches #
DEB_SEC_CHECK(){
  echo "" >> $log_file 2>&1
  echo "====== Security Updates ========" >> $log_file 2>&1
  echo "Could not find the security upgrades from Debian." >> $log_file 2>&1
}

## Checking CentOS Security patches #
CENT_SEC_CHECK(){
  cmd=`yum info yum | grep "Loaded plugins"`
  if [[ $cmd != *"security"* ]]; then
    yum -y install yum-plugin-security
  else
    echo "" >> $log_file 2>&1
    sec_update=`yum check-update --security | grep -E "package(s) needed \
    for security|No packages needed for security"`
    echo "====== Security Updates ========" >> $log_file 2>&1
    echo $sec_update >> $log_file 2>&1
  fi
}

## Check OS ##
OS_CHECK() {
  if [ `which apt-get &> /dev/null;echo $?` -eq 0 ]; then
    if [ -f /etc/lsb-release ]; then
      OS=`lsb_release -i | awk {'print $3'}`
      if [ $OS == "Ubuntu" ]; then
        echo "" >> $log_file 2>&1
        echo "OS: $OS" >> $log_file 2>&1
        echo "Hostname: $HOSTNAME" >> $log_file 2>&1
        UB_SEC_CHECK;
      elif [ $OS == "Debian" ]; then
        echo "" >> $log_file 2>&1
        echo "OS: $OS" >> $log_file 2>&1
        echo "Hostname: $HOSTNAME" >> $log_file 2>&1
        DEB_SEC_CHECK;
      elif [ $OS == "CentOS" ]; then
        echo "" >> $log_file 2>&1
        echo "OS: $OS" >> $log_file 2>&1
        echo "Hostname: $HOSTNAME" >> $log_file 2>&1
        CENT_SEC_CHECK;
      fi
    elif [ -f /etc/debian_version ]; then
      echo "" >> $log_file 2>&1
      echo "OS: Debian" >> $log_file 2>&1
      echo "Hostname: $HOSTNAME" >> $log_file 2>&1
      DEB_SEC_CHECK;
    fi
  elif [ `which yum &> /dev/null;echo $?` -eq 0 ]; then
      echo "" >> $log_file 2>&1
      echo "OS: CentOS/Redhat" >> $log_file 2>&1
      echo "Hostname: $HOSTNAME" >> $log_file 2>&1
      CENT_SEC_CHECK;
  fi
}

## MEM Check ##
MEM_CHECK() {
  echo "" >> $log_file 2>&1
  echo "======     Memory Usage   ======" >> $log_file 2>&1
  free -m >> $log_file 2>&1
}

## HDD Check ##
HDD_CHECK() {
echo "" >> $log_file 2>&1
echo "======     Disk Usage     ======" >> $log_file 2>&1
df -Ph >> $log_file 2>&1
}

## All functions call ##
MAIN_FUNC() {
  BASIC_CHECK;
  OS_CHECK;
  MEM_CHECK;
  HDD_CHECK;
}

## Calling main functon #
MAIN_FUNC;
