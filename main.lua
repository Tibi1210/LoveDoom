_G.love = require("love")
local push = require "lib/ext/push"
local lick = require "lib/ext/lick"
local tableToString = require "lib/ext/tableToString"
local mapLoader = require "lib/private/mapLoader"

io.stdout:setvbuf('no')
lick.reset = true -- reload love.load everytime you save

local player = {
    x = 0,
    y = 0,
    z = 0,
    angle = 0,
    look = 0
}

local walls = {}
local sectors = {}

local cosLookUp = {}
local sinLookUp = {}


push:setupScreen(160, 120, WW, WH, {
    fullscreen = false,
    resizable = false,
    pixelperfect = true
})

local function drawPixel(x, y, r, g, b)
    love.graphics.setColor(love.math.colorFromBytes(r, g, b))
    love.graphics.points(x, y)
end

local function drawWall(x1, x2, b1, b2, t1, t2, s, r, g, b)
    local dyb = b2 - b1
    local dyt = t2 - t1
    local dx = x2 - x1

    if dx == 0 then dx = 1 end

    local xs = x1

    if x1 < 0 then x1 = 0 end
    if x2 < 0 then x2 = 0 end
    if x1 > SW then x1 = SW end
    if x2 > SW then x2 = SW end

    for x = x1, x2 do
        x=math.floor(x)
        local y1 = dyb * (x - xs + 0.5) / dx + b1
        local y2 = dyt * (x - xs + 0.5) / dx + t1

        if y1 < 0 then y1 = 0 end
        if y2 < 0 then y2 = 0 end
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
            if sectors[s].surf[x] ~= nil then
                for y = sectors[s].surf[x], y1 do
                    drawPixel(x, y, sectors[s].r1, sectors[s].g1, sectors[s].b1)
                end
            end
        end
        if sectors[s].surface == -2 then
            if sectors[s].surf[x] ~= nil then
                for y = y2, sectors[s].surf[x] do
                    drawPixel(x, y, sectors[s].r2, sectors[s].g2, sectors[s].b2)
                end
            end
        end

        for y = y1, y2 do
            drawPixel(x, y, r, g, b)
        end
        ::continue::
    end
end

local function clipBehindPlayer(x1, y1, z1, x2, y2, z2)
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

local function dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.keyboard.setKeyRepeat(true)
    min_dt = 1 / 35
    next_time = love.timer.getTime()

    sectors, walls = mapLoader.loadMap("maps/map1")

    player.x = 617
    player.y = -318
    player.z = -204
    player.angle = 316
    player.look = -9

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
        player.angle = player.angle - 2
        if player.angle < 0 then
            player.angle = player.angle + 360
        end
    end

    if love.keyboard.isDown("l") then
        player.angle = player.angle + 2
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
    --love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 12)
    local wx = {}
    local wy = {}
    local wz = {}
    local CS = cosLookUp[player.angle]
    local SN = sinLookUp[player.angle]

    push:start()

    --order sectors by distance
    local st
    for s = 1, #sectors do
        for w = 1, #sectors - s do
            if sectors[w].d < sectors[w + 1].d then
                st = sectors[w]
                sectors[w] = sectors[w + 1]
                sectors[w + 1] = st
            end
        end
    end

    --draw sectors
    for s = 1, #sectors do
        sectors[s].d = 0 --clear distance
        sectors[s].surf = {}

        sectors[s].surface = 0                                      -- no surface
        if player.z < sectors[s].z1 then sectors[s].surface = 1 end --top surface
        if player.z > sectors[s].z2 then sectors[s].surface = 2 end --bottom surface

        for loop = 1, 2 do
            for i = sectors[s].ws, sectors[s].we do
                --offset bottom 2 points by player
                local x1 = walls[i].x1 - player.x
                local y1 = walls[i].y1 - player.y
                local x2 = walls[i].x2 - player.x
                local y2 = walls[i].y2 - player.y

                --swap for surface
                local swp
                if loop == 1 then
                    swp = x1
                    x1 = x2
                    x2 = swp
                    swp = y1
                    y1 = y2
                    y2 = swp
                end

                --World x position
                wx[0] = x1 * CS - y1 * SN
                wx[1] = x2 * CS - y2 * SN
                wx[2] = wx[0]
                wx[3] = wx[1]

                --World y position
                wy[0] = y1 * CS + x1 * SN
                wy[1] = y2 * CS + x2 * SN
                wy[2] = wy[0]
                wy[3] = wy[1]

                -- wall distance from player
                sectors[s].d = sectors[s].d + dist(0, 0, (wx[0] + wx[1]) / 2, (wy[0] + wy[1]) / 2)

                --World z height
                wz[0] = sectors[s].z1 - player.z + (player.look * wy[0] / 32.0)
                wz[1] = sectors[s].z1 - player.z + (player.look * wy[1] / 32.0)
                wz[2] = wz[0] + sectors[s].z2
                wz[3] = wz[1] + sectors[s].z2

                --dont draw if behind player
                if not (wy[0] < 1 and wy[1] < 1) then
                    --point 1 behind player, clip
                    if wy[0] < 1 then
                        wx[0], wy[0], wz[0] = clipBehindPlayer(wx[0], wy[0], wz[0], wx[1], wy[1], wz[1])
                        wx[2], wy[2], wz[2] = clipBehindPlayer(wx[2], wy[2], wz[2], wx[3], wy[3], wz[3])
                    end
                    --point 2 behind player, clip
                    if wy[1] < 1 then
                        wx[1], wy[1], wz[1] = clipBehindPlayer(wx[1], wy[1], wz[1], wx[0], wy[0], wz[0])
                        wx[3], wy[3], wz[3] = clipBehindPlayer(wx[3], wy[3], wz[3], wx[2], wy[2], wz[2])
                    end

                    --screen x position
                    wx[0] = wx[0] * 200 / wy[0] + SW2
                    wx[1] = wx[1] * 200 / wy[1] + SW2
                    wx[2] = wx[2] * 200 / wy[2] + SW2
                    wx[3] = wx[3] * 200 / wy[3] + SW2
                    --screen y position
                    wy[0] = wz[0] * 200 / wy[0] + SH2
                    wy[1] = wz[1] * 200 / wy[1] + SH2
                    wy[2] = wz[2] * 200 / wy[2] + SH2
                    wy[3] = wz[3] * 200 / wy[3] + SH2

                    --draw points
                    drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3], s, walls[i].r, walls[i].g, walls[i].b)
                end
            end
            sectors[s].d = sectors[s].d / (sectors[s].we - sectors[s].ws) --average sector distance
            sectors[s].surface = sectors[s].surface * -1                  --flip to negative to draw surface
        end
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

    if key == 't' then
        player.x = 617
        player.y = -318
        player.z = -204
        player.angle = 316
        player.look = -9
    end
    if key == 'r' then
        player.x = 540
        player.y = -253
        player.z = 176
        player.angle = 316
        player.look = 9
    end
end
