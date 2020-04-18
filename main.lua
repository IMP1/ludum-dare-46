local scene_manager = require 'lib.scene_manager'

local ForestScene = require 'scn.forest'

function T(str)
    return str
end

function love.load()
    scene_manager.hook()
    scene_manager.setScene(ForestScene.new())
end

function love.update(dt)
    scene_manager.update(dt)
end

function love.draw()
    scene_manager.draw()
end
