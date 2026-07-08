#!/bin/sh

# Forward CLAUDE_ENV_* variables into the jail, stripping the
# prefix.  CLAUDE_ENV_FOO=bar causes FOO=bar to be set inside
# the jail.  This works around doas/jexec dropping the caller's
# environment.

_env_fwd=" CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1 CLAUDE_CODE_DISABLE_AGENT_VIEW=1"
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

# Pick the jail by working directory. Sessions started under ~/evirts
# run in the evirts-claude jail; everything else uses the default
# claude jail.
_jail=claude
case "$(pwd)" in
"${HOME}"/evirts | "${HOME}"/evirts/*) _jail=evirts-claude ;;
esac

exec doas jexec -l -d "$(pwd)" -U "$(whoami)" "${_jail}" \
    ${_env_fwd} /usr/local/bin/claude "$@"
