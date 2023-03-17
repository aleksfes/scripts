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

# PARAMS
IP=$1
# Человеко-понятное имя хоста, которое будет прописано в сообщении в ТГ.
IP_ALIAS=$2
BOT_TOKEN=$3
CHAT_ID=$4
# В этот файл будут писаться результаты некоторых пингов для отложенного разбора ситуации.
PING_LOG_FILE=$5

if [[ -z "$IP" ]] || [[ -z "$IP_ALIAS" ]] || [[ -z "$BOT_TOKEN" ]] || [[ -z "$CHAT_ID" ]]; then
	error_and_help "задайте параметры"
fi
if [[ ! -f $PING_LOG_FILE ]]; then
	error_and_help "создайте лог-файл"
fi

HOST_NAME="openvpn-server"

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

ping -c 1 -W 1 $IP > /dev/null
PING_RESULT=$?

# dev-test purpose
#PING_RESULT=1

if [[ "$PING_RESULT" -eq "0" ]]; then
	# Если сервер поднялся, то пишем об этом в чат.
	if [[ ! "$LAST_PING_IS_OK" -eq "0" ]]; then
		tsEcho "$PING_IS_OK $IP" >> $PING_LOG_FILE
		MSG="Ура! Сервер $IP_ALIAS ($IP) вновь доступен с ${HOST_NAME}!"
		sendMessage "$BOT_TOKEN" "$CHAT_ID" "$MSG"
	fi
else
	# При фейлах пинга логируем всегда.
	tsEcho "$PING_IS_FAILED $IP" >> $PING_LOG_FILE
	# При первом фейле пишем в тг, остальные фейлы игнорируем до следующего успеха, чтобы не спамить.
	if [[ "$LAST_PING_IS_OK" -eq "0" ]]; then
		MSG="Сервер $IP_ALIAS ($IP) недоступен с ${HOST_NAME} :("
		sendMessage "$BOT_TOKEN" "$CHAT_ID" "$MSG"
	fi
fi



