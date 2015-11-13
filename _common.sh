#
# Набор общих функций для всех скриптов.
#

# До подключения этого скрипта нужно определить переменные:
# PROG="${0##*/}"
# HELP="..." - вывод справки о скрипте.


# Вывод сообщения об ошибке в канал ошибок.
# $1 - сообщение об ошибке.
show_error() {
	echo -e "ERROR: $1" >&2
}


# Вывод сообщения об ошибке с выходом из программы с кодом 1.
# $1 - сообщение об ошибке.
error() {
	show_error "$@"
	exit 1
}


# Вывод сообщения об ошибке, показ help и выход из программы с кодом 1.
# $1 - сообщение об ошибке.
error_and_help() {
	help
	echo ""
	error "$1"
}


# Вывод сообщения об ошибке - неизвестный ключ вызова скрипта.
error_unknown_option() {
	error "unknown script option!"
}


# Вывод предупреждения.
# $1 - текст предупреждения.
warn() {
	echo "WARNING: $1"
}


# Отображаем помощь.
help() {
	echo "$HELP"
}


# Отображаем помощь и произвольное сообщение, а затем выходим с кодом 0.
# $1 - текст сообщения, опциональный.
show_help() {
	# show message
	if [ -n "$1" ]; then
		echo "$1"
		echo ""
	fi

	help

	exit 0
}


# Запуск заданной команды с выводом описания.
# $1 - запускаемая команда.
# $2 - опциональный, описание команды.
run_cmd() {
	local cmd="$1"
	local descr="$2"

	echo "..."
	if [ -n "$descr" ]; then
		echo "$descr ..."
	else
		echo "Running command:"
	fi
	echo "  $cmd"
	echo "..."

	# Оставить выполнение команды последней, чтобы после run_cmd
	# можно было проверить статус выхода!
	$cmd
}


# Отображение сообщения стандартным методом - с пустыми отбивками.
# $1 - текст сообщения.
show_msg() {
	local msg="$1"

	echo ""
	echo "$msg"
	echo ""
}


# Выводим описание начавшегося процесса.
# $1 - описание процесса.
start_msg() {
	local task_descr="$1"

	show_msg "$task_descr ..."
}


# Выводим описание завершившегося процесса.
# $1 - описание процесса.
complete_msg() {
	local task_descr="$1"

	show_msg "$task_descr [COMPLETE]"
}


# Делаем паузу.
# $1 - длительность паузы в секундах, по умолчанию - 1 секунда.
my_wait() {
	local sleep_period="${1:-1}"

	show_msg "... wait (${sleep_period}) or exit (Ctrl + C) ..."

	sleep $sleep_period
}


# Запускаем нужный синхронный процесс и делаем паузу после его остановки.
# $1 - описание процесса
# $2 - команда для запуска процесса
start_process() {
	local msg="$1"
	local cmd="$2"

	# Запускаем нужный процесс.
	start_msg "$msg"
	$cmd
	complete_msg "$msg"
}


# Убивает все дочерние процессы заданного процессса.
# http://stackoverflow.com/questions/392022/best-way-to-kill-all-child-processes
# $1 - обязательный, pid основного процесса.
# $2 - опциональный, сигнал, посылаемый процессу при убийстве, по умолчанию - 9
kill_child_processes() {
	local _pid=$1
	local _sig=${2:-9}

	for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
		kill_process_tree ${_child} ${_sig}
	done
}


# Убивает процесс и все его дочерние процессы.
# http://stackoverflow.com/questions/392022/best-way-to-kill-all-child-processes
# $1 - обязательный, pid основного процесса.
# $2 - опциональный, сигнал, посылаемый процессу при убийстве, по умолчанию - 9
kill_process_tree() {
	local _pid=$1
	local _sig=${2:-9}

	# needed to stop quickly forking parent from producing children between child
	# killing and parent killing
	sudo kill -stop ${_pid}

	kill_child_processes ${_pid} ${_sig}

	sudo kill -${_sig} ${_pid}
}


# Проверяет статус завершения последней команды и выходит с заданной ошибкой,
# если команда завершилась с неожиданным статусом.
# $1 - обязательный, текст сообщения об ошибке.
# $2 - опциональный, ожидаемый статус завершения команды, по умолчанию - 0.
check_cmd_status() {
	local status="$(echo $?)"
	local err_msg="${1}"
	local expected_status="${2:-0}"

	if [ "${status}" != "${expected_status}" ]; then
		error "${err_msg} (exit code: ${status})"
	fi
}


# Установка симлинка на заданный целевой файл.
# $1 - путь к целевому файлу.
# $2 - путь к устанавливаемомоу симлинку.
make_link () {
	local target_file=$1
	local symlink=$2

	# Создаём симлинк только, если есть целевой файл.
	if [ -f $target_file -o -d $target_file ]; then
		# Если на месте симлинка уже что-то лежит, то удаляем это.
		if [ -f $symlink -o -d $symlink ]; then
			rm -rf $symlink
		fi
		# Создаём симлинк.
		ln -sfT $target_file $symlink
	else
		echo "make_link: file $target_file not found!"
	fi
}
