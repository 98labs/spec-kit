# Testing Your spec-kit Fork Locally

This guide explains how to test your forked spec-kit changes locally without affecting the globally installed version.

## The Problem You Had

When you ran `specify-dev init`, it was downloading templates from the **upstream GitHub repository**, not using your local fork's modified files.

## The Solution

We added a `--local` flag to `specify-dev init` that copies templates from your local fork instead of downloading from GitHub.

## Quick Start

```bash
# 1. Install your fork as specify-dev
cd /pathtoyourdirectory
./install-dev.sh

# 2. Activate the virtual environment
source .venv-dev/bin/activate

# 3. Run automated tests
./test-fork.sh

# 4. Test manually with --local flag (IMPORTANT!)
specify-dev init my-test-project --ai claude --local
cd my-test-project

# 5. Verify your changes are loaded
cat .specify/scripts/create-new-feature.sh | grep "branch-name"
# You should see your --branch-name flag implementation

# 6. Test conventional branching
bash .specify/scripts/create-new-feature.sh --branch-name "feat/test-feature" "test feature"
git branch  # Should show feat/test-feature

# 7. When done, deactivate
deactivate
```

**Important**: Always use the `--local` flag when testing your fork! This ensures you're using your modified templates and scripts instead of downloading from GitHub.

## Why You Need `--local` Flag

Without `--local`:

- ❌ Downloads templates from GitHub upstream repository
- ❌ Uses the official release version
- ❌ Your local changes are ignored

With `--local`:

- ✅ Copies templates from your local fork directory
- ✅ Uses YOUR modified scripts and templates
- ✅ Perfect for testing before pushing to GitHub

## What Changed in Your Fork

### 1. Added `specify-dev` Command

Modified `pyproject.toml` to add a development command entry point:

```toml
[project.scripts]
specify = "specify_cli:main"
specify-dev = "specify_cli:main"  # NEW - for testing fork
```

This allows you to install and use `specify-dev` alongside the global `specify` installation.

### 2. Installation Script (`install-dev.sh`)

Creates a virtual environment and installs your fork in editable mode:

- Creates `.venv-dev/` directory
- Installs the package with `pip install -e .`
- Makes `specify-dev` command available within the venv

### 3. `--local` Flag Support

Added `--local` flag to `specify-dev init` command:

- When used, copies templates from your local fork instead of downloading from GitHub
- Essential for testing your changes before pushing
- Uses the `copy_local_template()` function instead of `download_and_extract_template()`

**Code changes:**

- **`src/specify_cli/__init__.py`**:
  - Added `copy_local_template()` function (line 744-848)
  - Added `--local` flag to `init()` command (line 907)
  - Modified init logic to use local templates when `--local` is set (line 1075-1081)

### 4. Test Script (`test-fork.sh`)

Comprehensive test suite that validates:

- Project initialization with `specify-dev --local`
- Conventional branch naming (feat/, fix/, enhc/, etc.)
- Custom branch names via `--branch-name` flag
- Main/master branch protection
- Backward compatibility with numeric format (001-\*)
- Script permissions

## Manual Testing

After running `./install-dev.sh` and activating the venv, you can manually test your changes:

### Test Project Initialization

```bash
# IMPORTANT: Always use --local flag to test your fork's changes
specify-dev init test-project --ai claude --local
cd test-project
```

### Test Conventional Branch Creation

```bash
# Test with custom branch name
bash .specify/scripts/create-new-feature.sh --branch-name "feat/landing-page" "create landing page"

# Test interactive mode (will prompt for branch name)
bash .specify/scripts/create-new-feature.sh "create login page"

# Verify branch was created
git branch
```

### Test Different Branch Types

```bash
# These should all work
git checkout -b feat/new-feature
git checkout -b fix/bug-fix
git checkout -b enhc/enhancement
git checkout -b hotfix/urgent
git checkout -b chore/dependency-update

# These should fail (main/master protection)
git checkout main
bash .specify/scripts/setup-plan.sh  # Should show error
```

### Test Full Workflow with Claude Code

```bash
# Initialize a test project (use --local to test your fork!)
specify-dev init test-workflow --ai claude --local
cd test-workflow

# Start Claude Code
claude

# In Claude Code, test the commands:
/speckit.specify Build a simple todo app
# When prompted, test the conventional branch naming
```

## Automated Tests

Run the full test suite:

```bash
./test-fork.sh
```

This will:

1. Create a temporary test directory
2. Initialize a project with `specify-dev --local`
3. Run all branch naming tests
4. Verify branch protection works
5. Check backward compatibility
6. Clean up automatically

## Common Commands

```bash
# Initialize with local templates (ALWAYS USE THIS FOR TESTING!)
specify-dev init my-project --ai claude --local

# Check what version you're using
which specify-dev  # Should show .venv-dev/bin/specify-dev

# Verify your changes are loaded
cat test-project/.specify/scripts/create-new-feature.sh | grep "branch-name"

# Deactivate when done
deactivate
```

## Your Fork Changes

Your fork includes these modifications to support conventional branching:

### `scripts/bash/common.sh`

- Relaxed branch naming validation
- Now allows feat/, fix/, enhc/, hotfix/, chore/, release/ prefixes
- Still blocks main/master branches

### `scripts/bash/create-new-feature.sh`

- Added `--branch-name` flag for custom branch names
- Interactive prompt asks user to confirm or customize branch name
- Supports both conventional (feat/_) and numeric (001-_) formats

### `templates/commands/specify.md`

- Documents conventional branching convention
- Prompts user to confirm auto-generated branch names
- Links to conventional branching specification

## Comparison

| Command                    | Source          | Use Case                      |
| -------------------------- | --------------- | ----------------------------- |
| `specify init`             | GitHub releases | Production use                |
| `specify-dev init`         | GitHub releases | Same as above (no local flag) |
| `specify-dev init --local` | **YOUR FORK**   | **Testing your changes**      |

| Feature       | `specify` (global)    | `specify-dev` (fork)             |
| ------------- | --------------------- | -------------------------------- |
| Installation  | `uv tool install`     | `./install-dev.sh`               |
| Location      | System-wide           | Virtual environment              |
| Activation    | Always available      | Requires venv activation         |
| Changes       | Upstream version      | Your local fork                  |
| Branch naming | Numeric only (001-\*) | Conventional (feat/\*) + Numeric |

## Troubleshooting

### `specify-dev: command not found`

Make sure you've activated the virtual environment:

```bash
source .venv-dev/bin/activate
```

You should see `(.venv-dev)` in your prompt.

### Tests Failing

Check that you've installed the dev version:

```bash
./install-dev.sh
```

### Changes Not Appearing

Make sure you're using the `--local` flag:

```bash
specify-dev init test-project --ai claude --local  # ✓ Correct
specify-dev init test-project --ai claude          # ✗ Wrong - downloads from GitHub
```

### Want to Test Without Installation

You can run the Python module directly:

```bash
python3 -m specify_cli init test-project --ai claude --local
```

## Before Pushing to GitHub

1. Run the full test suite:

   ```bash
   source .venv-dev/bin/activate
   ./test-fork.sh
   ```

2. Test manually with a real project:

   ```bash
   specify-dev init real-test --ai claude --local
   cd real-test
   # Test the full workflow with Claude Code
   ```

3. Test manually with Claude Code to ensure the full workflow works

4. Check your changes:

   ```bash
   git status
   git diff
   ```

5. Verify your changes work:

   - ✅ Check that conventional branches are created correctly
   - ✅ Test the `--branch-name` flag
   - ✅ Verify the prompt asks for branch name confirmation
   - ✅ Ensure backward compatibility with numeric format (001-\*)

6. Consider adding this testing setup to `.gitignore`:
   ```bash
   echo ".venv-dev/" >> .gitignore
   ```

## Next Steps

Once you've validated your changes work correctly:

1. Commit your changes:

   ```bash
   git add -A
   git commit -m "feat: add conventional branch naming support"
   ```

2. Push to your fork:

   ```bash
   git push origin feat/conventional-branch
   ```

3. Create a pull request to the upstream repository

## Clean Up

To remove the development environment:

```bash
# Deactivate if active
deactivate

# Remove virtual environment
rm -rf .venv-dev
```

The global `specify` command remains unaffected.

## Summary

- **Without `--local`**: Downloads from GitHub (upstream) - ❌ Your changes ignored
- **With `--local`**: Uses your local modified files - ✓ Perfect for testing

**Always use `specify-dev init --local` when testing your fork!**
