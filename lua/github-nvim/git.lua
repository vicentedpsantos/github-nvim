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

M.get_repo_url = get_repo_url
M.get_repo_root = get_repo_root
M.get_branch_or_commit = get_branch_or_commit
M.get_relative_file_path = get_relative_file_path

return M
