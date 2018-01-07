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
show_diff=$3

if [ -z "$src" -o -z "$dst" ]; then
  show_help
fi

### Actions

diff_cmd="diff"
show_result="less"

has_colordiff="$(which colordiff)"
if [ -n "$has_colordiff" ]; then
  diff_cmd="colordiff"
fi

# определяем сравнение файлов
if [ -f "$src" -a -f "$dst" ]; then
  diff "$src" "$dst" | ${show_result}
else
  # определяем сравнение каталогов
  if [ -d "$src" -a -d "$dst" ]; then
    # -N - рассматривает отсутствующие файлы как пустые
    # -r - рекурсивный обход директорий
    # -q - не выводит дифф между файлами, только сообщение
    # -y - вывод в две колонки (?)
    # -c - вывод нескольких соседних строк для контекста
    diff_options="-N -r -c"
    if [ -z "$show_diff" ]; then
      diff_options="${diff_options} -q"
    fi
    ${diff_cmd} ${diff_options} --exclude="CVS" --exclude=".git" "$src" "$dst" | ${show_result}
  # неправильные параметры
  else
    echo "ERROR: \"$src\" or \"$dst\" are not looking at file/folder!!!"
    show_help
  fi
fi
