local vec2 = require 'lib.vector2'

local rat = {}
rat.__index = rat

local SPRITES = {
    idle = love.graphics.newImage("gfx/rat_1.png"),
}

function rat.new(x, y)
    local self = {}
    setmetatable(self, rat)
    self.position = vec2.new(x, y)
    self.sprite = SPRITES.idle
    self.size = {}
    return self
end

function rat:update(dt)
end

function rat:draw()
    local w, h = self.sprite:getDimensions()
    local flip = 1
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, flip, 1, w/2, h)
end

return rat
