PATH = "/home/austin/Repositories/Personal"
local window_id = nil

local game_buffer = nil
local M = {}

function M.IsWindow()
  if window_id ~= nil then
    return true
  end
  return false
end

function print_args(t)
  for i, v in ipairs(t) do
    print("arguement " .. tostring(i))
    print(tostring(v))
  end
end

function M.MakeWindow()
  game_buffer     = vim.api.nvim_create_buf(true, true)
  local buf_type  = "nofile"
  local file_type = "lua"
  vim.api.nvim_buf_set_option(game_buffer, 'buftype', buf_type)
  vim.api.nvim_buf_set_option(game_buffer, 'filetype', file_type)

  vim.cmd("vsplit")
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_id, game_buffer)
  window_id = win_id
end

function M.MakeRandomCodeBuffer()
  local git_projects_job = vim.fn.jobstart(
    "ls .",
    {
      cwd = PATH,
      on_exit = function(...) end,
      on_stdout = function(jobid, data, event)
        for key, value in pairs(data) do
          new_path = PATH .. "/" .. tostring(value)
          if new_path ~= PATH then
            local git_files_job = vim.fn.jobstart(
          end
        end
      end,
      on_stderr = function(...) end,
    })
end

return M
