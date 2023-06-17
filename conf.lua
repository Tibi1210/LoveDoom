local res = 6

SW = 160
SH = 120
WW = 160 * res
WH = 120 * res
SW2 = (SW / 2)
SH2 = (SH / 2)

function love.conf(t)
    t.window.title = "LoveDoom"

    t.window.height = SH
    t.window.width = SW
    t.window.resizable = false

    t.console = true

    --t.window.borderless = true
end
