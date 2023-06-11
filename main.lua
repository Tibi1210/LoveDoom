_G.love = require("love")


local player = {}
local cosLookUp = {}
local sinLookUp = {}


function drawPixel(x, y, r, g, b, a)
    love.graphics.setColor(r, g, b, a)
    love.graphics.points(x, y)
end

function drawWall(x1, x2, b1, b2, t1, t2)
    dyb = b2 - b1
    dyt = t2 - t1
    dx = x2 - x1
    if dx == 0 then
        dx = 1
    end
    xs = x1

    for x = x1, x2, 1 do
        y1 = dyb * (x - xs + 0.5) / dx + b1
        y2 = dyt * (x - xs + 0.5) / dx + t1

        for y = y1, y2, 1 do
            drawPixel(x, y, 255, 255, 255, 1)
        end

    end
end

function love.load()

    love.keyboard.setKeyRepeat(true)
    player.x = 70
    player.y = -110
    player.z = 20
    player.angle = 0
    player.look = 0

    local sin = math.sin
    local cos = math.cos

    for i = 0, 360, 1 do
        cosLookUp[i]=cos(i / 180 * math.pi)
        sinLookUp[i]=sin(i / 180 * math.pi)
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

    dx = sinLookUp[player.angle] * 10
    dy = cosLookUp[player.angle] * 10

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
    print(dt)
end

function love.draw()
    love.graphics.scale(pixelScale, pixelScale)
    --love.graphics.setColor(255, 255, 255, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

    wx = {}
    wy = {}
    wz = {}
    CS = cosLookUp[player.angle]
    SN = sinLookUp[player.angle]

    x1 = 40 - player.x
    y1 = 10 - player.y

    x2 = 40 - player.x
    y2 = 140 - player.y

    wx[0] = x1 * CS - y1 * SN
    wx[1] = x2 * CS - y2 * SN
    wx[2] = wx[0]
    wx[3] = wx[1]

    wy[0] = y1 * CS + x1 * SN
    wy[1] = y2 * CS + x2 * SN
    wy[2] = wy[0]
    wy[3] = wy[1]


    wz[0] = 0 - player.z + (player.look * wy[0] / 32)
    wz[1] = 0 - player.z + (player.look * wy[1] / 32)

    wz[2] = wz[0] + 40
    wz[3] = wz[1] + 40



    wx[0] = wx[0] * 200 / wy[0] + SW2
    wx[1] = wx[1] * 200 / wy[1] + SW2
    wx[2] = wx[2] * 200 / wy[2] + SW2
    wx[3] = wx[3] * 200 / wy[3] + SW2


    wy[0] = wz[0] * 200 / wy[0] + SH2
    wy[1] = wz[1] * 200 / wy[1] + SH2
    wy[2] = wz[2] * 200 / wy[2] + SH2
    wy[3] = wz[3] * 200 / wy[3] + SH2


    if wx[0] > 0 and wx[0] < SW and wy[0] > 0 and wy[0] < SW then
        -- drawPixel(wx[0], wy[0], 255, 0, 0, 1)
    end

    if wx[1] > 0 and wx[1] < SW and wy[1] > 0 and wy[1] < SW then
        -- drawPixel(wx[1], wy[1], 255, 0, 0, 1)
    end



    --love.graphics.line(wx[0], wy[0], wx[1], wy[1])
    --love.graphics.line(wx[2], wy[2], wx[3], wy[3])




    drawWall(wx[0], wx[1], wy[0], wy[1], wy[2], wy[3])


end

function love.keypressed(key)
    if key == 'space' then
        love.event.quit()
    end
end
