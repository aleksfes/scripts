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
	echo ""
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


# Выводит в консоль заданное количество пустых строк.
# $1 - количество пустых строк, по умолчанию - 2
blank_lines() {
	local i=1;
	local lines=${1:-2}

	for ((; i<=lines; i++)); do
		echo ""
	done
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


# Отображает помощь, если передана любая непустая строка
# $1 - ожидаемая строка
show_help_if_param() {
	if [ -n "$1" ]; then
		show_help
	fi
}


# Выставляет заголовок таба, только для iTerm/tabset.
# https://github.com/jonathaneunice/iterm2-tab-set
# ВНИМАНИМЕ: если в $1 есть пробел, то отбрасывается всё, что правее этого пробела,
# а цвет таба будет сброшен на рандомный! Наверное, это бага в tabset потому,
# что средствами bash мне не удалось заставить tabset работать нормально.
# $1 - заголовок таба
tabset_title() {
	local cmd="tabset --title $1"
	if_tabset_run "$cmd"
}


# Выставляет цвет фона заголовка таба, только для iTerm/tabset.
# https://github.com/jonathaneunice/iterm2-tab-set
# $1 - цвет
tabset_color() {
	local cmd="tabset --color $1"
	if_tabset_run "$cmd"
}


# Запускает команду, если tabset установлена в системе.
# https://github.com/jonathaneunice/iterm2-tab-set
# $1 - команда
if_tabset_run() {
	if [ -n "$(which tabset)" ]; then
		run_cmd "$1"
	else
		warn "tabset is not installed, see https://github.com/jonathaneunice/iterm2-tab-set"
	fi
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


# Запуск заданной команды в заданной папке с возвратом в текущую.
# $1 - целевая папка.
# $2 - запускаемая команда.
# $3 - опциональный, описание команды
run_cmd_in_dir() {
	local targetdir="$1"
	local cmd="$2"
	local descr="$3"
	local curdir="$(pwd)"

	cd $targetdir
	run_cmd "$cmd" "$descr"

	cd $curdir
}


# Выводит заданный разделитель или пустую строку в обрамлении пустых строк.
print_divider() {
	echo ""
	echo "$1"
	echo ""
}


# Отображение переданных параметров на отдельных строках с общими отбивками в виде пустых строк.
show_msg() {
	echo ""
	for param in "$@"; do
		echo "$param"
	done
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
		ln -s $target_file $symlink
	else
		echo "make_link: file $target_file not found!"
	fi
}


# Обрезает слишком длинную строку с начала строки, оставляет конец.
# $1 - строка
# $2 - максимальная длина строки
cut_long_string_start() {
	local str=$1
	local max_length_str=$2
	# string to number conversion
	local max_length=$(($max_length_str + 0))

	if (( ${#str} > $max_length )); then
		echo "...$(echo $str | rev | cut -c 1-$max_length | rev)"
	else
		echo $str
	fi
}
