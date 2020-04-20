local scene_manager = require 'lib.scene_manager'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

local SUCCESS_IMAGE = love.graphics.newImage("gfx/game_win.png")
local FAILURE_IMAGE = love.graphics.newImage("gfx/game_lose.png")

local SCROLL_SPEED = 64

function Scene.new(success)
    local self = BaseScene.new("Intro")
    setmetatable(self, Scene)
    self.success = success
    self.scroll = 160
    return self
end

function Scene:loadCredits()
    love.graphics.setCanvas(self.credits)
    local y = 0
    love.graphics.printf("Fledgeling", 0, y, 240, "center")
    y = y + 24
    love.graphics.printf("By Huw Taylor", 0, y, 240, "center")

    y = y + 48
    love.graphics.printf("Graphics", 0, y, 240, "center")

    y = y + 16
    love.graphics.printf("Tree Sprites", 0, y, 120, "center")
    love.graphics.printf("Jestan", 120, y, 120, "center")
    y = y + 16
    love.graphics.printf("Rat Sprites", 0, y, 120, "center")
    love.graphics.printf("Calciumtrice", 120, y, 120, "center")
    y = y + 16
    love.graphics.printf("Pixel Font", 0, y, 120, "center")
    love.graphics.printf("Dale Harris", 120, y, 120, "center")

    y = y + 32
    love.graphics.printf("Music", 0, y, 240, "center")

    y = y + 16
    love.graphics.printf("Ofelia's Dream", 0, y, 120, "center")
    love.graphics.printf("Bensound", 120, y, 120, "center")

    love.graphics.setCanvas()
end

function Scene:load()
    self.background = love.graphics.newCanvas()
    self.credits    = love.graphics.newCanvas()
    love.graphics.setCanvas(self.background)
    if self.success then
        love.graphics.draw(SUCCESS_IMAGE)
    else
        love.graphics.draw(FAILURE_IMAGE)
    end
    love.graphics.setCanvas()
    self:loadCredits()
end

function Scene:keyPressed()
    if self.scroll < 100 or key == "enter" or key == "return" then
        scene_manager.popScene()
    end
end

function Scene:mousePressed()
    scene_manager.popScene()
end

function Scene:update(dt)
    self.scroll = self.scroll - dt * SCROLL_SPEED
end

function Scene:draw()
    love.graphics.draw(self.background, 0, 0, 0, 4)
    love.graphics.draw(self.credits, 0, self.scroll, 0, 4)
end

return Scene
