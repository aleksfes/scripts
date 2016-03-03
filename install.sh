#!/bin/bash
# Установка скриптов и настроек на текущий хост
PROG="${0##*/}"
HELP="no need"

scripts_folder=$(readlink -f $0)
scripts_folder=${scripts_folder%/*}
cfg_folder=$scripts_folder/home

ssh_public_key="feoktistov_15.07.2015.ssh.public"

. ${scripts_folder}/_common.sh


home_folder=$(readlink -f ~)
me=$(whoami)


# functions

# start
echo "Installation ..."


# Добавляем ссылку на свои дополнения к bashrc.
bashrc_my="source $cfg_folder/bashrc"
if [ -z "`grep \"$bashrc_my\" $home_folder/.bashrc`" ]; then
  echo "" >> $home_folder/.bashrc
  echo "$bashrc_my" >> $home_folder/.bashrc
  echo "" >> $home_folder/.bashrc
  echo ".bashrc configured."
fi


# ssh ключ кладём каждый раз
#ssh-keygen -i -f $cfg_folder/$ssh_public_key > $home_folder/.ssh/authorized_keys
#echo "Public ssh key $ssh_public_key installed."
#chmod 600 $home_folder/.ssh/authorized_keys


# .inputrc
make_link $cfg_folder/inputrc $home_folder/.inputrc
echo ".inputrc installed."


# .vim
make_link $cfg_folder/vim $home_folder/.vim
echo ".vim installed."


# .vimrc
make_link $cfg_folder/vimrc $home_folder/.vimrc
echo ".vimrc installed."


# git settings

# Ставим свой gitconfig.
# Так как на работе и дома я использую разные email,
# то конфиг копируем с изменением нужных настроек.

# Читаем из заданного git-конфига поле email,
# чтобы не заставлять себя вводить этот email каждый раз.
get_git_email() {
	local git_config=$1
	local email=$(grep -oP "email = \S+" $git_config | head -n 1 | grep -oP "\S+$")
	echo $email
}

git_custom_config=$home_folder/.gitconfig
git_reference_config=$cfg_folder/gitconfig

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
	sed -i -e "s/email\s\+=\s\+\S\+/email = ${git_custom_email}/g" $git_custom_config
	echo "Custom email (${git_custom_email}) installed to .gitconfig."
fi



# finish
echo "Installation ... [COMPLETE]"
