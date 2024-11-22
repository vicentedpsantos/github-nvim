local M = {}

local function get_repo_url()
  local handle = io.popen("git config --get remote.origin.url 2>/dev/null")
  if not handle then
    return nil, "Failed to execute git command"
  end

  local result = handle:read("*a"):gsub("%s+$", "") -- Remove trailing whitespace
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

local function open_url(url)
  local open_command = nil
  if vim.fn.has("unix") == 1 then
    open_command = "xdg-open '" .. url .. "'"
  elseif vim.fn.has("mac") == 1 then
    open_command = "open '" .. url .. "'"
  elseif vim.fn.has("win32") == 1 then
    open_command = "start " .. url
  end

  if open_command then
    os.execute(open_command)
  else
    vim.notify("Platform not supported for opening URLs", vim.log.levels.ERROR)
  end
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

return M
