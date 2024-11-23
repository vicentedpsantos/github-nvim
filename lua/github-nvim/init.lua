local M = {}

local git = require("github-nvim.git")
local url = require("github-nvim.url")
local system = require("github-nvim.system")
local command = require("github-nvim.command")

local function build_github_file_url(include_line)
  local repo_url, err = git.get_repo_url()
  if not repo_url then
    return nil, err
  end

  local github_url, parse_err = url.parse_github_url(repo_url)
  if not github_url then
    return nil, parse_err
  end

  local repo_root, root_err = git.get_repo_root()
  if not repo_root then
    return nil, root_err
  end

  local branch_or_commit, branch_err = git.get_branch_or_commit()
  if not branch_or_commit then
    return nil, branch_err
  end

  local relative_file_path = git.get_relative_file_path(repo_root)
  if not relative_file_path or relative_file_path == "" then
    return nil, "Could not resolve the current file's path"
  end

  if include_line then
    local line_number = vim.fn.line(".")
    return string.format("%s/blob/%s/%s#L%d", github_url, branch_or_commit, relative_file_path, line_number)
  else
    return string.format("%s/blob/%s/%s", github_url, branch_or_commit, relative_file_path)
  end
end

function M.open_current_file_on_github()
  local file_url, err = build_github_file_url(false)
  if not file_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end
  system.open_url(file_url)
end

function M.open_current_file_on_github_with_line()
  local file_url, err = build_github_file_url(true)
  if not file_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end
  system.open_url(file_url)
end

function M.copy_current_file_url_with_line()
  local file_url, err = build_github_file_url(true)
  if not file_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end
  system.copy_to_clipboard(file_url)
end

function M.open_github_repo()
  local repo_url, err = git.get_repo_url()
  if not repo_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end

  local github_url, parse_err = url.parse_github_url(repo_url)
  if not github_url then
    vim.notify("Error: " .. parse_err, vim.log.levels.ERROR)
    return
  end

  system.open_url(github_url)
end

command.create_command("OpenGitHub", M.open_github_repo, "Open the GitHub repository of the current project")
command.create_command("OpenGitHubFile", M.open_current_file_on_github, "Open the current file on GitHub")
command.create_command("OpenGitHubFileLine", M.open_current_file_on_github_with_line, "Open the current file on GitHub at the current line")
command.create_command("CopyGitHubFileLine", M.copy_current_file_url_with_line, "Copy the current file URL on GitHub with line to the clipboard")

return M
