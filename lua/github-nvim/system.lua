local M = {}

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

M.open_url = open_url
M.copy_to_clipboard = copy_to_clipboard

return M
