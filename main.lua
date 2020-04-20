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
    -- movement_displayed = false,
    -- hunting_displayed = false,
    -- stealth_displayed = false,
    -- swooping_displayed = false,
    -- roosting_displayed = false,
    -- hunger_displayed = false,
}

-- TODO: Add prompts for gameplay aspects
--         * hunting
--         * swooping
--         * roosting
--         * hunger

-- TODO: SUBMIT

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
        end
    end
    scene_manager.update(dt)
end

function love.draw()
    scene_manager.draw()
end
