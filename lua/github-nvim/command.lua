local M = {}

local function create_command(command_name, func, desc)
  vim.api.nvim_create_user_command(
    command_name,
    func,
    { desc = desc }
  )
end

M.create_command = create_command

return M
