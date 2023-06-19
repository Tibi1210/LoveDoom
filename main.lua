_G.love = require("love")
local push = require "lib/ext/push"
local lick = require "lib/ext/lick"
local tableToString = require "lib/ext/tableToString"
local mapLoader = require "lib/private/mapLoader"

io.stdout:setvbuf('no')
lick.reset = true -- reload love.load everytime you save

local player = {
    x = 0,     --int
    y = 0,     --int
    z = 0,     --int
    angle = 0, --int
    look = 0   --int
}

local walls = {}
local sectors = {}

local cosLookUp = {} --float
local sinLookUp = {} --float


push:setupScreen(160, 120, WW, WH, {
    fullscreen = false,
    resizable = false,
    pixelperfect = true
})

local function drawPixel(x, y, r, g, b)
    love.graphics.setColor(love.math.colorFromBytes(r, g, b))
    love.graphics.points(x, y)
end

local function drawWall(x1, x2, b1, b2, t1, t2, s,w,frontBack, r, g, b)
    local dyb = math.floor(b2 - b1) --int
    local dyt = math.floor(t2 - t1) --int
    local dx = math.floor(x2 - x1)  --int

    if dx == 0 then dx = 1 end

    local xs = math.floor(x1) --int

    if x1 < 0 then x1 = 0 end
    if x2 < 0 then x2 = 0 end
    if x1 > SW then x1 = SW end
    if x2 > SW then x2 = SW end

    for x = x1, x2 do
        x = math.floor(x)
        local y1 = math.floor(dyb * (x - xs + 0.5) / dx + b1) --int
        local y2 = math.floor(dyt * (x - xs + 0.5) / dx + t1) --int

        if y1 < 0 then y1 = 0 end
        if y2 < 0 then y2 = 0 end
        if y1 > SH then y1 = SH end
        if y2 > SH then y2 = SH end

        if frontBack==1 then
            if sectors[s].surface==1 then
                sectors[s].surf[x]=y1
            end
            if sectors[s].surface==2 then
                sectors[s].surf[x]=y2
            end
            for y = y1, y2 do
                drawPixel(x, y, r, g, b)
            end
            
        end

        if frontBack==2 then
            if sectors[s].surface==1 then
                y2=sectors[s].surf[x]
            end
            if sectors[s].surface==2 then
                y1=sectors[s].surf[x]
            end
            for y = y1, y2 do
                drawPixel(x, y, r, g, b)
            end
            
        end
    end
end

local function clipBehindPlayer(x1, y1, z1, x2, y2, z2)
    local da = y1     --float
    local db = y2     --float
    local d = da - db --float
    if d == 0 then d = 1 end

    local s = da / (da - db) --float
    x1 = x1 + s * (x2 - (x1))
    y1 = y1 + s * (y2 - (y1))

    if y1 == 0 then y1 = 1 end

    z1 = z1 + s * (z2 - (z1))

    return x1, y1, z1
end

local function dist(x1, y1, x2, y2)
    return math.floor(math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))) --int
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.keyboard.setKeyRepeat(true)
    min_dt = 1 / 35
    next_time = love.timer.getTime()

    sectors, walls = mapLoader.loadMap("maps/map3")

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
    --love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 12)
    local wx = {}                      --int[4]
    local wy = {}                      --int[4]
    local wz = {}                      --int[4]
    local CS = cosLookUp[player.angle] --float
    local SN = sinLookUp[player.angle] --float
    local cycles = 1                   --int

    push:start()

    --order sectors by distance
    local st --sector
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

        sectors[s].surface = 0           -- no surface
        if player.z < sectors[s].z1 then --top surface
            sectors[s].surface = 1
            cycles = 2
            for x = 0, SW do
                sectors[s].surf[x] = SH
            end
        end
        if player.z > sectors[s].z2 then --bottom surface
            sectors[s].surface = 2
            cycles = 2
            for x = 0, SW do
                sectors[s].surf[x] = 0
            end
        end

        for frontBack = 1, cycles do
            for i = sectors[s].ws, sectors[s].we do
                --offset bottom 2 points by player
                local x1 = walls[i].x1 - player.x
                local y1 = walls[i].y1 - player.y
                local x2 = walls[i].x2 - player.x
                local y2 = walls[i].y2 - player.y

                --swap for surface
                local swp
                if frontBack == 2 then
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
                wz[0] = sectors[s].z1 - player.z + (player.look * wy[0] / 32.0) --int
                wz[1] = sectors[s].z1 - player.z + (player.look * wy[1] / 32.0) --int
                wz[2] = sectors[s].z2 - player.z + (player.look * wy[0] / 32.0) --int
                wz[3] = sectors[s].z2 - player.z + (player.look * wy[1] / 32.0) --int

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

                    --convert to int
                    wx[0] = math.floor(wx[0])
                    wx[1] = math.floor(wx[1])
                    wx[2] = math.floor(wx[2])
                    wx[3] = math.floor(wx[3])

                    wy[0] = math.floor(wy[0])
                    wy[1] = math.floor(wy[1])
                    wy[2] = math.floor(wy[2])
                    wy[3] = math.floor(wy[3])

                    wz[0] = math.floor(wz[0])
                    wz[1] = math.floor(wz[1])
                    wz[2] = math.floor(wz[2])
                    wz[3] = math.floor(wz[3])

                    --draw points
                    drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3], s, i, frontBack, walls[i].r, walls[i].g,
                        walls[i].b)
                end
            end
            sectors[s].d = math.floor(sectors[s].d / (sectors[s].we - sectors[s].ws)) --average sector distances
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
    if key == 'g' then
        sectors, walls = mapLoader.loadMap("maps/map3")
    end
end
