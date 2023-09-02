_G.love = require("love")
local push = require "lib/ext/push"
local lick = require "lib/ext/lick"
local tableToString = require "lib/ext/tableToString"
local mapLoader = require "lib/private/mapLoader"

local brickTexture = require "textures/brick"
local brick2Texture = require "textures/brick2"

local textures = {
    {
        name = brickTexture,
        height = 16,
        width = 16
    },
    {
        name = brick2Texture,
        height = 16,
        width = 16
    }
}


io.stdout:setvbuf('no')
lick.reset = true

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

local function testTextures()
    local t = 1 --texture number
    for y = 1, textures[t].height - 1 do
        for x = 1, textures[t].width - 1 do
            local pixel = math.floor(y * 3 * textures[t].width + x * 3)
            --print(pixel)
            local r = textures[t].name[pixel + 1]
            local g = textures[t].name[pixel + 2]
            local b = textures[t].name[pixel + 3]
            drawPixel(x, y, r, g, b)
        end
    end
end

local function floors()
    local x, y                          --int
    local xo = math.floor(SW2)          --int
    local yo = math.floor(SH2)          --int

    local lookUpDown = -player.look * 2 --float
    if lookUpDown > SH then lookUpDown = SH end

    local moveUpDown = player.z / 16.0 --float
    if moveUpDown == 0 then moveUpDown = 0.0001 end

    local ys = math.floor(-yo)         --int
    local ye = math.floor(-lookUpDown) --int

    if moveUpDown < 0 then
        ys = math.floor(-lookUpDown)
        ye = math.floor(yo + lookUpDown)
    end

    for y = ys, ye do
        for x = -xo, xo do
            local z = y + lookUpDown --float
            if z == 0 then z = 0.0001 end

            local fx = x / z * moveUpDown                                                              --float
            local fy = 200.0 / z * moveUpDown                                                          --float
            local rx = fx * sinLookUp[player.angle] - fy * cosLookUp[player.angle] + (player.y / 30.0) --float
            local ry = fx * cosLookUp[player.angle] + fy * sinLookUp[player.angle] - (player.x / 30.0) --float

            if rx < 0 then rx = -rx + 1 end
            if (ry < 0) then ry = -ry + 1 end


            if math.floor(rx) % 2 == math.floor(ry) % 2 then
                drawPixel(x + xo, y + yo, 155, 0, 0)
            else
                drawPixel(x + xo, y + yo, 0, 0, 0)
            end
        end
    end
end


local function drawWall(x1, x2, b1, b2, t1, t2, s, w, frontBack)
    --wall texture
    local wt = walls[w].wt --int

    ------------------------------------------------------
    local ht = 0                                                --float
    local ht_step = textures[wt].width * walls[w].u / (x2 - x1) --float
    ------------------------------------------------------

    local dyb = math.floor(b2 - b1) --int
    local dyt = math.floor(t2 - t1) --int
    local dx = math.floor(x2 - x1)  --int

    if dx == 0 then dx = 1 end

    local xs = math.floor(x1) --int

    if x1 < 0 then
        ht = ht - ht_step * x1
        x1 = 0
    end
    if x2 < 0 then x2 = 0 end
    if x1 > SW then x1 = SW end
    if x2 > SW then x2 = SW end

    for x = x1, x2 do
        x = math.floor(x)
        local y1 = math.floor(dyb * (x - xs + 0.5) / dx + b1) --int
        local y2 = math.floor(dyt * (x - xs + 0.5) / dx + t1) --int

        -------------------------------------------------------
        local vt = 0                                                 --float
        local vt_step = textures[wt].height * walls[w].v / (y2 - y1) --float
        -------------------------------------------------------

        if y1 < 0 then
            vt = vt - vt_step * y1
            y1 = 0
        end
        if y2 < 0 then y2 = 0 end
        if y1 > SH then y1 = SH end
        if y2 > SH then y2 = SH end

        if frontBack == 1 then
            if sectors[s].surface == 1 then
                sectors[s].surf[x] = y1
            end
            if sectors[s].surface == 2 then
                sectors[s].surf[x] = y2
            end
            -------------------------------------------------------------------
            for y = y1, y2 do
                --drawPixel(x, y, 0, 255, 0)
                local pixel = math.floor(textures[wt].height - (math.floor(vt) % textures[wt].height) - 1) * 3 *
                textures[wt].width + (math.floor(ht) % textures[wt].width * 3)
                local r = textures[wt].name[pixel + 1] - walls[w].shade
                if r < 0 then r = 0 end
                local g = textures[wt].name[pixel + 2] - walls[w].shade
                if g < 0 then g = 0 end
                local b = textures[wt].name[pixel + 3] - walls[w].shade
                if b < 0 then r = b end
                --print("R:"..r.." G:"..g.." B:"..b)
                drawPixel(x, y, r, g, b)
                vt = vt + vt_step
            end
            ht = ht + ht_step
            ---------------------------------------------------------------------
        end

        if frontBack == 2 then
            local xo = math.floor(SW2) --int
            local yo = math.floor(SH2) --int
            local x2 = math.floor(x - xo)
            local wo
            local tile = sectors[s].ss * 7

            if sectors[s].surface == 1 then
                y2 = sectors[s].surf[x]
                wo = sectors[s].z1
            end
            if sectors[s].surface == 2 then
                y1 = sectors[s].surf[x]
                wo = sectors[s].z2
            end

            local lookUpDown = -player.look * math.pi * 2 --float
            if lookUpDown > SH then lookUpDown = SH end

            local moveUpDown = (player.z - wo) / yo --float
            if moveUpDown == 0 then moveUpDown = 0.0001 end

            local ys = math.floor(y1 - yo) --int
            local ye = math.floor(y2 - yo) --int

            for y = ys, ye do
                local z = y + lookUpDown --float
                if z == 0 then z = 0.0001 end

                local fx = x2 / z * moveUpDown * tile                                                             --float
                local fy = 200.0 / z * moveUpDown * tile                                                          --float
                local rx = fx * sinLookUp[player.angle] - fy * cosLookUp[player.angle] + (player.y / 60.0 * tile) --float
                local ry = fx * cosLookUp[player.angle] + fy * sinLookUp[player.angle] - (player.x / 60.0 * tile) --float

                if rx < 0 then rx = -rx + 1 end
                if (ry < 0) then ry = -ry + 1 end

                local st = sectors[s].st

                local pixel = math.floor(textures[st].height - (math.floor(ry) % textures[st].height) - 1) * 3 * textures[st].width + (math.floor(rx) % textures[st].width * 3)
                local r = textures[st].name[pixel + 1]
                local g = textures[st].name[pixel + 2]
                local b = textures[st].name[pixel + 3]
                drawPixel(x2+xo, y+yo, r, g, b)

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
    x1 = math.floor(x1 + math.floor(s * (x2 - (x1))))
    y1 = math.floor(y1 + math.floor(s * (y2 - (y1))))

    if y1 == 0 then y1 = 1 end

    z1 = math.floor(z1 + math.floor(s * (z2 - (z1))))

    return x1, y1, z1
end

local function dist(x1, y1, x2, y2)
    return math.floor(math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))) --int
end

function love.load()
    love.window.setVSync(0)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.keyboard.setKeyRepeat(true)
    min_dt = 1 / 35
    next_time = love.timer.getTime()

    sectors, walls = mapLoader.loadMap("maps/map2")

    player.x = 433.63808305561
    player.y = 116.60143512704
    player.z = -64
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
                wx[0] = math.floor(x1 * CS - y1 * SN)
                wx[1] = math.floor(x2 * CS - y2 * SN)
                wx[2] = wx[0]
                wx[3] = wx[1]

                --World y position
                wy[0] = math.floor(y1 * CS + x1 * SN)
                wy[1] = math.floor(y2 * CS + x2 * SN)
                wy[2] = wy[0]
                wy[3] = wy[1]

                -- wall distance from player
                sectors[s].d = sectors[s].d + dist(0, 0, (wx[0] + wx[1]) / 2, (wy[0] + wy[1]) / 2)

                --World z height
                wz[0] = math.floor(sectors[s].z1 - player.z + math.floor(player.look * wy[0] / 32.0)) --int
                wz[1] = math.floor(sectors[s].z1 - player.z + math.floor(player.look * wy[1] / 32.0)) --int
                wz[2] = math.floor(sectors[s].z2 - player.z + math.floor(player.look * wy[0] / 32.0)) --int
                wz[3] = math.floor(sectors[s].z2 - player.z + math.floor(player.look * wy[1] / 32.0)) --int

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
                    wx[0] = math.floor(wx[0] * 200 / wy[0] + SW2)
                    wx[1] = math.floor(wx[1] * 200 / wy[1] + SW2)
                    wx[2] = math.floor(wx[2] * 200 / wy[2] + SW2)
                    wx[3] = math.floor(wx[3] * 200 / wy[3] + SW2)
                    --screen y position
                    wy[0] = math.floor(wz[0] * 200 / wy[0] + SH2)
                    wy[1] = math.floor(wz[1] * 200 / wy[1] + SH2)
                    wy[2] = math.floor(wz[2] * 200 / wy[2] + SH2)
                    wy[3] = math.floor(wz[3] * 200 / wy[3] + SH2)

                    --draw points
                    drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3], s, i, frontBack)
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
end

function love.keypressed(key)
    if key == 'space' then
        love.event.quit()
    end

    if key == 'r' then
        player.x = 433.63808305561
        player.y = 116.60143512704
        player.z = -64
        player.angle = 316
        player.look = -9
    end

    if key == 't' then
        print("x: " ..
            player.x ..
            " " ..
            "y: " .. player.y .. " " .. "z: " .. player.z .. " " .. "a: " .. player.angle .. " " .. "l: " .. player.look)
    end

    if key == 'g' then
        sectors, walls = mapLoader.loadMap("maps/map2")
    end
end
