# From the yolo-coding-agent package. Edit lab's
# infra/hosts/yolo/templates/coding-agent, not this file.
#
# The jail is the sandbox, so Claude Code trusts every folder in it,
# and asks nothing before it starts. Claude Code takes this only from
# the environment, not from its settings' env.
export CLAUDE_CODE_SANDBOXED=1
