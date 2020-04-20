local scene_manager = require 'lib.scene_manager'

local CreditsScene = require 'scn.credits'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

function Scene.new(success)
    local self = BaseScene.new("Intro")
    setmetatable(self, Scene)
    self.success = success
    return self
end

function Scene:load()
    self.canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(self.canvas)
    if self.success then
        love.graphics.printf(T"Your little owlet isn't so little anymore.", 16, 64, 208, "center")
        love.graphics.printf(T"With its belly full, it begins its journey.", 16, 80, 208, "center")
        for _, t in pairs(TUTORIALS) do
            t.completed = true
        end
    else
        love.graphics.printf(T"The nest is quiet now.", 16, 72, 208, "center")
    end
    love.graphics.setCanvas()
    self.timer = 0
    self.prompt = false
end

function Scene:update(dt)
    self.timer = self.timer + dt
    if self.timer > 6 and not self.prompt then
        self.prompt = true
        love.graphics.setCanvas(self.canvas)
        love.graphics.printf(T"Press any key to continue.", 16, 128, 208, "center")
        love.graphics.setCanvas()
    end
end

function Scene:keyPressed()
    if self.timer > 2 or key == "enter" or key == "return" then
        scene_manager.setScene(CreditsScene.new(self.success))
    end
end

function Scene:mousePressed()
    scene_manager.setScene(CreditsScene.new(self.success))
end

function Scene:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 4)
end

return Scene
