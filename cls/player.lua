local controls = require 'controls'

local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = {}
    setmetatable(self, Player)
    self.position = {x, y}
    self.velocity = {0, 0}
    return self
end

function Player:update_movement(dt)
    local x, y = unpack(self.position)
    local vx, vy = unpack(self.velocity)
    if love.keyboard.isDown(controls.move_up) then
        y = y - 64 * dt
    end    
    if love.keyboard.isDown(controls.move_left) then
        x = x - 64 * dt
    end
    if love.keyboard.isDown(controls.move_down) then
        y = y + 64 * dt
    end
    if love.keyboard.isDown(controls.move_right) then
        x = x + 64 * dt
    end
    self.position = {x, y}
end

function Player:update(dt)
    self:update_movement(dt)
end

function Player:draw(dt)
    love.graphics.circle("fill", self.position[1], self.position[2], 6)
end

return Player
