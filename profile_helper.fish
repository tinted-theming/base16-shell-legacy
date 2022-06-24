#!/usr/bin/env fish

# [what] provides aliases for base16 themes and sets $HOME/.base16_theme
#
# [usage] can be added to $HOME/.config/fish/config.fish like so:
#
# if status --is-interactive
#    source $HOME/.config/base16-shell/profile_helper.fish
# end
#
# TODO: maybe port to $HOME/.config/fish/functions ?


if test -z $BASE16_SHELL
  set -g BASE16_SHELL (cd (dirname (status -f)); and pwd)
end

# load currently active theme...
if test -e "$HOME/.base16_theme"
  eval sh "$HOME/.base16_theme"
end

if test -n "$BASE16_DEFAULT_THEME"; and not test -e "$HOME/.base16_theme"
  ln -s "$BASE16_SHELL/scripts/base16-$BASE16_DEFAULT_THEME.sh" \
    "$HOME/.base16_theme"
end

# set aliases, like base16_*...
for SCRIPT in $BASE16_SHELL/scripts/*.sh
  set THEME (basename $SCRIPT .sh) # eg: base16-ocean
  function $THEME -V SCRIPT -V THEME
    set partial_theme_name (string replace -a 'base16-' '' $THEME) # eg: ocean
    sh $SCRIPT
    ln -sf $SCRIPT "$HOME/.base16_theme"
    set -gx BASE16_THEME (string split -m 1 '-' $THEME)[2]
    if test -e "$HOME/.tmux/plugins/base16-tmux"
      echo "set -g @colors-base16 '$partial_theme_name'" > "$HOME/.tmux.base16.conf"
    end
    if test (count $BASE16_SHELL_HOOKS) -eq 1; and test -d "$BASE16_SHELL_HOOKS"
      for hook in $BASE16_SHELL_HOOKS/*
        test -f "$hook"; and test -x "$hook"; and "$hook"
      end
    end
  end
end

alias reset "command reset \
  && [ -f "$HOME/.base16_theme" ] \
  && sh "$HOME/.base16_theme""
