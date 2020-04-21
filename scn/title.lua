local scene_manager = require 'lib.scene_manager'

local IntroScene = require 'scn.intro'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

local IMAGE = love.graphics.newImage("gfx/title.png")

function Scene.new()
    local self = BaseScene.new("Title")
    setmetatable(self, Scene)
    return self
end

function Scene:load()
    self.canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(self.canvas)
    love.graphics.draw(IMAGE)
    love.graphics.setCanvas()
end

function Scene:keyPressed(key)
    if key == "lalt" then return end
    scene_manager.pushScene(IntroScene.new())
end

function Scene:mousePressed()
    scene_manager.pushScene(IntroScene.new())
end

function Scene:draw()
    love.graphics.draw(self.canvas, 0, 0, 0, 4)
end

return Scene
