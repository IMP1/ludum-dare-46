local controls = require 'controls'
local vec2     = require 'lib.vector2'
local lerp     = require 'lib.lerp'

local ACCELERATION = 256 -- pixels / second / second
local MIN_SPEED    = 32  -- pixels / second
local MAX_SPEED    = 192 -- pixels / second
local SWOOP_SPEED  = 256 -- pixels / second

local IMAGE = love.graphics.newImage("gfx/owl_spritesheet.png")

local QUADS = {
    fall     = love.graphics.newQuad(42, 177, 32, 24, IMAGE:getWidth(), IMAGE:getHeight()),
    straight = love.graphics.newQuad(76, 177, 32, 24, IMAGE:getWidth(), IMAGE:getHeight()),
    rise     = love.graphics.newQuad(108, 177, 32, 24, IMAGE:getWidth(), IMAGE:getHeight()),
    swoop    = love.graphics.newQuad(108, 177, 32, 24, IMAGE:getWidth(), IMAGE:getHeight()),
}

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = {}
    setmetatable(self, Player)
    self.position = vec2.new(x, y)
    self.velocity = vec2.new(192, 0)
    self.sprite   = QUADS.straight
    self.swooping = false
    self.roosting = false
    return self
end

function Player:update_movement(dt)
    if self.roosting then return end
    -- TODO: Rework movement. Player shouldn't be able to go straight up or straight down.
    -- Treat vertical and horizontal movement separately
    local impulse = vec2.new(0, 0)
    if love.keyboard.isDown(controls.move_up) then
        impulse.y = impulse.y - 64
    end    
    if love.keyboard.isDown(controls.move_left) then
        impulse.x = impulse.x - 64
    end
    if love.keyboard.isDown(controls.move_down) then
        impulse.y = impulse.y + 64
    end
    if love.keyboard.isDown(controls.move_right) then
        impulse.x = impulse.x + 64
    end
    if impulse:magnitudeSquared() > 0 then
        self.velocity = lerp.lerp(self.velocity, self.velocity + impulse:normalise() * ACCELERATION, dt)
    end
    if self.velocity:magnitudeSquared() > MAX_SPEED ^ 2 then
        self.velocity = self.velocity:normalise() * MAX_SPEED
    end
    self.position = lerp.lerp(self.position, self.position + self.velocity, dt)
end

function Player:update_sprite(dt)
    if self.swooping then
        self.sprite = QUADS.swoop
    elseif self.velocity.y > math.abs(self.velocity.x) / 4 then
        self.sprite = QUADS.fall
    elseif self.velocity.y < -math.abs(self.velocity.x) / 4 then
        self.sprite = QUADS.rise
    else
        self.sprite = QUADS.straight
    end
end

function Player:update(dt)
    self:update_movement(dt)
    self:update_sprite(dt)
end

function Player:draw(dt)
    local w, h = 32, 24
    local flip = 1
    if self.velocity.x < 0 then
        flip = -1
    end
    love.graphics.draw(IMAGE, self.sprite, self.position[1], self.position[2], 0, flip, 1, w/2, h/2)
end

return Player
