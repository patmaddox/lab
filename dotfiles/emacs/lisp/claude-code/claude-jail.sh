#!/bin/sh

# Forward CLAUDE_ENV_* variables into the jail, stripping the
# prefix.  CLAUDE_ENV_FOO=bar causes FOO=bar to be set inside
# the jail.  This works around doas/jexec dropping the caller's
# environment.

_env_fwd=" CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1"
_nl='
'
_oldifs="$IFS"
IFS="$_nl"
for _line in $(env); do
	case "$_line" in
	CLAUDE_ENV_*=*) _env_fwd="${_env_fwd} ${_line#CLAUDE_ENV_}" ;;
	esac
done
IFS="$_oldifs"

if [ -n "${_env_fwd}" ]; then
	_env_fwd="env${_env_fwd}"
fi

exec doas jexec -l -d "$(pwd)" -U "$(whoami)" claude \
    ${_env_fwd} /usr/local/bin/claude "$@"
