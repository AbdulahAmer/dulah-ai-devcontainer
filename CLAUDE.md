# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Guidance

- Ignore GEMINI.md and GEMINI-\*.md files
- To save main context space, for code searches, inspections, troubleshooting or analysis, use code-searcher subagent where appropriate - giving the subagent full context background for the task(s) you assign it.
- After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
- For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.
- Before you finish, please verify your solution
- Do what has been asked; nothing more, nothing less.
- NEVER create files unless they're absolutely necessary for achieving your goal.
- ALWAYS prefer editing an existing file to creating a new one.
- NEVER proactively create documentation files (\*.md) or README files. Only create documentation files if explicitly requested by the User.
- When you update or modify core context files, also update markdown documentation and memory bank
- When asked to commit changes, include .claude directory, CLAUDE.md and CLAUDE-\*.md referenced memory bank system files from any commits. Never delete these files.

## Memory Bank System

This project uses a structured memory bank system with specialized context files. Always check these files for relevant information before starting work:

### Core Context Files

- **CLAUDE-activeContext.md** - Current session state, goals, and progress (if exists)
- **CLAUDE-patterns.md** - Established code patterns and conventions (if exists)
- **CLAUDE-decisions.md** - Architecture decisions and rationale (if exists)
- **CLAUDE-troubleshooting.md** - Common issues and proven solutions (if exists)
- **CLAUDE-config-variables.md** - Configuration variables reference (if exists)
- **CLAUDE-temp.md** - Temporary scratch pad (only read when referenced)

**Important:** Always reference the active context file first to understand what's currently being worked on and maintain session continuity.

## Git Safety Protocol

This project implements a git workflow safeguard system to prevent accidental data loss and ensure code quality.

### Branch Protection System

**Pre-commit Hook Enforcement:**
- Direct commits to `main`/`master` branches are **technically blocked** by git hook
- Hook runs automatically on every commit attempt
- Provides guidance on creating feature branches
- Can be bypassed with `--no-verify` (not recommended)

**Workflow Requirements:**

**STEP 0: Pre-Work Sync Check (MANDATORY)**

Before creating any new branch or starting work, ALWAYS ensure master is up-to-date:

```bash
# 1. Switch to master (if not already there)
git checkout master

# 2. Fetch latest changes from remote (safe, doesn't merge)
git fetch origin

# 3. Check sync status
git status
```

**Interpret status and take action:**

- ✅ `"Your branch is up to date with 'origin/master'"` → **Proceed to step 1 below**

- ⚠️ `"Your branch is behind 'origin/master' by X commits"` → **Pull first:**
  ```bash
  git pull origin master
  # Verify: git status  # Should now show "up to date"
  ```

- ⚠️ `"Your branch and 'origin/master' have diverged"` → **Resolve divergence:**
  ```bash
  # Option 1: If you have no local commits on master, force update
  git reset --hard origin/master

  # Option 2: If you have local commits, merge or rebase
  git pull origin master  # Creates merge commit
  # OR
  git rebase origin/master  # Replays your commits on top
  ```

**Why this matters:** Ensures your feature branch is based on the latest code, preventing work on outdated master and reducing future merge conflicts.

**Only after master is up-to-date**, proceed with the workflow below:

Before ANY destructive operation (rm, major refactors, rewrites):

1. **Verify clean state:** Run `git status` - must show clean working tree or committed changes
2. **Create feature branch:** Use descriptive naming:
   - `feature/description` - for new features
   - `fix/description` - for bug fixes
   - `session/YYYYMMDD-HHMM-description` - for session-based work
   - `refactor/description` - for refactoring work
3. **Confirm branch:** Run `git branch --show-current` - must NOT be main/master
4. **Proceed with changes** - now safe to make destructive edits
5. **Commit frequently:** After each logical unit of work
6. **Use git-pr-helper skill:** When ready to create PR or merge

**NEVER:**
- Delete files while on main/master branch
- Run `rm -rf` without verifying you're on a feature branch
- Skip commits during long refactors
- Force-push to main/master
- Bypass pre-commit hook without explicit user request

**If you need to abandon work:**
- `git stash` - preserve uncommitted changes
- `git reset --hard origin/main` - discard all local changes (WARNING: destructive)
- Always verify with user before discarding work

### PR and Merge Workflow

When work is complete and ready for review:

1. **Invoke git-pr-helper skill** - provides comprehensive PR assistance
2. **Generate PR description** - skill analyzes commits and creates quality description
3. **Run safety checks** - verify tests pass, no conflicts with base branch
4. **Create PR** - using `gh pr create` or skill workflow
5. **Merge after review** - skill guides merge strategy (regular, squash, rebase)
6. **Clean up branches** - skill helps identify and remove old branches

**When to use git-pr-helper skill:**
- User asks: "Create a PR", "Merge my work", "Ready to submit"
- When creating pull requests from feature branches
- When resolving merge conflicts
- When cleaning up old session/feature branches
- When recovering from git mistakes

**The skill CANNOT and will NOT:**
- Prevent file deletion before commits (hook handles this)
- Auto-create branches at session start (follow workflow above)
- Enforce policies (hook handles enforcement)

### Safety Stack

This project uses a defense-in-depth approach:

1. **Layer 1 - Git Hook (Technical Enforcement):** Blocks commits to main/master automatically
2. **Layer 2 - CLAUDE.md Instructions (Guidance):** This protocol guides safe workflows
3. **Layer 3 - git-pr-helper Skill (Workflow Assistance):** Helps with PR/merge operations
4. **Layer 4 - Docker Volumes (Data Persistence):** Configs survive container rebuilds
5. **Layer 5 - User Review (Final Check):** Never merge without user confirmation

### Hook Reinstallation

Git hooks are in `.git/hooks/` and are NOT committed to the repository. After cloning or container rebuilds:

```bash
# Reinstall hooks
bash /workspaces/claude-devcontainer/.devcontainer/setup-git-hooks.sh
```

Or add to `devcontainer.json` `postStartCommand` for automatic installation.

## Project Overview

This is a devcontainer infrastructure project for multi-AI development environments, focused on secure, production-ready configurations for Claude Code, OpenAI Codex CLI, and Google Gemini CLI.

## Session Start Hook

This project includes an automatic environment check hook that runs at the start of each Claude Code session.

### What It Does

**When running IN devcontainer:**
- ✅ Confirms devcontainer environment detection
- 📦 Shows container hostname
- 💾 Verifies mounted volumes (`.claude`, `.codex`, `.gemini`, `.aws`, etc.)
- 🔌 Lists configured MCP servers from `mcp.json`
- 🛠️ Checks tool availability (claude, codex, gemini, gh, docker, aws, uv)
- 🌐 Displays network configuration and OpenTelemetry endpoint
- 📁 Shows current workspace and git branch
- ⚠️ Warns if on main/master branch (suggests feature branches)

**When running OUTSIDE devcontainer:**
- ⚠️ Displays warning that environment is not devcontainer
- 📋 Provides instructions to open project in devcontainer
- ✅ Allows session to continue (non-blocking)

### How It Works

1. **Template**: `.devcontainer/session-start.sh.template` (baked into container image)
2. **Deployment**: Copied to `.claude/hooks/session-start.sh` on first container creation by `init-claude-hooks.sh`
3. **Configuration**: Referenced in `settings.json` via `hooks.sessionStart.command`
4. **Execution**: Runs automatically when Claude Code session starts

### Customization

The hook is copied to your workspace and can be customized:

```bash
# Edit the hook
code .claude/hooks/session-start.sh

# Make it executable if needed
chmod +x .claude/hooks/session-start.sh
```

Changes persist across container rebuilds (workspace is mounted volume).

### Disabling the Hook

To disable, edit `/home/node/.claude/settings.json` and remove the `hooks` section, or comment out the command:

```json
{
  "hooks": {
    "sessionStart": {
      "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh"
    }
  }
}
```

See [Claude Cookbooks - Session Hooks](https://github.com/anthropics/claude-cookbooks/tree/main/skills/.claude/hooks) for more examples.

## Claude Code Skills

This project includes specialized skills for managing devcontainer operations, documentation, and git workflows:

### Development Skills

- **git-pr-helper** - Git workflow assistance for PR creation, branch management, merge coordination, and conflict resolution

### When to Use Skills

Claude will automatically invoke these skills when you:
- Configure firewall or MCP servers → `devcontainer-manager`
- Update llms.txt or generate docs → `llms-txt-manager`
- Update HTML guide sections → `html-guide-manager`
- Check documentation consistency → `cross-doc-linker`
- Create PR, merge branches, or resolve conflicts → `git-pr-helper`

### Skill Integration

- Use `ai-cross-verifier` to validate complex changes with Codex + Gemini
- All skills follow project commit conventions and update memory bank files

## ALWAYS START WITH THESE COMMANDS FOR COMMON TASKS

**Task: "List/summarize all files and directories"**

```bash
fd . -t f           # Lists ALL files recursively (FASTEST)
# OR
rg --files          # Lists files (respects .gitignore)
```

**Task: "Search for content in files"**

```bash
rg "search_term"    # Search everywhere (FASTEST)
```

**Task: "Find files by name"**

```bash
fd "filename"       # Find by name pattern (FASTEST)
```

### Directory/File Exploration

```bash
# FIRST CHOICE - List all files/dirs recursively:
fd . -t f           # All files (fastest)
fd . -t d           # All directories
rg --files          # All files (respects .gitignore)

# For current directory only:
ls -la              # OK for single directory view
```

### BANNED - Never Use These Slow Tools

- ❌ `tree` - NOT INSTALLED, use `fd` instead
- ❌ `find` - use `fd` or `rg --files`
- ❌ `grep` or `grep -r` - use `rg` instead
- ❌ `ls -R` - use `rg --files` or `fd`
- ❌ `cat file | grep` - use `rg pattern file`

### Use These Faster Tools Instead

```bash
# ripgrep (rg) - content search
rg "search_term"                # Search in all files
rg -i "case_insensitive"        # Case-insensitive
rg "pattern" -t py              # Only Python files
rg "pattern" -g "*.md"          # Only Markdown
rg -1 "pattern"                 # Filenames with matches
rg -c "pattern"                 # Count matches per file
rg -n "pattern"                 # Show line numbers
rg -A 3 -B 3 "error"            # Context lines
rg " (TODO| FIXME | HACK)"      # Multiple patterns

# ripgrep (rg) - file listing
rg --files                      # List files (respects •gitignore)
rg --files | rg "pattern"       # Find files by name
rg --files -t md                # Only Markdown files

# fd - file finding
fd -e js                        # All •js files (fast find)
fd -x command {}                # Exec per-file
fd -e md -x ls -la {}           # Example with ls

# jq - JSON processing
jq. data.json                   # Pretty-print
jq -r .name file.json           # Extract field
jq '.id = 0' x.json             # Modify field
```

### Search Strategy

1. Start broad, then narrow: `rg "partial" | rg "specific"`
2. Filter by type early: `rg -t python "def function_name"`
3. Batch patterns: `rg "(pattern1|pattern2|pattern3)"`
4. Limit scope: `rg "pattern" src/`

### INSTANT DECISION TREE

```
User asks to "list/show/summarize/explore files"?
  → USE: fd . -t f  (fastest, shows all files)
  → OR: rg --files  (respects .gitignore)

User asks to "search/grep/find text content"?
  → USE: rg "pattern"  (NOT grep!)

User asks to "find file/directory by name"?
  → USE: fd "name"  (NOT find!)

User asks for "directory structure/tree"?
  → USE: fd . -t d  (directories) + fd . -t f  (files)
  → NEVER: tree (not installed!)

Need just current directory?
  → USE: ls -la  (OK for single dir)
```
