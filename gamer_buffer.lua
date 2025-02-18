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

local function print_args(t)
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

function string:endswith(ending)
  return ending == "" or self:sub(- #ending) == ending
end

local file_list = {}
local function getGitFiles(path)
  if string.match(path, "llama") then
    return
  end
  local git_files_job = vim.fn.jobstart(
    "git ls-files",
    {
      cwd = path,
      on_exit = function() end,
      on_stdout = function(jobid, data, event)
        for key, value in pairs(data) do
          local file_name = tostring(value)
          if file_name == "" or
              file_name:endswith(".otf")
              or file_name:endswith(".toml")
              or file_name:endswith(".json")
              or file_name:endswith(".lock")
              or file_name:endswith(".mod")
              or file_name:endswith(".sum")
              or file_name:endswith(".uuid")
              or file_name:endswith("config")
              or file_name:endswith(".md")
              or file_name:endswith("i3blocks")
              or file_name:endswith("ssh_config")
              or file_name:endswith(".gitignore")
          then
          else
            local new_path = path .. "/" .. file_name
            table.insert(file_list, new_path)
          end
        end
      end,
      on_stderr = function(...) end,
    })
  return git_files_job
end

function M.MakeRandomCodeBuffer()
  local open_jobs = {}
  local main_jobs = {}
  local git_projects_job = vim.fn.jobstart(
    "ls .",
    {
      cwd = PATH,
      on_exit = function(...) end,
      on_stdout = function(jobid, data, event)
        for key, value in pairs(data) do
          local p_name = tostring(value)
          local new_path = PATH .. "/" .. p_name
          if p_name ~= "" then
            local job = getGitFiles(new_path)
            if job ~= nil then
              print(new_path .. " => " .. job)
              table.insert(open_jobs, job)
            end
          end
        end
      end,
      on_stderr = function(...) print("Get all projects error") end,
    })
  table.insert(main_jobs, git_projects_job)
  vim.fn.jobwait(main_jobs)
  vim.fn.jobwait(open_jobs)
  for _, file in pairs(file_list) do
    print(file)
  end
end

return M
