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

# Ставим свой gitconfig
make_link $cfg_folder/gitconfig $home_folder/.gitconfig
echo ".gitconfig installed."


# finish
echo "Installation ... [COMPLETE]"
