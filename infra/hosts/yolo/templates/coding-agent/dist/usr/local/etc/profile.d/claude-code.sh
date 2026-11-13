# From the yolo-coding-agent package. Edit lab's
# infra/hosts/yolo/templates/coding-agent, not this file.
#
# The jail is the sandbox, so Claude Code trusts every folder in it,
# and asks nothing before it starts. Claude Code takes this only from
# the environment, not from its settings' env.
export CLAUDE_CODE_SANDBOXED=1

# bypassPermissions mode still asks before an rm whose target it cannot
# resolve, such as one in a shell variable, or a whole directory such
# as home. With nobody to answer, the session stops. The jail holds
# nothing to lose, so let them run. This too comes only from the
# environment.
export CLAUDE_CODE_EVEN_MORE_DANGEROUSLY_SKIP_PERMISSIONS=1

# Claude Code keeps .claude.json beside ~/.claude, not in it, so it
# would miss the dataset that yolo mounts there to outlive a reset.
# Pointing CLAUDE_CONFIG_DIR at ~/.claude keeps it inside. Only the
# agent's, as root's home has no such mount.
if [ "$(id -un)" = agent ]; then
	export CLAUDE_CONFIG_DIR=/home/agent/.claude
fi
