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

function M.open_current_file_on_github()
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

  local repo_root, root_err = get_repo_root()
  if not repo_root then
    vim.notify("Error: " .. root_err, vim.log.levels.ERROR)
    return
  end

  local branch_or_commit, branch_err = get_branch_or_commit()
  if not branch_or_commit then
    vim.notify("Error: " .. branch_err, vim.log.levels.ERROR)
    return
  end

  local relative_file_path = get_relative_file_path(repo_root)
  if not relative_file_path or relative_file_path == "" then
    vim.notify("Error: Could not resolve the current file's path", vim.log.levels.ERROR)
    return
  end

  local file_url = string.format("%s/blob/%s/%s", github_url, branch_or_commit, relative_file_path)
  open_url(file_url)
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

return M
