#!/bin/bash
# Установка скриптов и настроек на текущий хост
PROG="${0##*/}"
HELP="no need"

# get 'scripts' folder absolute path - cross platform way
START_PWD=$(pwd)
cd $(dirname $0)
SCRIPTS=$(pwd -P)
cd $START_PWD

sc_home=$SCRIPTS/home

# Shell'ом по умолчанию может быть не bash, поэтому детектируем наличие source
# и вызываем его, если есть, в противном случае используем команду "точка" (.).
common_lib=${SCRIPTS}/lib/_common.sh
(which source > /dev/null) && source $common_lib || . $common_lib

cd ~
real_home=$(pwd -P)
cd $START_PWD
me=$(whoami)


# functions

# start
echo "Installation ..."


# Добавляем ссылку на свои дополнения к bashrc.
bashrc_my="source $sc_home/bashrc"
if [ -z "`grep \"$bashrc_my\" $real_home/.bashrc`" ]; then
  echo "" >> $real_home/.bashrc
  echo "$bashrc_my" >> $real_home/.bashrc
  echo "" >> $real_home/.bashrc
  echo ".bashrc configured."
fi


# .inputrc
make_link $sc_home/inputrc $real_home/.inputrc
echo ".inputrc installed."


# .vim
make_link $sc_home/vim $real_home/.vim
echo ".vim installed."

# .vimrc
make_link $sc_home/vimrc $real_home/.vimrc
echo ".vimrc installed."

# .tmux.conf
make_link $sc_home/tmux.conf $real_home/.tmux.conf
echo ".tmux.conf installed."

# tern npm install
vim_tern_folder=$sc_home/vim/bundle/tern_for_vim
if [ -d $vim_tern_folder ]; then
	run_cmd_in_dir $vim_tern_folder "npm install" "Installing TernJS ..."
	echo "TernJS installed."
fi


# git settings

# Ставим свой gitconfig.
# Так как на работе и дома я использую разные email,
# то конфиг копируем с изменением нужных настроек.

# Читаем из заданного git-конфига поле email,
# чтобы не заставлять себя вводить этот email каждый раз.
get_git_email() {
	local git_config=$1
	local email=$(egrep -o "email = \S+" $git_config | head -n 1 | egrep -o "\S+$")
	echo $email
}

git_custom_config=$real_home/.gitconfig
git_reference_config=$sc_home/gitconfig

# Но сначала достаём из местного конфига используемый email.
git_custom_email=""
if [ -f $git_old_config ]; then
	git_custom_email="$(get_git_email $git_custom_config)"
fi

# Если кастомный email совпадает с референсным, то не спрашиваем ни о чём.
git_reference_email="$(get_git_email $git_reference_config)"
if [ "$git_reference_email" = "$git_custom_email" ]; then
	git_custom_email=""
fi

# Чтобы использовать email из местного конфига я просто должен нажать Enter,
# так будет проще запускать install.sh в будущем.
if [ -n "$git_custom_email" ]; then
	echo "Please, input anything to prevent using custom email (${git_custom_email}):"
	read confirmation
	if [ -n "$confirmation" ]; then
		git_custom_email=""
	fi
fi

# Копируем конфиг.
rm -f $git_custom_config
cp -f $git_reference_config $git_custom_config
echo ".gitconfig installed."

# Вставляем кастомный email на место.
if [ -n "$git_custom_email" ]; then
	sed -i -e "s/email = .*/email = ${git_custom_email}/g" $git_custom_config
	echo "Custom email (${git_custom_email}) installed to .gitconfig."
fi



# finish
echo "Installation ... [COMPLETE]"
