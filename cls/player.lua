local controls = require 'controls'
local lerp     = require 'lib.lerp'

local Vector = require 'lib.vector2'

local Player = {}
Player.__index = Player

Player.IMAGE = love.graphics.newImage("gfx/owl_spritesheet.png")
Player.CATCH_DISTANCE = 24

local ACCELERATION = 256 -- pixels / second / second
local MIN_SPEED    = 32  -- pixels / second
local MAX_SPEED    = 192 -- pixels / second
local SWOOP_SPEED  = 256 -- pixels / second
local FLAP_FREQUENCY = 0.2

local SOUNDS = {
    flap = love.audio.newSource("sfx/flap.ogg", "static"),
}

local QUADS = {
    fall          = love.graphics.newQuad(42, 177, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    fall_flap     = love.graphics.newQuad(42, 156, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    straight      = love.graphics.newQuad(76, 177, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    straight_flap = love.graphics.newQuad(82, 152, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    rise          = love.graphics.newQuad(108, 177, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    rise_flap     = love.graphics.newQuad(116, 155, 17, 14, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    swoop         = love.graphics.newQuad(147, 168, 24, 32, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    roost_1       = love.graphics.newQuad(147, 168, 24, 32, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    roost_2       = love.graphics.newQuad(180, 175, 32, 24, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    caught        = love.graphics.newQuad(186, 145, 24, 32, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
    caught_flap   = love.graphics.newQuad(211, 146, 24, 32, Player.IMAGE:getWidth(), Player.IMAGE:getHeight()),
}

function Player.new(x, y)
    local self = {}
    setmetatable(self, Player)
    self.position = Vector.new(x, y)
    self.velocity = Vector.new(0, 0)
    self.sprite   = QUADS.straight
    self.swooping = false
    self.roosting = true
    self.gliding  = false
    self.last_flap = 0
    self.carried_prey = nil
    self.just_hit_ground = false
    self.flap_animation_timer = 0
    self.flap_animation_flap = false
    return self
end

function Player:accelerate(dt, direction)
    self.velocity = lerp.lerp(self.velocity, self.velocity + direction * ACCELERATION, dt)
end

function Player:update_movement(dt)
    self.last_flap = self.last_flap + dt
    if self.roosting then return end
    local impulse = Vector.new(0, 0)
    if love.keyboard.isDown(controls.move_up) then
        impulse.y = impulse.y - 1
    end    
    if love.keyboard.isDown(controls.move_left) then
        impulse.x = impulse.x - 1
    end
    if love.keyboard.isDown(controls.move_down) then
        impulse.y = impulse.y + 1
    end
    if love.keyboard.isDown(controls.move_right) then
        impulse.x = impulse.x + 1
    end
    if impulse:magnitudeSquared() > 0 then
        self:accelerate(dt, impulse:normalise())
        self.last_flap = 0
        TUTORIAL.movement_displayed = true
        self.flap_animation_timer = self.flap_animation_timer + dt
        if self.flap_animation_timer >= FLAP_FREQUENCY then
            self.flap_animation_timer = self.flap_animation_timer - FLAP_FREQUENCY
            self.flap_animation_flap = not self.flap_animation_flap
            if self.flap_animation_flap then SOUNDS.flap:play() end
        end
    elseif self.carried_prey then
        self.flap_animation_timer = self.flap_animation_timer + dt
        if self.flap_animation_timer >= FLAP_FREQUENCY then
            self.flap_animation_timer = self.flap_animation_timer - FLAP_FREQUENCY
            self.flap_animation_flap = not self.flap_animation_flap
            if self.flap_animation_flap then SOUNDS.flap:play() end
        end
    end
    if love.keyboard.isDown(controls.move_swoop) then
        self.swooping = true
    else
        self.swooping = false
    end
    if self.velocity:magnitudeSquared() > MAX_SPEED ^ 2 then
        self.velocity = self.velocity:normalise() * MAX_SPEED
    end
    self.position = lerp.lerp(self.position, self.position + self.velocity, dt)
end

function Player:update_sprite(dt)
    local flap = self.flap_animation_flap
    if self.roosting then
        self.sprite = QUADS.roost_2
    elseif self.carried_prey then
        self.sprite = flap and QUADS.caught_flap or QUADS.caught
    elseif self.swooping then
        self.sprite = QUADS.swoop 
    else
        if self.velocity.y > math.abs(self.velocity.x) / 4 then
            self.sprite = flap and QUADS.fall_flap or QUADS.fall
        elseif self.velocity.y < -math.abs(self.velocity.x) / 4 then
            self.sprite = flap and QUADS.rise_flap or QUADS.rise
        else
            self.sprite = flap and QUADS.straight_flap or QUADS.straight
        end
    end
end

function Player:roost(x, y)
    self.roosting = true
    self.position.x = x
    self.position.y = y
    self.velocity.y = 0
    self.velocity.x = -0.1
    self.sprite = QUADS.roost_2
end

function Player:catch(prey)
    self.carried_prey = prey
end

function Player:update(dt)
    self:update_movement(dt)
    self:update_sprite(dt)
    if self.just_hit_ground then
        self.just_hit_ground = false
    end
end

function Player:draw(dt)
    local _, _, w, h = self.sprite:getViewport()
    local flip = 1
    if self.velocity.x < 0 then
        flip = -1
    end
    love.graphics.draw(Player.IMAGE, self.sprite, self.position[1], self.position[2], 0, flip, 1, w/2, h/2)
end

return Player
