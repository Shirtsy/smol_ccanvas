local function return_character_table()
    local sequence = {}
    for i = 0, 31 do
        local value = string.char(128 + i)
        local key = {0, 0, 0, 0, 0, 0}
        local n = i
        for bit = 0, 4 do
            key[bit + 1] = n % 2
            n = math.floor(n / 2)
        end
        local key_string = ""
        for _, v in pairs(key) do
            key_string = key_string .. tostring(v)
        end
        sequence[key_string] = value
    end
    return sequence
end

local character_table = return_character_table()

local inverted_character_table = {}

for k, v in pairs(character_table) do
    local new_key = ""
    for c in k:gmatch"." do
        if c == "0" then
            new_key = new_key .. "1"
        elseif c == "1" then
            new_key = new_key .. "0"
        end
    end
    inverted_character_table[new_key] = v
end

local SmolCanvas = {}
SmolCanvas.__index = SmolCanvas

function SmolCanvas.new(width, height)
    local self = setmetatable({}, SmolCanvas)
    self.char_width = width
    self.char_height = height
    self.pixel_width = width * 2
    self.pixel_height = height * 3

    -- Initialize the 2D table for the canvas
    self.pixel_grid = {}
    for x = 1, self.pixel_width do
        self.pixel_grid[x] = {}
        for y = 1, self.pixel_height do
            self.pixel_grid[x][y] = 0
        end
    end

    self.foreground = colors.white
    self.background = colors.black
    return self
end

function SmolCanvas:write_pixel(x, y, value)
    self.pixel_grid[x][y] = value
end

function SmolCanvas:draw_pixel(x, y)
    SmolCanvas:write_pixel(x, y, 1)
end

function SmolCanvas:erase_pixel(x, y)
    SmolCanvas:write_pixel(x, y, 0)
end

function SmolCanvas:write_line(x1, y1, x2, y2, value)
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    while true do
        if x1 >= 1 and x1 <= self.pixel_width and y1 >= 1 and y1 <= self.pixel_height then
            self.pixel_grid[x1][y1] = value
        end
        
        if x1 == x2 and y1 == y2 then break end
        
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x1 = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1 = y1 + sy
        end
    end
end

function SmolCanvas:draw_line(x1, y1, x2, y2)
    self:write_line(x1, y1, x2, y2, 1)
end

function SmolCanvas:erase_line(x1, y1, x2, y2)
    self:write_line(x1, y1, x2, y2, 0)
end

function SmolCanvas:write_rectangle(x1, y1, x2, y2, value)
    -- Ensure x1 <= x2 and y1 <= y2
    local startX = math.min(x1, x2)
    local endX = math.max(x1, x2)
    local startY = math.min(y1, y2)
    local endY = math.max(y1, y2)

    -- Clamp values to stay within the canvas bounds
    startX = math.max(1, math.min(startX, self.pixel_width))
    endX = math.max(1, math.min(endX, self.pixel_width))
    startY = math.max(1, math.min(startY, self.pixel_height))
    endY = math.max(1, math.min(endY, self.pixel_height))

    -- Fill the rectangle
    for x = startX, endX do
        for y = startY, endY do
            self.pixel_grid[x][y] = value
        end
    end
end

function SmolCanvas:draw_rectangle(x1, y1, x2, y2)
    self:write_rectangle(x1, y1, x2, y2, 1)
end

function SmolCanvas:erase_rectangle(x1, y1, x2, y2)
    self:write_rectangle(x1, y1, x2, y2, 0)
end

function SmolCanvas:raw_grid_to_string()
    local rows = {}
    for y = 1, self.pixel_height do
        local row = {}
        for x = 1, self.pixel_width do
            row[x] = self.pixel_grid[x][y] == 1 and "\127" or "\183"
        end
        rows[y] = table.concat(row)
    end
    return table.concat(rows, "\n")
end





local canv = SmolCanvas.new(3, 1)
local pretty = require "cc.pretty"

canv:draw_line(2,1,1,1)
print(canv:raw_grid_to_string())

return SmolCanvas