-- This writes to ~/.xsession-errors
local gears_debug = require('gears.debug')
local out = gears_debug.print_warning

-- https://rrampage.github.io/2021/12/04/relearning-lua/
local function print_table(tbl)
  -- Specify function vars as local else they become global
  local s = '{'
  local fst = true
  for k, v in pairs(tbl) do
    local tk = type(k)
    local tv = type(v)
    if not fst then
      s = s .. ','
    else
      fst = false
    end

    if tk == 'number' or tk == 'boolean' then
      s = s .. '[' .. tostring(k) .. ']='
    else
      s = s .. '["' .. k .. '"]='
    end

    if tv == 'table' then
      s = s .. print_table(v)
    elseif tv == 'number' or tv == 'boolean' then
      s = s .. tostring(v)
    elseif tv == 'string' then
      s = s .. '"' .. v .. '"'
    else
      s = s .. tv
    end
  end
  s = s .. '}'
  return s
end

-- variadic log function. Pass as many things to it as you want,
-- of any type, and it will print them out
-- separated by spaces
local function log(...)
  local message = ''
  for i = 1, select('#', ...) do
    local arg = select(i, ...)
    local the_type = type(arg)
    -- gears_debug.print_warning("type: " .. the_type)
    if the_type == 'nil' then
      message = message .. 'nil'
    elseif the_type == 'boolean' then
      message = message .. tostring(arg)
    elseif the_type == 'string' or the_type == 'number' then
      message = message .. arg
    elseif the_type == 'table' then
      -- message = message .. gears_debug.dump_return(arg)
      message = message .. print_table(arg)
    end
    message = message .. ' '
  end
  out(message)
end



return log
