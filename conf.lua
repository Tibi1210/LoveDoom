local res = 4

SW = 160
SH = 120
WW = SW * res
WH = SH * res
SW2 = math.floor(SW / 2)
SH2 = math.floor(SH / 2)

function love.conf(t)
    t.window.title = "LoveDoom"

    t.window.height = WH
    t.window.width = WW
    t.window.resizable = false

    t.console = true
    
    --t.window.borderless = true
end
