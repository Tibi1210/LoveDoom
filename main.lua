_G.love = require("love")
io.stdout:setvbuf('no')

local push = require "push"
lick = require "lick"
lick.reset = true -- reload love.load everytime you save


local player = {
    x = 0,
    y = 0,
    z = 0,
    angle = 0,
    look = 0
}

local walls = {
    --RED
    {
        x1 = 0,
        y1 = 0,
        x2 = 32,
        y2 = 0,
        c = 1
    },

    {
        x1 = 32,
        y1 = 0,
        x2 = 32,
        y2 = 32,
        c = 2
    },
    {
        x1 = 32,
        y1 = 32,
        x2 = 0,
        y2 = 32,
        c = 1
    },
    {
        x1 = 0,
        y1 = 32,
        x2 = 0,
        y2 = 0,
        c = 2
    },
    --GREEN
    {
        x1 = 64,
        y1 = 0,
        x2 = 96,
        y2 = 0,
        c = 3
    },

    {
        x1 = 96,
        y1 = 0,
        x2 = 96,
        y2 = 32,
        c = 4
    },
    {
        x1 = 96,
        y1 = 32,
        x2 = 64,
        y2 = 32,
        c = 3
    },
    {
        x1 = 64,
        y1 = 32,
        x2 = 64,
        y2 = 0,
        c = 4
    },
    --BLUE
    {
        x1 = 64,
        y1 = 64,
        x2 = 96,
        y2 = 64,
        c = 5
    },

    {
        x1 = 96,
        y1 = 64,
        x2 = 96,
        y2 = 96,
        c = 6
    },

    {
        x1 = 96,
        y1 = 96,
        x2 = 64,
        y2 = 96,
        c = 5
    },
    {
        x1 = 64,
        y1 = 96,
        x2 = 64,
        y2 = 64,
        c = 6
    },
    --WHITE
    {
        x1 = 0,
        y1 = 64,
        x2 = 32,
        y2 = 64,
        c = 7
    },

    {
        x1 = 32,
        y1 = 64,
        x2 = 32,
        y2 = 96,
        c = 8
    },

    {
        x1 = 32,
        y1 = 96,
        x2 = 0,
        y2 = 96,
        c = 7
    },
    {
        x1 = 0,
        y1 = 96,
        x2 = 0,
        y2 = 64,
        c = 8
    },
}

--[[

local walls = {
    --RED
    {
        x1 = 0,
        y1 = 0,
        x2 = 100,
        y2 = 0,
        c = 1
    },

    {
        x1 = 0,
        y1 = 100,
        x2 = 0,
        y2 = 0,
        c = 2
    },
    {
        x1 = 100,
        y1 = 0,
        x2 = 100,
        y2 = 100,
        c = 1
    },
    {
        x1 = 100,
        y1 = 100,
        x2 = 0,
        y2 = 100,
        c = 2
    },
    --GREEN
    {
        x1 = 0,
        y1 = 200,
        x2 = 100,
        y2 = 200,
        c = 3
    },

    {
        x1 = 0,
        y1 = 300,
        x2 = 0,
        y2 = 200,
        c = 4
    },
    {
        x1 = 100,
        y1 = 200,
        x2 = 100,
        y2 = 300,
        c = 3
    },
    {
        x1 = 100,
        y1 = 300,
        x2 = 0,
        y2 = 300,
        c = 4
    },
    --BLUE
    {
        x1 = 200,
        y1 = 0,
        x2 = 300,
        y2 = 0,
        c = 5
    },

    {
        x1 = 200,
        y1 = 100,
        x2 = 200,
        y2 = 0,
        c = 6
    },

    {
        x1 = 300,
        y1 = 0,
        x2 = 300,
        y2 = 100,
        c = 5
    },
    {
        x1 = 300,
        y1 = 100,
        x2 = 200,
        y2 = 100,
        c = 6
    },
    --WHITE
    {
        x1 = 200,
        y1 = 200,
        x2 = 300,
        y2 = 200,
        c = 7
    },

    {
        x1 = 200,
        y1 = 300,
        x2 = 200,
        y2 = 200,
        c = 8
    },

    {
        x1 = 300,
        y1 = 200,
        x2 = 300,
        y2 = 300,
        c = 7
    },
    {
        x1 = 300,
        y1 = 300,
        x2 = 200,
        y2 = 300,
        c = 8
    },
}
]]

local sectors = {
    {
        ws = 1,
        we = 4,
        z1 = 0,
        z2 = 40,
        d = 0,
        c1 = 1,
        c2 = 2,
        surf = {},
        surface = 0
    },
    {
        ws = 5,
        we = 8,
        z1 = 0,
        z2 = 40,
        d = 0,
        c1 = 3,
        c2 = 4,
        surf = {},
        surface = 0
    },
    {
        ws = 9,
        we = 12,
        z1 = 0,
        z2 = 40,
        d = 0,
        c1 = 5,
        c2 = 6,
        surf = {},
        surface = 0
    },
    {
        ws = 13,
        we = 16,
        z1 = 0,
        z2 = 40,
        d = 0,
        c1 = 7,
        c2 = 8,
        surf = {},
        surface = 0
    }

}

local cosLookUp = {}
local sinLookUp = {}

push:setupScreen(160, 120, WW, WH, {
    fullscreen = false,
    resizable = false,
    pixelperfect = true
})

function drawPixel(x, y, r, g, b, a)
    love.graphics.setColor(love.math.colorFromBytes( r, g, b))
    love.graphics.points(x, y)
end

function drawWall(x1, x2, b1, b2, t1, t2, s)
    local dyb = b2 - b1
    local dyt = t2 - t1
    local dx = x2 - x1

    if dx == 0 then dx = 1 end

    local xs = x1

    if x1 < 0 then x1 = 0 end
    if x2 < 0 then x2 = 0 end
    if x1 > SW then x1 = SW end
    if x2 > SW then x2 = SW end

    for x = x1, x2, 1 do
        local y1 = dyb * (x - xs + 0.5) / dx + b1
        local y2 = dyt * (x - xs + 0.5) / dx + t1

        if y1 < 0 then y1 = 1 end
        if y2 < 0 then y2 = 1 end
        if y1 > SH then y1 = SH end
        if y2 > SH then y2 = SH end

        if sectors[s].surface == 1 then
            sectors[s].surf[x] = y1
            goto continue
        end
        if sectors[s].surface == 2 then
            sectors[s].surf[x] = y2
            goto continue
        end

        if sectors[s].surface == -1 then
            if not (sectors[s].surf[x] == nil) then
                for y = sectors[s].surf[x], y1 do
                    drawPixel(x, y, 155, 155, 155, 1)
                end
            end
        end
        if sectors[s].surface == -2 then
            if not (sectors[s].surf[x] == nil) then
                for y = y2, sectors[s].surf[x] do
                    drawPixel(x, y, 255, 0, 0, 1)
                end
            end
        end


        for y = y1, y2 do
            drawPixel(x, y, 255, 255, 255, 1)
        end

        ::continue::
    end
end

function clipBehindPlayer(x1, y1, z1, x2, y2, z2)
    local da = y1
    local db = y2
    local d = da - db
    if d == 0 then d = 1 end

    local s = da / (da - db)
    x1 = x1 + s * (x2 - (x1))
    y1 = y1 + s * (y2 - (y1))

    if y1 == 0 then y1 = 1 end

    z1 = z1 + s * (z2 - (z1))

    return x1, y1, z1
end

function dist(x1, y1, x2, y2)
    local distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    return distance;
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.keyboard.setKeyRepeat(true)
    min_dt = 1 / 30
    next_time = love.timer.getTime()

    player.x = 181
    player.y = -85
    player.z = -56
    player.angle = 316
    player.look = -11

    local sin = math.sin
    local cos = math.cos

    for i = 0, 360, 1 do
        cosLookUp[i] = cos(i / 180 * math.pi)
        sinLookUp[i] = sin(i / 180 * math.pi)
    end
end

function love.update(dt)
    next_time = next_time + min_dt

    --look left/right
    if love.keyboard.isDown("j") then
        player.angle = player.angle - 4
        if player.angle < 0 then
            player.angle = player.angle + 360
        end
    end

    if love.keyboard.isDown("l") then
        player.angle = player.angle + 4
        if player.angle > 359 then
            player.angle = player.angle - 360
        end
    end

    local dx = sinLookUp[player.angle] * 10
    local dy = cosLookUp[player.angle] * 10

    --strafe
    if love.keyboard.isDown("a") then
        player.x = player.x - dy
        player.y = player.y + dx
    end

    if love.keyboard.isDown("d") then
        player.x = player.x + dy
        player.y = player.y - dx
    end

    --forward/backwards
    if love.keyboard.isDown("w") then
        player.x = player.x + dx
        player.y = player.y + dy
    end

    if love.keyboard.isDown("s") then
        player.x = player.x - dx
        player.y = player.y - dy
    end

    -- look up/down
    if love.keyboard.isDown("i") then
        player.look = player.look + 1
    end

    if love.keyboard.isDown("k") then
        player.look = player.look - 1
    end

    -- move up/down
    if love.keyboard.isDown("e") then
        player.z = player.z + 4
    end

    if love.keyboard.isDown("q") then
        player.z = player.z - 4
    end
end

function love.draw()
    love.graphics.setColor(255, 0, 0, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    local wx = {}
    local wy = {}
    local wz = {}
    local CS = cosLookUp[player.angle]
    local SN = sinLookUp[player.angle]

    push:start()

    for s = 1, #sectors do
        for w = 1, #sectors - s do
            if sectors[w].d < sectors[w + 1].d then
                st = sectors[w]
                sectors[w] = sectors[w + 1]
                sectors[w + 1] = st
            end
        end
    end

    local secCount = 1
    for _, sector in ipairs(sectors) do
        sector.d = 0

        sector.surface = 0
        if player.z < sector.z1 then sector.surface = 1 end
        if player.z > sector.z2 then sector.surface = 2 end

        for loop = 1, 2 do
            for i = sector.ws, sector.we do

                local x1 = walls[i].x1 - player.x
                local y1 = walls[i].y1 - player.y

                local x2 = walls[i].x2 - player.x
                local y2 = walls[i].y2 - player.y

                if loop == 1 then
                    swp = x1
                    x1 = x2
                    x2 = swp
                    swp = y1
                    y1 = y2
                    y2 = swp
                end

                wx[0] = x1 * CS - y1 * SN
                wx[1] = x2 * CS - y2 * SN
                wx[2] = wx[0]
                wx[3] = wx[1]

                wy[0] = y1 * CS + x1 * SN
                wy[1] = y2 * CS + x2 * SN
                wy[2] = wy[0]
                wy[3] = wy[1]

                sector.d = sector.d + dist(0, 0, (wx[0] + wx[1]) / 2, (wy[0] + wy[1]) / 2)

                wz[0] = sector.z1 * -1 - player.z + (player.look * wy[0] / 32)
                wz[1] = sector.z1 * -1 - player.z + (player.look * wy[1] / 32)

                wz[2] = wz[0] + sector.z2
                wz[3] = wz[1] + sector.z2

                if not (wy[0] < 1 and wy[1] < 1) then
                    if wy[0] < 1 then
                        wx[0], wy[0], wz[0] = clipBehindPlayer(wx[0], wy[0], wz[0], wx[1], wy[1], wz[1])
                        wx[2], wy[2], wz[2] = clipBehindPlayer(wx[2], wy[2], wz[2], wx[3], wy[3], wz[3])
                    end
                    if wy[1] < 1 then
                        wx[1], wy[1], wz[1] = clipBehindPlayer(wx[1], wy[1], wz[1], wx[0], wy[0], wz[0])
                        wx[3], wy[3], wz[3] = clipBehindPlayer(wx[3], wy[3], wz[3], wx[2], wy[2], wz[2])
                    end

                    wx[0] = wx[0] * 200 / wy[0] + SW2
                    wx[1] = wx[1] * 200 / wy[1] + SW2
                    wx[2] = wx[2] * 200 / wy[2] + SW2
                    wx[3] = wx[3] * 200 / wy[3] + SW2

                    wy[0] = wz[0] * 200 / wy[0] + SH2
                    wy[1] = wz[1] * 200 / wy[1] + SH2
                    wy[2] = wz[2] * 200 / wy[2] + SH2
                    wy[3] = wz[3] * 200 / wy[3] + SH2

                    drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3], secCount)
                end
            end
            sector.d = sector.d / (sector.we - sector.ws)
            sector.surface = sector.surface * -1
        end
        secCount = secCount + 1
    end
    push:finish()

    local cur_time = love.timer.getTime()
    if next_time <= cur_time then
        next_time = cur_time
        return
    end
    love.timer.sleep(next_time - cur_time)
    --print("x: " .. player.x .. " " .. "y: " .. player.y .. " " .. "z: " .. player.z .. " " .. "a: " .. player.angle .. " " .. "l: " .. player.look)
end

function love.keypressed(key)
    if key == 'space' then
        love.event.quit()
    end
end

function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result .. "[\"" .. k .. "\"]" .. "="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result .. table_to_string(v)
        elseif type(v) == "boolean" then
            result = result .. tostring(v)
        else
            result = result .. "\"" .. v .. "\""
        end
        result = result .. ","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len() - 1)
    end
    return result .. "}"
end
