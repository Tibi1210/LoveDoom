res = 4

SW = 160 * res
SH = 120 * res
SW2 = (SW / 2)
SH2 = (SH / 2)
pixelScale = 4 / res


function love.conf(t)
    t.window.title = "LoveDoom"

    t.window.height = SH
    t.window.width = SW
    t.window.resizable = false

    t.console = true

    --t.window.borderless = true
end
