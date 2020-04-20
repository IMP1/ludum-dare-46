local scene_manager = require 'lib.scene_manager'

function T(str)
    return str
end

DEBUG = true

local PIXEL_SCALE = 1
local WIDTH, HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()

TUTORIALS = {
    movement = {
        timer = nil,
        completed = false,
        message = T"Use WASD or the Arrow keys to move.",
        delay = 4,
    },
    hunting = {
        timer = nil,
        completed = false,
        message = T"Get near to a rat and press SPACE to catch it.",
        delay = 6,
        duration = 4,
    },
    stealth = {
        timer = nil,
        completed = false,
        message = T"Avoid flapping your wings, which alerts the rats.",
        delay = 4,
        duration = 4,
    },
    hiding = {
        timer = nil,
        completed = false,
        message = T"Rats will hide under stones and sticks if they hear you coming.",
        delay = 0,
        duration = 4,
    },
    swooping = {
        timer = nil,
        completed = false,
        message = T"Press SPACE to catch the rat when you are close enough.",
        delay = 4,
        duration = 4,
    },
    hunger = {
        timer = nil,
        completed = false,
        message = T"Return to the nest with a rat to feed your owlet.",
        delay = 4,
        duration = 4,
    },
    roosting = {
        timer = nil,
        completed = false,
        message = T"Press R to roost at your nest.",
        delay = 0,
        duration = 1,
        multi = true,
    },
}
TUTORIALS_OFF = false

function love.load()
    local bgm = love.audio.newSource("sfx/bensound-ofeliasdream.mp3", "stream")
    bgm:setLooping(true)
    bgm:play()
    love.graphics.setBackgroundColor(34/255,32/255,52/255)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    local pixel_font = love.graphics.newImageFont("gfx/font.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890!?.,:;'()-", 1) 
    love.graphics.setFont(pixel_font)
    local Scene = require 'scn.title'
    scene_manager.hook()
    scene_manager.setScene(Scene.new())
end

function love.keypressed(key)
    if DEBUG then
        if key == "escape" then love.event.quit() end
    end
    if key == "`" then DEBUG = not DEBUG end
end

function love.update(dt)
    for _, tutorial in pairs(TUTORIALS) do
        if tutorial.timer then
            tutorial.timer = tutorial.timer + dt
            if tutorial.duration and tutorial.timer - tutorial.delay > tutorial.duration then
                tutorial.completed = true
                if tutorial.multi then
                    tutorial.completed = false
                    tutorial.timer = nil
                    
                end
            end
        end
    end
    scene_manager.update(dt)
end

function love.draw()
    scene_manager.draw()
end
