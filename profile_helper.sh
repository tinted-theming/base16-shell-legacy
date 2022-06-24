#!/usr/bin/env bash

if [ -z "$BASE16_SHELL" ]; then
  if [ -n "$BASH_VERSION" ]; then
    script_path=${BASH_SOURCE[0]}
  elif [ -n "$ZSH_VERSION" ]; then
    script_path=${(%):-%x}
  fi

  BASE16_SHELL=${script_path%/*}
fi

_base16()
{
  local script=$1
  local theme=$2
  [ -f "$script" ] && . $script
  ln -fs "$script" "$HOME/.base16_theme"
  if [ -e "$HOME/.tmux/plugins/base16-tmux" ]; then echo -e "set -g \0100colors-base16 '$theme'" >| ~/.tmux.base16.conf; fi;
  if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}

if [ -n "$BASE16_DEFAULT_THEME" ] \
  && [ ! -e "$HOME/.base16_theme" ]; then
  ln -s \
    "$BASE16_SHELL_PATH/scripts/base16-$BASE16_DEFAULT_THEME.sh" \
    "$HOME/.base16_theme"
fi

if [ -e "$HOME/.base16_theme" ]; then
  . "$HOME/.base16_theme"
fi

# Set base16_* aliases
for script in "$BASE16_SHELL"/scripts/base16*.sh; do
  script_name=${script##*/}
  script_name=${script_name%.sh}
  theme=${script_name#*-}
  func_name="base16_${theme}"
  alias $func_name="_base16 \"${script}\" ${theme}"
done;

alias reset="command reset && [ -f $HOME/.base16_theme ] && . $HOME/.base16_theme"
