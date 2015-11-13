#!/bin/bash

# Сокращённый вызов diff'а с направлением ответа в less

PROG=${0##*/}

### Хелп

show_help() {
  echo "$PROG - shortcut for sending diff to less"
  echo "Usage:"
  echo "  $PROG file-src file-dst"
  echo "  $PROG folder-src folder-dst"
  exit 0
}

### Параметры

src=$1
dst=$2

if [ -z "$src" -o -z "$dst" ]; then
  show_help
fi

### Actions

cmd_output="less"

# определяем сравнение файлов
if [ -f "$src" -a -f "$dst" ]; then
  diff "$src" "$dst" | less
else
  # определяем сравнение каталогов
  if [ -d "$src" -a -d "$dst" ]; then
    # -N - рассматривает отсутствующие файлы как пустые
    # -r - рекурсивный обход директорий
    # -q - не выводит дифф между файлами, только сообщение
    # -y - вывод в две колонки (?)
    diff -N -r -q -y --exclude="CVS" --exclude=".git" "$src" "$dst" | $cmd_output
  # неправильные параметры
  else
    echo "ERROR: \"$src\" or \"$dst\" are not looking at file/folder!!!"
    show_help
  fi
fi
