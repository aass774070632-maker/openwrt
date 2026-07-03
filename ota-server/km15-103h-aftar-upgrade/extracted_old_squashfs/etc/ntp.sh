#!/bin/sh  
#                                 
# script file to start ntp client

NTP_TIMEZONE="$1"
NTP_SERVER_IP1="$2"
NTP_SERVER_IP2="$3"
SUCCESS_SLEEP="$4"
NTP_INIT_FLAG="$5"

NTPTMP=/var/tmp/ntp_tmp
NTPTMP_2=/var/tmp/ntp_ctime
NTP_SUCCESS=/var/tmp/ntp_success
NTP_SERVER_ID=0

SERVER_COUNT=2
SERVER_RETRY_COUNT=3
RETRY_SLEEP=30
RETRY_LIMIT=5
FAIL_SLEEP=600
#SUCCESS_SLEEP=43200

# sleep 시간. mcr-ntpclient 시작부터 고정되도록 감산
# 현재 shell에서 expr 이 곱셈이 안 됨.
AR_CNT=$#
[ $AR_CNT -gt 1 ] &&  RETRY_SLEEP=`expr $RETRY_SLEEP - $RETRY_LIMIT`
[ $AR_CNT -gt 2 ] &&  RETRY_SLEEP=`expr $RETRY_SLEEP - $RETRY_LIMIT`

killall -q mcr-ntpclient 2> /dev/null

###########kill sleep that ntp.sh created###############
TMPFILEDL=/tmp/tmpfiledl
line=0

# RETRY_SLEEP 변수가 가변이라서 그냥 숫자로 처리함.
# ps | grep "sleep[ ]*[$RETRY_SLEEP|$FAIL_SLEEP|$SUCCESS_SLEEP]" > $TMPFILEDL
ps | grep "sleep[ ]*[20|25|30|$FAIL_SLEEP|$SUCCESS_SLEEP]" > $TMPFILEDL
echo 0 > /proc/zq_mcr_secure_policy
line=`cat $TMPFILEDL | wc -l`
num=1
while [ $num -le $line ];
do
	pat0=` head -n $num $TMPFILEDL | tail -n 1`
	pat1=`echo $pat0 | cut -f1 -dS`  
	pat2=`echo $pat1 | cut -f1 -d " "`  
	kill -9 $pat2 2> /dev/null
	num=`expr $num + 1`
done
echo 1 > /proc/zq_mcr_secure_policy
rm -f /tmp/tmpfiledl 2> /dev/null

###########################
if [ "$NTP_INIT_FLAG" = "1" ]; then
	rm /etc/localtime
	ln -s /etc/Seoul /etc/localtime
	sleep 20
fi

# echo Start NTP daemon
while [ true ];
do
	if [ "$NTP_TIMEZONE" = "" ]; then
		NTP_TIMEZONE="KST-009"
	fi
	echo $NTP_TIMEZONE > /tmp/tmpTZ
	sed -e 's#.*_\(-*\)0*\(.*\)#GMT-\1\2#' /tmp/tmpTZ > /tmp/tmpTZ2
	sed -e 's#\(.*\)--\(.*\)#\1\2#' /tmp/tmpTZ2 > /etc/TZ
	rm -rf /tmp/tmpTZ
	rm -rf /tmp/tmpTZ2

	num1=1
	while [ $num1 -le $RETRY_LIMIT ];
	do
		num2=1
		while [ $num2 -le $SERVER_COUNT ];
		do
			if [ $NTP_SERVER_ID = 0 ];then
				ntpserver=$NTP_SERVER_IP1
				NTP_SERVER_ID=1
			else
				ntpserver=$NTP_SERVER_IP2
				NTP_SERVER_ID=0
			fi

#			echo "NTP: $ntpserver try ....[$num1-`date '+%H:%M:%S'`]"
			# 서버 당, 5초 단위로 $SERVER_RETRY_COUNT 회 반복
			echo "" > $NTPTMP

# Start.2010.03.23 higherd 
# 시험팀 요청에 의해서, 변경
#	 mcr-ntpclient -c $SERVER_RETRY_COUNT -s -h $ntpserver -i 5 > $NTPTMP
#
#			mcr-ntpclient -c 1 -s -h $ntpserver -i 5 > /dev/null &
#			mcr-ntpclient -c 1 -s -h $ntpserver -i 5 > /dev/null &
			mcr-ntpclient -c 1 -s -h $ntpserver -i 5 > $NTPTMP
# 2개는 버림.
# End.2010.03.23
			if [ $? = 0 ]; then
				echo 0 > /proc/zq_mcr_secure_policy
				if [ -n "`cat $NTPTMP`" ];then
					echo ntp client success
					success=1
					CUR_TIME=`date "+%Y %m %d %H %M %S"`
					echo $CUR_TIME > $NTPTMP_2
					echo 1 > /proc/zq_mcr_secure_policy
					break
				else
					success=0
				fi
				echo 1 > /proc/zq_mcr_secure_policy
			else
				success=0
			fi
			num2=`expr $num2 + 1`
		done
		num1=`expr $num1 + 1`
		if [ $success = 0 ] ;then
			sleep $RETRY_SLEEP
		fi
		[ $success -eq 1 ] && break;
	done
		
	if [ $success = 1 ] ;then
		echo 1 > /proc/sys/vm/drop_caches
		NTP_STRING="NTP_SUCCESS"
		echo $NTP_STRING > $NTP_SUCCESS
		sleep $SUCCESS_SLEEP 
	else
		NTP_STRING="NTP_FAIL"
		echo $NTP_STRING > $NTP_SUCCESS
		sleep $FAIL_SLEEP
	fi
done &
