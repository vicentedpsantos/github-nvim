# GitHub-Nvim

A lightweight Neovim plugin to deal with Github shenanigans. One of the core principles of this plugin is that it will **never add a dependency**, keeping things as light and simple as possible.

## Requirements

- Neovim 0.7+ (with Lua support)
- A GitHub-hosted repository with a properly configured `origin` remote.
- A web browser (accessible via `xdg-open`, `open`, or `start` commands).

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

Add the following configuration to your Lazy.nvim setup:

```lua
{
  "vicentedpsantos/github-nvim",
  config = function()
    require('github-nvim')

    -- Normal mode mappings
    vim.keymap.set("n", "<leader>gho", ":OpenGitHub<cr>", { desc = "Open GitHub repository page of current repo." })
    vim.keymap.set("n", "<leader>ghf", ":OpenGitHubFile<cr>", { desc = "Open GitHub page of current repo at current file." })
    vim.keymap.set("n", "<leader>ghl", ":OpenGitHubFileLine<cr>", { desc = "Open GitHub page of current repo at current file and line." })
    vim.keymap.set("n", "<leader>ghc", ":CopyGitHubFileLine<cr>", { desc = "Copy GitHub URL of current file and line to clipboard." })

    -- Visual mode mappings
    vim.keymap.set("v", "<leader>ghl", ":OpenGitHubFileLine<cr>", { desc = "Open GitHub page of current repo at current file at current range." })
    vim.keymap.set("v", "<leader>ghc", ":CopyGitHubFileLine<cr>", { desc = "Copy GitHub URL of current file and range to clipboard." })
  end
}
```

## Usage

### Commands

1. **`:OpenGitHub`**
   - Opens the repository page in your browser.

2. **`:OpenGitHubFile`**
   - Opens the currently edited file on GitHub at the current branch or commit.

3. **`:OpenGitHubFileLine`**
   - Opens the currently edited file on GitHub at the current branch or commit and scrolls to the selected line(s).
   - In Normal Mode, targets only the current line.
   - In Visual Mode, targets the selected range of lines.

4. **`:CopyGitHubFileLine`**
   - Copies the GitHub URL for the current file and line(s) to the system clipboard.
   - In Normal Mode, targets only the current line.
   - In Visual Mode, targets the selected range of lines.

## Notes

- Make sure your repository has an `origin` remote pointing to GitHub.
- The plugin automatically detects the current branch or commit hash for the file link.
- Detached HEAD states will use the commit hash instead of a branch name. 

Enjoy seamless navigation between your code and GitHub!
