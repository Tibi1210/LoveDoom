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
    {
        x1 = 0,
        y1 = 0,
        x2 = 1000,
        y2 = 0,
        z1 = 0,
        z2 = 1
    },

    {
        x1 = 0,
        y1 = 1000,
        x2 = 0,
        y2 = 0,
        z1 = 0,
        z2 = 1
    },
    {
        x1 = 0,
        y1 = 0,
        x2 = 0,
        y2 = 0,
        z1 = 0,
        z2 = 1000
    },
}



local cosLookUp = {}
local sinLookUp = {}

push:setupScreen(160, 120, WW, WH, {
    fullscreen = false,
    resizable = false,
    pixelperfect = true
})

function drawPixel(x, y, r, g, b, a)
    --love.graphics.setColor(r, g, b, a)
    love.graphics.points(x, y)
end

function drawWall(x1, x2, b1, b2, t1, t2)
    local dyb = b2 - b1
    local dyt = t2 - t1
    local dx = x2 - x1
    if dx == 0 then
        dx = 1
    end
    local xs = x1

    if x1 < 0 then
        x1 = 0
    end
    if x2 < 0 then
        x2 = 0
    end
    if x1 > SW then
        x1 = SW
    end
    if x2 > SW then
        x2 = SW
    end

    for x = x1, x2, 1 do
        local y1 = dyb * (x - xs + 0.5) / dx + b1
        local y2 = dyt * (x - xs + 0.5) / dx + t1

        if y1 < 0 then
            y1 = 1
        end
        if y2 < 0 then
            y2 = 1
        end
        if y1 > SH then
            y1 = SH
        end
        if y2 > SH then
            y2 = SH
        end

        for y = y1, y2, 1 do
            drawPixel(x, y, 255, 255, 255, 1)
        end
    end
end

function clipBehindPlayer(x1, y1, z1, x2, y2, z2)
    local da = y1
    local db = y2
    local d = da - db
    if d == 0 then
        d = 1
    end
    local s = da / (da - db)
    x1 = x1 + s * (x2 - (x1))
    y1 = y1 + s * (y2 - (y1))
    if y1 == 0 then
        y1 = 1
    end
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
    player.x = 0
    player.y = -500
    player.z = 0
    player.angle = 0
    player.look = 0

    local sin = math.sin
    local cos = math.cos

    for i = 0, 360, 1 do
        cosLookUp[i] = cos(i / 180 * math.pi)
        sinLookUp[i] = sin(i / 180 * math.pi)
    end
end

function love.update(dt)
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
    push:start()
    local wx = {}
    local wy = {}
    local wz = {}
    local CS = cosLookUp[player.angle]
    local SN = sinLookUp[player.angle]
    i=1
    for _, wall in ipairs(walls) do
        if i == 1 then
            love.graphics.setColor(255, 0, 0, 1)
        end
        if i == 2 then
            love.graphics.setColor(0, 255, 0, 1)
        end
        if i == 3 then
            love.graphics.setColor(0, 0, 255, 1)
        end
        if i == 4 then
            love.graphics.setColor(255, 255, 255, 1)
        end
        if i == 5 then
            love.graphics.setColor(255, 255, 0, 1)
        end
        i=i+1

        local x1 = wall.x1 - player.x
        local y1 = wall.y1 - player.y

        local x2 = wall.x2 - player.x
        local y2 = wall.y2 - player.y

        wx[0] = x1 * CS - y1 * SN
        wx[1] = x2 * CS - y2 * SN
        wx[2] = wx[0]
        wx[3] = wx[1]

        wy[0] = y1 * CS + x1 * SN
        wy[1] = y2 * CS + x2 * SN
        wy[2] = wy[0]
        wy[3] = wy[1]


        wz[0] = wall.z1 * -1 - player.z + (player.look * wy[0] / 32)
        wz[1] = wall.z1 * -1 - player.z + (player.look * wy[1] / 32)

        wz[2] = wz[0] + wall.z2
        wz[3] = wz[1] + wall.z2

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
            
            drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3])
            drawWall(wx[1], wx[0], wy[1], wy[0], wy[3], wy[2])
        end
    end
    push:finish()
end

function love.keypressed(key)
    if key == 'space' then
        love.event.quit()
    end
end
