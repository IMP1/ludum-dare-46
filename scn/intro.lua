local scene_manager = require 'lib.scene_manager'

local GameScene = require 'scn.forest'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

function Scene.new()
    local self = BaseScene.new("Intro")
    setmetatable(self, Scene)
    return self
end

function Scene:load()
    self.canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.printf(T"Your little owlet is almost ready to take flight and leave the nest.", 16, 16, 208, "center")
    love.graphics.printf(T"You will need to find it the food it will need to take its journey.", 16, 48, 208, "center")
    love.graphics.setCanvas()
    self.timer = 0
    self.prompt = false
end

function Scene:update(dt)
    self.timer = self.timer + dt
    if self.timer > 2 and not self.prompt then
        self.prompt = true
        love.graphics.setCanvas(self.canvas)
        love.graphics.printf(T"Press any key to continue.", 16, 128, 208, "center")
        love.graphics.setCanvas()
    end
    love.graphics.printf(T"Press any key to begin.", 16, 128, 208, "center")
end

function Scene:keyPressed(key)
    if self.timer > 2 or key == "enter" or key == "return" then
        scene_manager.setScene(GameScene.new())
    end
end

function Scene:mousePressed()
    scene_manager.setScene(GameScene.new())
end

function Scene:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 4)
end

return Scene
