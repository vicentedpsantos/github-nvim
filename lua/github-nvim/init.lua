local M = {}

local function get_repo_url()
  local handle = io.popen("git config --get remote.origin.url 2>/dev/null")
  if not handle then
    return nil, "Failed to execute git command"
  end

  local result = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if result == "" then
    return nil, "No repository found"
  end
  return result
end

local function parse_github_url(repo_url)
  local patterns = {
    "https://github%.com/(.+)/(.+)%.git",
    "git@github%.com:(.+)/(.+)%.git"
  }

  for _, pattern in ipairs(patterns) do
    local owner, repo = repo_url:match(pattern)
    if owner and repo then
      return string.format("https://github.com/%s/%s", owner, repo)
    end
  end

  return nil, "Failed to parse GitHub URL"
end

local function get_repo_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not handle then
    return nil, "Failed to get repository root"
  end

  local result = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if result == "" then
    return nil, "Not a git repository"
  end
  return result
end

local function get_branch_or_commit()
  local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null || git rev-parse HEAD 2>/dev/null")
  if not handle then
    return nil, "Failed to get branch or commit"
  end

  local result = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  if result == "" then
    return nil, "Failed to resolve branch or commit"
  end
  return result
end

local function get_relative_file_path(repo_root)
  local filepath = vim.fn.expand("%:p")
  return filepath:sub(#repo_root + 2)
end

local function open_url(url)
  vim.notify("Opening " .. url, vim.log.levels.INFO)

  local open_command = nil
  if vim.fn.has("mac") == 1 then
    open_command = "open '" .. url .. "'"
  elseif vim.fn.has("unix") == 1 then
    open_command = "xdg-open '" .. url .. "'"
  elseif vim.fn.has("win32") == 1 then
    open_command = "start " .. url
  end

  if open_command then
    os.execute(open_command)
  else
    vim.notify("Platform not supported for opening URLs", vim.log.levels.ERROR)
  end
end

local function copy_to_clipboard(text)
  local clipboard_command = nil
  if vim.fn.has("mac") == 1 then
    clipboard_command = "echo '" .. text .. "' | pbcopy"
  elseif vim.fn.has("unix") == 1 then
    clipboard_command = "echo '" .. text .. "' | xclip -selection clipboard"
  elseif vim.fn.has("win32") == 1 then
    clipboard_command = "echo " .. text .. " | clip"
  end

  if clipboard_command then
    os.execute(clipboard_command)
    vim.notify("Copied to clipboard: " .. text, vim.log.levels.INFO)
  else
    vim.notify("Platform not supported for clipboard copy", vim.log.levels.ERROR)
  end
end

local function build_github_file_url(include_line)
  local repo_url, err = get_repo_url()
  if not repo_url then
    return nil, err
  end

  local github_url, parse_err = parse_github_url(repo_url)
  if not github_url then
    return nil, parse_err
  end

  local repo_root, root_err = get_repo_root()
  if not repo_root then
    return nil, root_err
  end

  local branch_or_commit, branch_err = get_branch_or_commit()
  if not branch_or_commit then
    return nil, branch_err
  end

  local relative_file_path = get_relative_file_path(repo_root)
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
  open_url(file_url)
end

function M.open_current_file_on_github_with_line()
  local file_url, err = build_github_file_url(true)
  if not file_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end
  open_url(file_url)
end

function M.copy_current_file_url_with_line()
  local file_url, err = build_github_file_url(true)
  if not file_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end
  copy_to_clipboard(file_url)
end

function M.open_github_repo()
  local repo_url, err = get_repo_url()
  if not repo_url then
    vim.notify("Error: " .. err, vim.log.levels.ERROR)
    return
  end

  local github_url, parse_err = parse_github_url(repo_url)
  if not github_url then
    vim.notify("Error: " .. parse_err, vim.log.levels.ERROR)
    return
  end

  open_url(github_url)
end

vim.api.nvim_create_user_command(
  "OpenGitHub",
  M.open_github_repo,
  { desc = "Open the GitHub repository of the current project" }
)

vim.api.nvim_create_user_command(
  "OpenGitHubFile",
  M.open_current_file_on_github,
  { desc = "Open the current file on GitHub" }
)

vim.api.nvim_create_user_command(
  "OpenGitHubFileLine",
  M.open_current_file_on_github_with_line,
  { desc = "Open the current file on GitHub at the current line" }
)

vim.api.nvim_create_user_command(
  "CopyGitHubFileLine",
  M.copy_current_file_url_with_line,
  { desc = "Copy the current file URL on GitHub with line to the clipboard" }
)

return M
