local vec2 = require 'lib.vector2'

local rat = {}
rat.__index = rat

local SPRITES = {
    idle = love.graphics.newImage("gfx/rat_1.png"),
}

local GRAZE_TIME_PERIOD = {1, 4}

function rat.new(x, y)
    local self = {}
    setmetatable(self, rat)
    self.position = vec2.new(x, y)
    self.sprite = SPRITES.idle
    self.size = {}
    self.grazing = true
    self.fleeing = true
    self.moving  = true
    self.timer   = GRAZE_TIME_PERIOD[1] + (GRAZE_TIME_PERIOD[2] - GRAZE_TIME_PERIOD[1]) * math.random()
    return self
end

function rat:update(dt, player)
    if self.grazing then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.timer = 0
            -- TODO: move somewhere else.
        end
    end
end

function rat:draw()
    local w, h = self.sprite:getDimensions()
    local flip = 1
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, flip, 1, w/2, h)
end

return rat
