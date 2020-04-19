local controls = require 'controls'
local vec2     = require 'lib.vector2'
local lerp     = require 'lib.lerp'

local ACCELERATION = 256 -- pixels / second / second
local MIN_SPEED    = 32  -- pixels / second
local MAX_SPEED    = 192 -- pixels / second
local SWOOP_SPEED  = 256 -- pixels / second

local SPRITES = {
    straight = love.graphics.newImage("gfx/owl_glide.png"),
    rise     = love.graphics.newImage("gfx/owl_rise.png"),
    fall     = love.graphics.newImage("gfx/owl_fall.png"),
    swoop    = love.graphics.newImage("gfx/owl_fall.png"),
}

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = {}
    setmetatable(self, Player)
    self.position = vec2.new(x, y)
    self.velocity = vec2.new(192, 0)
    self.sprite   = SPRITES.straight
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
        self.sprite = SPRITES.swoop
    elseif self.velocity.y > math.abs(self.velocity.x) / 4 then
        self.sprite = SPRITES.fall
    elseif self.velocity.y < -math.abs(self.velocity.x) / 4 then
        self.sprite = SPRITES.rise
    else
        self.sprite = SPRITES.straight
    end
end

function Player:update(dt)
    self:update_movement(dt)
    self:update_sprite(dt)
end

function Player:draw(dt)
    local w, h = self.sprite:getDimensions()
    local flip = 1
    if self.velocity.x < 0 then
        flip = -1
    end
    love.graphics.circle("fill", self.position[1], self.position[2], 6)
    love.graphics.draw(self.sprite, self.position[1], self.position[2], 0, flip, 1, w/2, h/2)
end

return Player
