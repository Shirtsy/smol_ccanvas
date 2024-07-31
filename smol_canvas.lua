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

function SmolCanvas:set_foreground_color(color)
    self.foreground = color
end

function SmolCanvas:set_background_color(color)
    self.background = color
end

function SmolCanvas:fill_canvas()
    for x = 1, self.pixel_width do
        for y = 1, self.pixel_height do
            self.pixel_grid[x][y] = 1
        end
    end
end

function SmolCanvas:erase_canvas()
    for x = 1, self.pixel_width do
        for y = 1, self.pixel_height do
            self.pixel_grid[x][y] = 0
        end
    end
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
    
    for i = 1, 500 do
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

function SmolCanvas:get_canvas_blit()
    local characters_blit = ""
    local foreground_blit = ""
    local background_blit = ""
    for char_y = 1, self.char_height do
        for char_x = 1, self.char_width do
            local pixel_start_x = (char_x - 1) * 2 + 1
            local pixel_start_y = (char_y - 1) * 3 + 1
            
            local char_pixels = ""
            for y = 0, 2 do
                for x = 0, 1 do
                    char_pixels = char_pixels .. tostring(self.pixel_grid[pixel_start_x + x][pixel_start_y + y])
                end
            end
            
            if character_table[char_pixels] then
                characters_blit = characters_blit .. character_table[char_pixels]
                foreground_blit = foreground_blit .. colors.toBlit(self.foreground)
                background_blit = background_blit .. colors.toBlit(self.background)
            elseif inverted_character_table[char_pixels] then
                characters_blit = characters_blit .. inverted_character_table[char_pixels]
                foreground_blit = foreground_blit .. colors.toBlit(self.background)
                background_blit = background_blit .. colors.toBlit(self.foreground)
            end
        end
    end
    return characters_blit, foreground_blit, background_blit
end

function SmolCanvas:render_canvas(screen_x, screen_y)
    local saved_cursor_x, saved_cursor_y = term.getCursorPos()
    local saved_text_color = term.getTextColor()
    local saved_background_color = term.getBackgroundColor()

    local characters_blit, foreground_blit, background_blit = self:get_canvas_blit()

    for char_y = 1, self.char_height do
        term.setCursorPos(screen_x, char_y + screen_y - 1)
        local characters_sub = string.sub(characters_blit, 1 + self.char_width * char_y - self.char_width, self.char_width * char_y)
        local foreground_sub = string.sub(foreground_blit, 1 + self.char_width * char_y - self.char_width, self.char_width * char_y)
        local background_sub = string.sub(background_blit, 1 + self.char_width * char_y - self.char_width, self.char_width * char_y)
        term.blit(characters_sub, foreground_sub, background_sub)
    end
    
    term.setCursorPos(saved_cursor_x, saved_cursor_y)
    term.setTextColor(saved_text_color)
    term.setBackgroundColor(saved_background_color)
end

return SmolCanvas