PATH = "/home/austin/Repositories/Personal"
local window_id = nil
local ns = vim.api.nvim_create_namespace("nvim_typr")
local ghost_text = "CmpGhostText"
local incorrect_text = "Error"
local buffer_target = {}
local extmark_table = {}

local game_buffer = nil
local M = {}

function M.IsWindow()
  if window_id ~= nil then
    return true
  end
  return false
end

function M.MakeWindow()
  game_buffer     = vim.api.nvim_create_buf(true, true)
  local buf_type  = "nofile"
  local file_type = ""
  vim.api.nvim_buf_set_option(game_buffer, 'buftype', buf_type)
  vim.api.nvim_buf_set_option(game_buffer, 'filetype', file_type)

  vim.cmd("vsplit")
  local win_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_id, game_buffer)
  window_id = win_id
end

function string:split(sub_str)
  local result = {}
  local from = 1
  local from_sub, to_sub = string.find(self, sub_str, from)
  while from_sub do
    table.insert(result, string.sub(self, from, from_sub - 1))
    from = to_sub + 1
    from_sub, to_sub = string.find(self, sub_str, from)
  end
  table.insert(result, string.sub(self, from))
  return result
end

function M.SetBuffer(str)
  local lines = {}
  if type(str) == "string" then
    lines = str:split("\n")
  elseif type(str) == "table" then
    lines = str
  end
  if game_buffer == nil then
    return
  end
  local num_lines = vim.api.nvim_buf_line_count(game_buffer)
  vim.api.nvim_buf_set_lines(game_buffer, 0, num_lines + 1, false, lines)
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
  local n = math.random(#file_list)
  local file_path = file_list[n]
  local new_text_lines = {}
  local read_file_job = vim.fn.jobstart(
    "cat " .. file_path, {
      on_stdout = function(jobid, data, evt)
        for _, value in pairs(data) do
          local new_text = tostring(value)
          table.insert(new_text_lines, new_text)
        end
      end
    })
  vim.fn.jobwait({ read_file_job })
  buffer_target = new_text_lines
end

function update_state()
  local current_text = vim.api.nvim_buf_get_lines(
    game_buffer, 0, -1, false
  )

  for i = 1, #current_text do
    local target_line = buffer_target[i]
    local actual_line = current_text[i]
    for pos = 1, #actual_line do
      local target_char = target_line[pos]
      local actual_char = actual_line[pos]
      local remaining_line = target_line:sub(#actual_line + 1, -1)
      local ext_id = extmark_table[i]
      vim.api.nvim_buf_del_extmark(game_buffer, ns, ext_id)
      extmark_table[i] = vim.api.nvim_buf_set_extmark(
        game_buffer,
        ns, i - 1,
        #actual_line, {
          virt_text = { { remaining_line, ghost_text } },
          virt_text_pos = 'overlay'
        }
      )
    end
  end
end

function M.StartGame()
  M.MakeRandomCodeBuffer()
  local new_buffer = {}
  for _, line in pairs(buffer_target) do
    table.insert(new_buffer, "")
  end
  M.SetBuffer(new_buffer)
  local i = 1
  for _, line in pairs(buffer_target) do
    extmark_table[i] = vim.api.nvim_buf_set_extmark(game_buffer, ns, i - 1, 0, {
      virt_text = { { line, ghost_text } },
      virt_text_pos = 'overlay'
    })
    i = i + 1
  end
  vim.api.nvim_create_autocmd("TextChangedI", {
    buffer = game_buffer,
    callback = update_state
  })
end

return M
