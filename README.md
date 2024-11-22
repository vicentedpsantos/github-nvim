# GitHub-Nvim

A lightweight Neovim plugin to deal with Github shenanigans.

## Features

- **Open Repository**: Quickly navigate to your project's GitHub repository homepage.
- **Open Current File**: Open the current file on GitHub at the active branch or commit.

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
        require('github_open')
    end
}
```

## Usage

### Commands

1. **`:OpenGitHub`**
   - Opens the repository page in your browser.

2. **`:OpenGitHubFile`**
   - Opens the currently edited file on GitHub at the current branch or commit.

## Notes

- Make sure your repository has an `origin` remote pointing to GitHub.
- The plugin automatically detects the current branch or commit hash for the file link.
- Detached HEAD states will use the commit hash instead of a branch name. 

Enjoy seamless navigation between your code and GitHub!
