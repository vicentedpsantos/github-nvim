local M = {}

local function create_command(command_name, func, opts)
  vim.api.nvim_create_user_command(
    command_name,
    func,
    { desc = opts.desc or "", range = opts.range or false }
  )
end

M.create_command = create_command

return M
