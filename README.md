# skillful

Miscellaneous QOL (Quality of Life) Claude Skills - A hybrid marketplace and plugin for productivity improvements.

## What is this?

**skillful** is both a Claude Code marketplace AND a plugin in one. It contains curated skills, commands, and agents to enhance your development workflow with Claude Code.

## Installation

You can install skillful in two ways:

### Option 1: Via Marketplace (Recommended)

Add the marketplace, then install the plugin:

```bash
/plugin marketplace add hlibkoval/skillful
/plugin install skillful@skillful
```

### Option 2: Direct Plugin Installation

Install directly as a plugin:

```bash
/plugin install hlibkoval/skillful
```

Both methods give you access to all skills, commands, and agents included in skillful.

## What's Included

- **Skills** (`skills/`) - Model-invoked capabilities that Claude activates automatically
- **Commands** (`commands/`) - User-invoked slash commands (e.g., `/skillful:command-name`)
- **Agents** (`agents/`) - Specialized agent definitions for specific tasks

### Available Skills

#### GitLab (`skills/gitlab/`)

Comprehensive GitLab workflow automation using the `glab` CLI tool. Automatically activated when working with GitLab repositories.

**Features:**
- Merge request creation and management (create, review, approve, merge)
- Issue tracking and project management
- CI/CD pipeline monitoring and debugging
- Release management
- Multi-instance support (GitLab.com and self-managed)
- Authentication verification and troubleshooting
- GitLab Duo AI integration

**Bundled Resources:**
- `references/glab-commands.md` - Comprehensive command reference
- `references/workflows.md` - Step-by-step workflow guides
- `scripts/verify-glab-auth.sh` - Authentication verification script

**When it activates:**
- Creating or reviewing merge requests
- Managing GitLab issues
- Checking pipeline status
- Configuring glab authentication
- Working with GitLab releases

## Usage

After installation:

1. **Skills activate automatically** - Claude invokes them when relevant based on their descriptions
2. **Use commands explicitly** - Type `/skillful:` and press tab to see available commands
3. **Reference agents** - Use specialized agents via the Task tool when needed

## Structure

```
skillful/
├── .claude-plugin/
│   ├── marketplace.json    # Marketplace manifest (self-referencing)
│   └── plugin.json         # Plugin manifest
├── skills/                 # Agent Skills (auto-invoked by Claude)
├── commands/               # Slash commands (user-invoked)
├── agents/                 # Specialized agent definitions
└── README.md              # This file
```

## How the Hybrid Works

This repository uses a **marketplace/plugin hybrid pattern** inspired by [obra/superpowers](https://github.com/obra/superpowers):

- **marketplace.json** defines a marketplace that references itself via `"source": "./"`
- **plugin.json** defines the actual plugin with skills, commands, and agents
- Users can discover it as a marketplace OR install it directly as a plugin
- Both installation paths result in the same functionality

## Contributing

To contribute a new skill, command, or agent:

1. **For Skills**: Create a directory under `skills/` with a `SKILL.md` file
   - Include YAML frontmatter with `name` and `description`
   - See [Claude Code skills documentation](https://docs.claude.com/en/docs/claude-code/skills.md)

2. **For Commands**: Create a `.md` file under `commands/`
   - Include YAML frontmatter with `description`
   - Add command implementation

3. **For Agents**: Create a `.md` file under `agents/`
   - Include YAML frontmatter with `name`, `description`, and optional `model`
   - Add agent instructions

4. Submit a pull request with your additions

## Version

Current version: **0.0.1**

## License

MIT
