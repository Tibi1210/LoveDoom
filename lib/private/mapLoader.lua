local mapLoader = {}

local walls = {}
local sectors = {}

local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

local function loadSectors(line)
    table.insert(sectors, {})
    local data = split(line, ",")
    sectors[#sectors].ws = tonumber(data[1])
    sectors[#sectors].we = tonumber(data[2])
    sectors[#sectors].z1 = tonumber(data[3])
    sectors[#sectors].z2 = tonumber(data[4])
    sectors[#sectors].d = tonumber(data[5])
    sectors[#sectors].surf = {}
    sectors[#sectors].surface = tonumber(data[6])
    sectors[#sectors].r1 = tonumber(data[7])
    sectors[#sectors].g1 = tonumber(data[8])
    sectors[#sectors].b1 = tonumber(data[9])
    sectors[#sectors].r2 = tonumber(data[10])
    sectors[#sectors].g2 = tonumber(data[11])
    sectors[#sectors].b2 = tonumber(data[12])
end

local function loadWalls(line)
    table.insert(walls, {})
    local data = split(line, ",")
    walls[#walls].x1 = tonumber(data[1])
    walls[#walls].y1 = tonumber(data[2])
    walls[#walls].x2 = tonumber(data[3])
    walls[#walls].y2 = tonumber(data[4])
    walls[#walls].r = tonumber(data[5])
    walls[#walls].g = tonumber(data[6])
    walls[#walls].b = tonumber(data[7])
end

function mapLoader.loadMap(file)
    walls = {}
    sectors = {}
    local i = 0
    for line in io.lines(file .. "/sectors.txt") do
        if i ~= 0 then
            loadSectors(line)
        end
        i = 1
    end
    i = 0
    for line in io.lines(file .. "/walls.txt") do
        if i ~= 0 then
            loadWalls(line)
        end
        i = 1
    end
    return sectors,walls
end

return mapLoader