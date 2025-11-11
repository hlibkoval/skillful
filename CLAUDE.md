# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**skillful** is a hybrid Claude Code marketplace and plugin that provides Quality of Life (QOL) skills, commands, and agents for productivity improvements. It uses a self-referencing marketplace pattern where the repository acts as both a marketplace and plugin simultaneously.

## Architecture

### Hybrid Marketplace/Plugin Pattern

This repository implements a unique dual-identity pattern:

1. **marketplace.json** declares a marketplace that references itself via `"source": "./"`
2. **plugin.json** defines the plugin with its metadata
3. Users can either:
   - Add as marketplace (`/plugin marketplace add hlibkoval/skillful`) then install (`/plugin install skillful@skillful`)
   - Install directly as plugin (`/plugin install hlibkoval/skillful`)
4. Both installation paths provide identical functionality

**Key insight**: The marketplace "owns" the plugin by self-referencing, allowing users to discover it as either a marketplace OR a plugin.

### Directory Structure

```
skillful/
├── .claude-plugin/
│   ├── marketplace.json    # Self-referencing marketplace manifest
│   └── plugin.json         # Plugin metadata (author, version, keywords)
├── skills/                 # Agent Skills (Claude auto-invokes based on descriptions)
│   └── <skill-name>/
│       ├── SKILL.md       # Required: YAML frontmatter + markdown instructions
│       ├── references/    # Optional: Detailed docs loaded on-demand
│       ├── scripts/       # Optional: Executable helpers
│       └── assets/        # Optional: Templates, files used in output
├── commands/              # Slash commands (user-invoked via /skillful:command-name)
│   └── <command>.md       # YAML frontmatter + command implementation
└── agents/                # Specialized agent definitions
    └── <agent>.md         # YAML frontmatter + agent instructions
```

### Skill Architecture Pattern

Skills follow the **progressive disclosure** pattern from the skill-creator framework:

1. **SKILL.md** (~2-3k words): Core instructions with YAML frontmatter
   - `name`: Skill identifier
   - `description`: Critical for Claude's invocation decision (when to use this skill)
   - Markdown body: High-level workflows and guidance

2. **references/** (optional): Detailed documentation loaded as needed
   - Keep SKILL.md lean by moving detailed references here
   - Claude loads these files only when required
   - Examples: API docs, schemas, command references, workflow guides

3. **scripts/** (optional): Executable code for deterministic operations
   - Use when code is repeatedly rewritten or needs determinism
   - Token-efficient (can execute without reading into context)
   - Examples: Authentication checks, file processors

4. **assets/** (optional): Files used in output, not loaded into context
   - Templates, boilerplate, images, fonts
   - Copied or modified during skill execution
   - Examples: HTML templates, React boilerplate, brand assets

## Working with Skills

### Creating a New Skill

1. **Create directory structure**:
   ```bash
   mkdir -p skills/<skill-name>/{references,scripts,assets}
   ```

2. **Write SKILL.md** with proper frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Use when <specific trigger conditions>. Describe what this skill does and when Claude should invoke it.
   ---
   ```

3. **Follow imperative/infinitive writing style**:
   - Use verb-first instructions: "To accomplish X, do Y"
   - NOT second person: "You should do X"
   - Objective, instructional language for AI consumption

4. **Use relative paths** for bundled resources:
   - ✅ `scripts/verify-auth.sh`
   - ✅ `cat references/commands.md`
   - ❌ `/Users/username/path/to/file`

5. **Keep SKILL.md lean** (~2-3k words):
   - Move detailed documentation to `references/`
   - Move reusable code to `scripts/`
   - Move templates/assets to `assets/`

### Skill Description Best Practices

The `description` field in YAML frontmatter determines when Claude invokes the skill:

- **Be specific** about trigger conditions
- **Use third person**: "Use when..." not "Use this when..."
- **Mention key technologies/tools**: Include names like "glab CLI", "GitLab", etc.
- **Describe scenarios**: "when creating MRs, managing issues, checking pipelines"
- **Highlight unique capabilities**: "authentication verification and instance detection"

Example:
```yaml
description: Use when working with GitLab repositories (cloud or self-managed) - provides workflows for creating MRs, managing issues, checking pipelines, and using glab CLI correctly, including authentication verification and instance detection
```

### Resource Organization Guidelines

- **SKILL.md**: When to use skill, core workflows, references to bundled resources
- **references/**: Command syntax, API docs, detailed workflow steps, schemas
- **scripts/**: Authentication verification, file transformations, validation
- **assets/**: HTML/React templates, configuration files, images

Avoid duplication: Information should live in SKILL.md OR references/, not both.

## File Conventions

### Path References

All paths in SKILL.md and reference files must be **relative to the skill directory**:

```bash
# ✅ Correct (relative paths)
scripts/verify-glab-auth.sh
cat references/workflows.md
assets/template.html

# ❌ Wrong (absolute paths)
/Users/username/Projects/skillful/skills/gitlab/scripts/verify-glab-auth.sh
```

### Executable Scripts

Scripts in `scripts/` directories should be:
- Made executable: `chmod +x scripts/<script>.sh`
- Include proper shebang: `#!/usr/bin/env bash` or `#!/usr/bin/env python3`
- Return proper exit codes for success/failure
- Provide helpful error messages

## Version Management

Current version: **0.0.2** (defined in both plugin.json and marketplace.json)

When updating versions:
1. Update `version` in `.claude-plugin/plugin.json`
2. Update `version` and `plugins[0].version` in `.claude-plugin/marketplace.json`
3. Keep both files synchronized

## Git Workflow

Standard git workflow applies. When committing skills:

```bash
git add skills/<skill-name>/
git commit -m "Add <skill-name> skill for <purpose>

<detailed description of what the skill does>"
git push
```

## Discovery and Auto-Loading

- **Skills**: Auto-discovered from `skills/` directory based on SKILL.md presence
- **Commands**: Auto-discovered from `commands/` directory
- **Agents**: Auto-discovered from `agents/` directory
- **No explicit registration needed**: Files in these directories are automatically available

Claude Code scans these directories and loads resources based on naming conventions and frontmatter metadata.

## Current Skills

### Claude Code (`skills/claude-code/`)

Comprehensive Claude Code CLI and configuration assistant.

**Structure**:
- `SKILL.md` - Core capabilities overview with practical examples
- `references/cli-reference.md` - Complete CLI commands and flags reference
- `references/mcp-servers.md` - MCP server configuration and examples
- `references/configuration.md` - Settings files with executable bash examples
- `references/plugins-and-skills.md` - Plugin and skill development guides
- `references/hooks.md` - Hook system patterns and examples
- `references/troubleshooting.md` - Common issues and solutions
- `references/best-practices.md` - Recommended workflows and optimization

**Key patterns demonstrated**:
- Capabilities-based structure for integrated systems
- Actionable configuration (executable bash commands)
- Comprehensive reference documentation (~20k words)
- Self-configuration capability (Claude configuring itself)

**Activation triggers**: Claude Code CLI questions, configuration, MCP servers, plugins, skills, hooks, troubleshooting

### GitLab (`skills/gitlab/`)

Comprehensive GitLab workflow automation using glab CLI.

**Structure**:
- `SKILL.md` - Main skill with authentication and workflow guidance
- `references/glab-commands.md` - Exhaustive command reference
- `references/workflows.md` - Step-by-step workflow guides
- `scripts/verify-glab-auth.sh` - Authentication verification script

**Key patterns demonstrated**:
- Progressive disclosure (lean SKILL.md, detailed references)
- Executable troubleshooting script
- Multi-instance support documentation
- Workflow-oriented organization

**Activation triggers**: GitLab MRs, issues, CI/CD pipelines, authentication, releases

## Contributing

When adding new skills, commands, or agents:

1. **Follow existing patterns**: Study the GitLab skill structure
2. **Use relative paths**: No absolute local paths in documentation
3. **Write for Claude**: Use imperative/infinitive form, not second person
4. **Keep it lean**: Progressive disclosure pattern (SKILL.md → references → scripts/assets)
5. **Test thoroughly**: Ensure scripts are executable and paths work from skill directory
6. **Document in README.md**: Add a section under "Available Skills"

## Official Documentation

When working with this repository, consult these Claude Code documentation resources:

- **[Skills](https://docs.claude.com/en/docs/claude-code/skills.md)** - Consult when creating or modifying SKILL.md files, understanding YAML frontmatter requirements, or organizing bundled resources
- **[Plugins](https://docs.claude.com/en/docs/claude-code/plugins.md)** - Consult when modifying plugin.json, understanding plugin structure, or changing how the plugin is discovered and installed
- **[Plugin Marketplaces](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces.md)** - Consult when modifying marketplace.json, understanding the self-referencing pattern, or changing marketplace configuration
- **[Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference.md)** - Consult for complete schema definitions, validation rules, and technical specifications for plugin and marketplace manifests

## License

MIT License - See repository root for full license text.
