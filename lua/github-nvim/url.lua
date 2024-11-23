local M = {}

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

M.parse_github_url = parse_github_url

return M
