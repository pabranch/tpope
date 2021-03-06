# ~/.cshrc
# vim:set et sw=2:

# Common {{{1

foreach dir ( /usr/ucb /usr/local/bin /opt/local/bin /opt/sfw/bin "$HOME/.rbenv/bin" "$HOME/.rbenv/shims" "$HOME/bin" )
  if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end
foreach dir ( /usr/bin/X11 /opt/sfw/kde/bin /usr/openwin/bin /usr/dt/bin /usr/games /usr/lib/surfraw /var/lib/gems/1.9.1/bin /var/lib/gems/1.8/bin /usr/local/sbin /usr/sbin /sbin /usr/etc )
  if ( $PATH !~ *$dir* && -d "$dir" ) setenv PATH "${dir}:${PATH}"
end

if ( -f "$HOME/.locale" && ! $?LANG && ! $?LC_ALL ) then
  setenv LANG "`cat ~/.locale`"
endif

setenv ENV "$HOME/.shrc"
setenv CLASSPATH '.'
if ( -d "$HOME/.java" ) setenv CLASSPATH "${CLASSPATH}:$HOME/.java"
if ( -d "$HOME/java" )  setenv CLASSPATH "${CLASSPATH}:$HOME/java"
setenv RUBYLIB  "$HOME/src/ruby/lib:$HOME/.ruby/lib"
setenv PERL5LIB "$HOME/.perl5:$HOME/perl5:$HOME/.perl:$HOME/perl"
setenv RSYNC_RSH 'ssh -axqoBatchMode=yes'
if ( { test -t 1 } ) setenv RSYNC_RSH 'ssh -ax'

unset dir

if ( { limit maxproc 256 } ) then >&/dev/null
  limit maxproc 256 >&/dev/null
  if ($?CRON == 1) limit maxproc 128 >&/dev/null
endif

if ( $?prompt == 0 ) exit
if ( "$prompt" == "" ) exit
# }}}1
# Environment {{{1
umask 022
if ( -x /bin/stty ) stty -ixon

setenv VISUAL "$HOME/bin/sensible-editor"
setenv PAGER "$HOME/bin/sensible-pager"
setenv BROWSER "$HOME/bin/sensible-browser"
setenv LESS 'RFX#10'
if ( -x /usr/bin/lesspipe ) then
  setenv LESSOPEN '|lesspipe %s'
else
  setenv LESSOPEN '|"$HOME/.lessfilter" %s'
endif
if ( $HOST == '') set HOST = `tpope hostman`
setenv LYNX_CFG "$HOME/.lynx.cfg"

set noclobber
# }}}
# Prompt {{{1
if ( `id|sed -e 's/^uid=\([0-9]*\).*$/\1/'` == 0 ) then
  set usercolor = "01;37"
  set usercode = "+b W"
  set promptchar = "#"
else
  set usercolor = "01;33"
  set usercode = "+b Y"
  set promptchar = "%"
  if ( `id|sed -e 's/^.*gid=[0-9]*(\([^)]*\)).*/\1/'` == `id -un` ) umask 002
endif

if ( -x /usr/bin/tty || -x /usr/local/bin/tty ) then
  set ttybracket=" [`tty|sed -e s,^/dev/,,`]"
  set ttyat="`tty|sed -e s,^/dev/,,`@"
else
  set ttyat=""
  set ttybracket=""
endif

if ( $?tcsh ) then
  if ( -x "$HOME/bin/tpope" ) then
    set hostcolor = `$HOME/bin/tpope hostman ansi`
  else
    set hostcolor = `00;33`
  endif

  set prompt = "%{\e[${usercolor}m%}%n%{\e[00m%}@%{\e[${hostcolor}m%}%m%{\e[00m%}:%{\e[01;34m%}%~%{\e[00m%}%# "

  switch ($TERM)

  case screen*:
    if ( $?STY ) then
      alias precmd 'printf "\e]1;'"i${ttyat}${HOST}"'\a\e]2;'"${USER}@${HOST}"':%s'"${ttybracket}"'\a\ek'"${ttyat}"'\e\\" "`echo $cwd|sed -e s,^$HOME,~,`"'
    else
      alias precmd 'printf "\e]1;'"i${ttyat}${HOST}"'\a\e]2;'"${USER}@${HOST}"':%s'"${ttybracket}"'\a\ek'"${ttyat}${HOST}"'\e\\" "`echo $cwd|sed -e s,^$HOME,~,`"'
    endif
    breaksw

  case xterm*:
  case rxvt*:
  case Eterm*:
  case kterm*:
  case putty*:
  case dtterm*:
  case ansi*:
  case cygwin*:
    alias precmd 'printf "\e]1;'"${ttyat}${HOST}"'\a\e]2;'"${USER}@${HOST}"':%s'"${ttybracket}"'\a" "`echo $cwd|sed -e s,^$HOME,~,`"'
    breaksw

  case linux*:
    breaksw

  default:
    set prompt = "%n@%m:%~%# "
    breaksw

  endsw
else
  alias cd 'cd \!* && setprompt'
  alias chdir 'chdir \!* && setprompt'
  alias pushd 'pushd \!* && setprompt'
  alias popd  'popd  \!* && setprompt'
  alias setprompt 'set prompt = "'`id -un`@$HOST':`pwd|sed -e "s,^$HOME,~,"`'"$promptchar"' "'
  setprompt
  set history = 100
  set filec
  if ( $TERM =~ screen* || $TERM =~ vt220* ) then
      printf "\ek%s\e\\" "$ttyat$HOST"
  endif
endif

unset hostcolor usercolor usercode promptchar oldterm ttyat ttybracket
# }}}1
# Aliases {{{1
if ( -x /usr/bin/dircolors && $?tcsh ) then
  eval `/usr/bin/dircolors -c $HOME/.dir_colors`
  alias ls 'ls -hF --color=auto'
else if ( -x /usr/local/bin/dircolors && $?tcsh ) then
  eval `/usr/local/bin/dircolors -c $HOME/.dir_colors`
  alias ls 'ls -hF --color=auto'
else if ( -x /usr/bin/dircolors || -x /usr/local/bin/dircolors ) then
  alias ls 'ls -hF --color=auto'
else
  alias ls 'ls -hF'
  setenv CLICOLOR ''
  setenv LSCOLORS ExGxFxdxCxfxexCaCdEaEd
endif

grep --color |& grep unknown >/dev/null || alias grep 'grep --color=auto --exclude="*~"'

if ( -x /usr/bin/finger && -f "$HOME/.hushlogin" ) then
  /usr/bin/finger $USER | grep '^New mail' >&/dev/null && \
    echo "You have new mail."
else if ( -x /usr/ucb/finger && -f "$HOME/.hushlogin" ) then
  /usr/ucb/finger $USER | grep '^New mail' >&/dev/null && \
    echo "You have new mail."
endif

alias mv 'mv -i'
alias cp 'cp -i'

alias j 'jobs'

if ( -x /usr/bin/vim || -x /usr/local/bin/vim || -x /opt/sfw/bin/vim ) then
  alias vi 'vim'
endif

if ( -x /usr/bin/gvim || -x /usr/local/bin/gvim || -x /opt/sfw/bin/gvim ) then
  alias vi 'vim' # -X
endif

if ( `uname` == Linux ) then
  alias less 'less -R'
  alias zless 'zless -R'
endif

foreach cmd ( `tpope aliases` )
  alias $cmd "tpope $cmd"
end
# }}}1
