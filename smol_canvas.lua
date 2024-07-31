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

print(inverted_character_table["000001"])

return SmolCanvas