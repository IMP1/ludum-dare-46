local scene_manager = require 'lib.scene_manager'

function T(str)
    return str
end

DEBUG = true

local PIXEL_SCALE = 1
local WIDTH, HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()
local canvas

TUTORIAL = {
    timers = {
        movement = nil,
        swooping = nil,
    },
    movement_displayed = false,
    swooping_displayed = false,
}

-- TODO: Add prompts for gameplay

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local pixel_font = love.graphics.newImageFont("gfx/font.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz1234567890!?.,:;'()-", 1) 
    love.graphics.setFont(pixel_font)
    local ForestScene = require 'scn.forest'
    scene_manager.hook()
    scene_manager.setScene(ForestScene.new())
end

function love.keypressed(key)
    if DEBUG then
        if key == "escape" then love.event.quit() end
    end
    if key == "`" then DEBUG = not DEBUG end
end

function love.update(dt)
    for key, timer in pairs(TUTORIAL.timers) do
        if timer then
            TUTORIAL.timers[key] = timer + dt
        end
    end
    scene_manager.update(dt)
end

function love.draw()
    scene_manager.draw()
end
