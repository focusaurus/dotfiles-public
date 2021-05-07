local module = {}
local open = io.open

local function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

function module.show(path)
  local text = read_file(path)
  hs.alert.show(text, 6)
end

return module
