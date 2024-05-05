#!/bin/bash

PROG="${0##*/}"
SCRIPTS="${0%/*/*}"

PROG_DIR="${0%/*}"

HELP="
$PROG - пингует ip и ругается в tg-чат от имени бота, если сервер недоступен
Usage: $PROG PARAMS (see sources)
"

source ${SCRIPTS}/lib/_common.sh
source ${SCRIPTS}/lib/tg.sh

# --- PARAMS

IP=$1
# В этот файл будут писаться результаты некоторых пингов для отложенного разбора ситуации.
PING_LOG_FILE=$2
MQTT_TOPIC=$3
MQTT_MESSAGE=$4
MQTT_USER=$5
MQTT_PASSWORD=$6
MQTT_HOST=$7
MQTT_PORT=$8

if [[ -z "$IP" ]] || [[ -z "$MQTT_TOPIC" ]] || [[ -z "$MQTT_MESSAGE" ]] || [[ -z "$MQTT_USER" ]] \
		|| [[ -z "$MQTT_PASSWORD" ]] || [[ -z "$MQTT_HOST" ]] || [[ -z "$MQTT_PORT" ]]; then
	error_and_help "задайте параметры"
fi
if [[ ! -f $PING_LOG_FILE ]]; then
	error_and_help "создайте лог-файл"
fi

# --- PING

PING_IS_OK="PING_RESULT_OK"
PING_IS_FAILED="PING_RESULT_FAILED"

LAST_PING=$(grep -e "$PING_IS_OK" -e "$PING_IS_FAILED" $PING_LOG_FILE | tail -n 1)
# Если записей в логе нет, то считаем, что раньше сервер пинговался успешно.
# LAST_PING_IS_OK=0 - последний пинг прошёл успешно
if [[ -z "$LAST_PING" ]]; then
	LAST_PING_IS_OK=0
else
	LAST_PING_OK_FOUND=$(echo $LAST_PING | grep "$PING_IS_OK")
	LAST_PING_IS_OK=$?
fi

# Пингуем несколько раз до первого успеха, чтобы исключить случайные флапы сети.
PING_RESULT=1
NUMBER_OF_PING_TRIES=5
while [ "$PING_RESULT" != "0" ] && [ "$NUMBER_OF_PING_TRIES" != "0" ]; do
	# Нужно смотреть ping именно линуксовый потому, что на MacOS есть разница в параметрах!
	ping -c 1 -W 1 $IP > /dev/null
	PING_RESULT=$?
	NUMBER_OF_PING_TRIES=$(($NUMBER_OF_PING_TRIES - 1))
done

# dev-test purpose
#PING_RESULT=1

# --- PING RESULT HANDLING

if [[ "$PING_RESULT" -eq "0" ]]; then
	if [[ ! "$LAST_PING_IS_OK" -eq "0" ]]; then
		tsEcho "$PING_IS_OK $IP" >> $PING_LOG_FILE
	fi
else
	# При фейлах пинга логируем всегда.
	tsEcho "$PING_IS_FAILED $IP" >> $PING_LOG_FILE
	# При первом фейле пишем в тг, остальные фейлы игнорируем до следующего успеха, чтобы не спамить.
	if [[ "$LAST_PING_IS_OK" -eq "0" ]]; then
		mqttx pub -t "$MQTT_TOPIC" -m "$MQTT_MESSAGE" -h "$MQTT_HOST" -p "$MQTT_PORT" \
			-u "$MQTT_USER" -P "$MQTT_PASSWORD" > /dev/null
	fi
fi



