#!/bin/bash

### Devoloped and maintained by Cygate Cloud Services - Linux team ###

## Variables ##
DATE=`date`
log_file="/tmp/`hostname`.txt"
ARCH=`arch`
VER="1.0"
HOSTNAME=`hostname`

## Clearing the log file if already exists ##
echo > $log_file

## Checking basic stuffs ##
        BASIC_CHECK() {
                # Logfile check #
                if [ ! -f $log_file ];
                        then
                #echo "" >> /dev/null 2>&1
                        touch $log_file
                fi

}


## Mandatory tools for RHEL/CentOS ##
        RHEL_TOOLS() {
                yum -y install yum-plugin-security bc bind-utils >> /dev/null 2>&1
}


## Check OS ##
        OS_CHECK() {
                # Debian OR Ubuntu #
                if [ -f /etc/lsb-release ];
                        then
                                D_OS=`lsb_release -d|awk -F':' {'print $2'}`
                                CODE=`lsb_release -c|awk -F':' {'print $2'}`
                                echo "======     OS Info        ======" >> $log_file 2>&1
                                echo "OS:" $D_OS >> $log_file 2>&1
                                echo "Arch:" $ARCH >> $log_file 2>&1
                                echo "Code name:" $CODE >> $log_file 2>&1
                                echo "Hostname:" $HOSTNAME >> $log_file 2>&1
                                echo "" >> $log_file 2>&1
                                # Apt-get update #
                                APT_GET=`which apt-get`
                                if [ ! -f $APT_GET ]; then
                                        exit 1
                                fi
                                apt-get update >> /dev/null 2>&1
                                UD_FILE="/tmp/updates.list"
                                echo > $UD_FILE
                                echo "List of available updates:" >> $UD_FILE
                                echo "===========================" >> $UD_FILE
                                apt-get -s upgrade >> /tmp/updates.list
                                UD_COUNT=`apt-get -s upgrade |grep upgraded|tail -n1 |awk {'print $1'}`
                                if [ ! $UD_COUNT -ge 1 ]; then
                                        echo "`hostname` is up-to-date." >> $log_file 2>&1
                                                else
                                        echo "$UD_COUNT Update(s) available to install. Please refer $UD_FILE for update info." >> $log_file 2>&1
				fi
                        else
                                RHEL_CHECK;
                fi
        }


# RHEL OR CentOS #
        RHEL_CHECK() {
                if [ -f /etc/redhat-release ];
                        then
                                echo "$(tput bold) $(tput setaf 1) OS: RHEL/CentOS $(tput sgr 0)"
                                R_OS=`cat /etc/redhat-release`
                echo "======     OS Info        ======" >> $log_file 2>&1
                echo "OS:" $R_OS >> $log_file 2>&1
                                echo "Arch:" $ARCH >> $log_file 2>&1
                                RHEL_TOOLS;
                                # Yum updates #
                                YUM_CHK=`which yum`
                                        if [ ! -f $YUM_CHK ]; then
                                                echo "$(tput bold) $(tput setaf 1) Please check yum package.. $(tput sgr 0)"
                                                exit 1
                                        fi
                                UD_FILE="/tmp/updates.list"
                                echo > $UD_FILE
                                echo "List of available updates:" >> $UD_FILE
                                echo "===========================" >> $UD_FILE
                                LIST=`yum check-update |grep -v -E "Loaded|Loading|\*|^$" >> $UD_FILE`
                                TOTAL=`cat $UD_FILE|wc -l`
                                        if [ ! $TOTAL -gt 3 ]; then
                                                echo "`hostname` is up-to-date." >> $log_file 2>&1
                                        else
                                        KERN_UD=`grep -i kernel $UD_FILE|wc -l`
                                        echo "" >> $log_file 2>&1
                                        echo "Please find the available update(s) here: $UD_FILE" >> $log_file 2>&1
                                                if [ $KERN_UD -eq 0 ]; then
                                                        echo "Note: Server reboot is NOT required after updates installed." >> $log_file 2>&1
                                                else
                                                        echo "Note: Server reboot is MANDATORY since kernel package updates are there." >> $log_file 2>&1
                                                fi
                                        fi
                                else
                                        DEBIAN_OS=$(for f in $(find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null); \
                                        do echo ${f:5:${#f}-13}; done;)
                                                if  [ $DEBIAN_OS == "debian" ]; then
                                                        echo "$(tput bold) $(tput setaf 1) OS: Debian $(tput sgr 0)"
                                                        D_OS=`lsb_release -d|awk -F':' {'print $2'}`
                                                        CODE=`lsb_release -c|awk -F':' {'print $2'}`
                                                        echo "======     OS Info        ======" >> $log_file 2>&1
                                                        echo "OS:" $D_OS >> $log_file 2>&1
                                                        echo "Arch:" $ARCH >> $log_file 2>&1
                                                        echo "Code name:" $CODE >> $log_file 2>&1
                                                        echo "Hostname:" $HOSTNAME >> $log_file 2>&1
                                                        echo "" >> $log_file 2>&1
                                                        # Apt-get update #
                                                        APT_GET=`which apt-get`
                                                                if [ ! -f $APT_GET ]; then
                                                                        echo "$(tput bold) $(tput setaf 1) Error: apt-get is not installed or missing..! $(tput sgr 0)"
                                                                        exit 1
                                                                fi
                                                        apt-get update >> /dev/null 2>&1
                                                        UD_FILE="/tmp/updates.list"
                                                        echo > $UD_FILE
                                                        echo "List of available updates:" >> $UD_FILE
                                                        echo "===========================" >> $UD_FILE
                                                        apt-get -s upgrade >> /tmp/updates.list
                                                        UD_COUNT=`apt-get -s upgrade |grep upgraded|tail -n1 |awk {'print $1'}`
                                                                if [ ! $UD_COUNT -ge 1 ]; then
                                                                        echo "" >> $log_file 2>&1
                                                                        echo "`hostname` is up-to-date." >> $log_file 2>&1
                                                                else
                                                                        echo "" >> $log_file 2>&1
                                                                        echo "$UD_COUNT Update(s) available to install. Please refer $UD_FILE for update info." >> $log_file 2>&1
                                                                fi
                                                else
                                                        echo "$(tput bold) $(tput setaf 1) Error: Unable to detect OS version of `hostname` $(tput sgr 0)"
                                                fi
                        fi
        }

## CPU Check ##
        CPU_CHECK() {
                echo "" >> $log_file 2>&1
                echo "======     CPU Information  ======" >> $log_file 2>&1
                CPU_INFO=/proc/cpuinfo
                if [ ! -f /proc/cpuinfo ];
                        then
                                echo "$(tput bold) $(tput setaf 1) CPU Check errors: $CPU_INFO not found..$(tput sgr 0)"
                                echo "Warning: $CPU_INFO is missing.." >> $log_file 2>&1
                                exit 1
                        else
                                echo "No of CPU Core(s) :" `grep processor $CPU_INFO|wc -l` >> $log_file 2>&1
                                grep -E "model name|cpu MHz" $CPU_INFO|tail -n2 >> $log_file 2>&1
                fi
        }

## MEM Check ##
        MEM_CHECK() {
                #bc check
                if [ ! -f /usr/bin/bc ]; then
                                echo "$(tput bold) $(tput setaf 1) bc is not installed, please install. $(tput sgr 0)"
                                exit 1
                        else
                TOTAL_MEM=`grep MemTotal /proc/meminfo | awk '{print $2/1024}'|awk -F. '{print $1}'`
                FREE_MEM=`grep -E -w "MemFree|Buffers|Cached" /proc/meminfo|awk '{print $2}'|awk '{s+=$1} END {print s/1024}'`
                MEM_PER=`echo "$FREE_MEM/$TOTAL_MEM*100"|bc -l|cut -d. -f1`
                echo "" >> $log_file 2>&1
                echo "======     Memory Usage   ======" >> $log_file 2>&1
                echo "Total Memory: $TOTAL_MEM MB" >> $log_file 2>&1
                echo "Free Memory: $FREE_MEM MB" >> $log_file 2>&1
                echo "Free Memory percentage: $MEM_PER%" >> $log_file 2>&1
                        if [ $MEM_PER -le 10 ]; then
                                echo "Info:" >> $log_file 2>&1
                        else
                                echo "" >> $log_file 2>&1
                                echo "Info: Memory usage on server `hostname` looks normal."  >> $log_file 2>&1
                        fi
                fi
        }

## HDD Check ##
        HDD_CHECK() {
        echo "" >> $log_file 2>&1
        echo "======     Disk Usage     ======" >> $log_file 2>&1
        df -Ph | grep -v -i -E "none|tmpfs|udev" >> $log_file 2>&1
        df -Ph | grep -vE '^Filesystem|tmpfs|cdrom|none|udev' | awk '{ print $5 " " $1 }' | while read output;
                do
                        usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
                        partition=$(echo $output | awk '{ print $2 }' )
                        if [ $usep -gt 90 ]; then
                                echo "" >> $log_file 2>&1
                                echo "Warning: $(hostname) is almost reached the disk limits \"$partition ($usep%)\"." >> $log_file 2>&1
                fi
                done
        }

## All functions call ##
        FULL_FUNC() {
                BASIC_CHECK;
                OS_CHECK;
                CPU_CHECK;
                MEM_CHECK;
                HDD_CHECK;
}
FULL_FUNC;
