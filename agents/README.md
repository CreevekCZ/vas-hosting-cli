# Agent Skills

This directory contains skill files that teach AI coding agents how to use the `vash` CLI.
Copy the relevant file into your project to give your agent full knowledge of every command.

## Claude Code

Copy `claude-code/vash.md` into your project's `.claude/commands/` directory:

```sh
mkdir -p .claude/commands
curl -o .claude/commands/vash.md \
  https://raw.githubusercontent.com/CreevekCZ/vas-hosting-cli/main/agents/claude-code/vash.md
```

Then invoke it in Claude Code with `/vash`.
