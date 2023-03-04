# Методы для работы с TG-BOT_API
# Публичные методы в самом конце.

# --------------
# PRIVATE - в этой секции идут приватные функции, их лучше не вызывать снаружи!
# --------------

# Проверяем, что в системе установлена нужная нам утилита.
# PRIVATE
assertUtil() {
	local util="$1"
	which $util > /dev/null
	if [[ ! "$?" -eq "0" ]]; then
		echo "Please, install '$util'."
		exit 911
	fi
}

# См. urlencode ниже.
assertUtil jq


# Для всех обёрток над tg-API используем стандартные параметры:
# PRIVATE
# $1 - метод, в рамках которого идёт проверка
# $2 - bot-token
# $3 - chat-id
assertCommonParams() {
	local method=$1
	local token=$2
	local chatid=$3

	if [[ -z "$token" ]]; then
		tsEcho "$method: please, provide TG bot token."
		exit 998
	fi
	if [[ -z "$chatid" ]]; then
		tsEcho "$method: please, provide TG chat ID."
		exit 997
	fi
}

# См. https://core.telegram.org/bots/api#authorizing-your-bot и дальше
# Считаем, что сюда приходят уже валидные параметры.
# PRIVATE
# $1 - bot-token
# $2 - chat-id
# $3 - метод в TG-API
# $4 - query string без chat_id
callTgAPI() {
	local METHOD="$3"
	local QUERY="$4"
	local URL="https://api.telegram.org/bot${1}/${3}?chat_id=${2}&${QUERY}"

	# dev-test purpose
	# tsEcho $URL

	local API_CALL_OUTPUT=$(wget -O - "$URL" 2>&1)
	local CALL_IS_200=$(echo "$API_CALL_OUTPUT" | grep "200 OK" | wc -l)

	if [[ "$CALL_IS_200" -eq "0" ]]; then
		tsEcho "$API_CALL_OUTPUT"
		exit 921
	fi
}

# Делает url encode заданной строки.
# ВНИМАНИЕ: требуется установленный jq!
# PRIVATE
# $1 - text to url encode
urlencode() {
	jq -rn --arg x "$1" '$x|@uri'
}

# Делает url encode для заданной пары имя/значение параметра.
# PRIVATE
# $1 - имя параметра
# $2 - значение параметра
urlencodeParam() {
	local name=$(urlencode "$1")
	local value=$(urlencode "$2")
	echo "${name}=${value}"
}


# --------------
# PUBLIC - наконец-то ты добрался до публичных методов! Используй их на радость себе!
# --------------


# Делает echo, но с timestamp
# PRIVATE
tsEcho() {
	echo $(date --rfc-3339=seconds) $*
}


# Отправляет сообщение в чат от лица бота.
# https://core.telegram.org/bots/api#sendmessage
# $1 - bot-token
# $2 - chat-id
# $3 - text
sendMessage() {
	assertCommonParams sendMessage "$1" "$2"
	local text=$(urlencodeParam text "$3")
	local query=${text}
	callTgAPI "$1" "$2" "sendMessage" "$query"
}
