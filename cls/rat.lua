local lerp = require 'lib.lerp'

local Vector = require 'lib.vector2'

local Rat = {}
Rat.__index = Rat

Rat.SUSPICION_RANGE = 128
Rat.AWARENESS_RANGE = 96

local IMAGE = love.graphics.newImage("gfx/rat_1.png")

local QUADS = {
    idle      = love.graphics.newQuad(0, 0, 32, 16, IMAGE:getWidth(), IMAGE:getHeight()),
    listening = love.graphics.newQuad(32, 0, 32, 16, IMAGE:getWidth(), IMAGE:getHeight()),
    caught    = love.graphics.newQuad(64, 0, 32, 16, IMAGE:getWidth(), IMAGE:getHeight()),
}

local GRAZE_TIME_PERIOD = {1, 4}
local LISTEN_TIME_PERIOD = {2, 3}
local HIDE_TIME_PERIOD = {8, 12}
local MOVE_SPEED = 32
local FLEE_SPEED = 128

function Rat.new(x, y)
    local self = {}
    setmetatable(self, Rat)
    self.position = Vector.new(x, y)
    self.sprite = QUADS.idle
    self.grazing = true
    self.moving  = false
    self.listening = false
    self.fleeing = false
    self.hiding = false
    self.caught = false
    self.graze_timer = GRAZE_TIME_PERIOD[1] + (GRAZE_TIME_PERIOD[2] - GRAZE_TIME_PERIOD[1]) * math.random()
    self.listen_timer = 0
    self.hiding_timer = 0
    self.move_target = nil
    self.flee_target = nil
    return self
end

local function random_graze_spot(self, hiding_spots)
    local min_x = hiding_spots[1].position.x + 10
    local max_x = hiding_spots[#hiding_spots].position.x - 10
    local x = min_x + (max_x - min_x) * math.random()
    return Vector.new(x, self.position.y)
end

function Rat:die()
    self.sprite = QUADS.caught
    self.caught = true
end

function Rat:move(target)
    self.grazing = false
    self.move_target = target
    self.moving = true
end

function Rat:hide()
    self.hiding = true
    self.hiding_timer = HIDE_TIME_PERIOD[1] + (HIDE_TIME_PERIOD[2] - HIDE_TIME_PERIOD[1]) * math.random()
end

function Rat:listen()
    self.listening = true
    self.sprite = QUADS.listening
    self.listen_timer = LISTEN_TIME_PERIOD[1] + (LISTEN_TIME_PERIOD[2] - LISTEN_TIME_PERIOD[1]) * math.random()
end

function Rat:flee(player, hiding_spots)
    self.fleeing = true
    local nearest_spot
    if player.position.x >= self.position.x then
        nearest_spot = hiding_spots[1]
        local nearest_dist = (nearest_spot.position - self.position):magnitudeSquared()
        for _, spot in pairs(hiding_spots) do
            local dist = (spot.position - self.position):magnitudeSquared()
            if spot.position.x < self.position.x and dist < nearest_dist then
                nearest_spot = spot
                nearest_dist = dist
            end
        end
    else
        nearest_spot = hiding_spots[#hiding_spots]
        local nearest_dist = (nearest_spot.position - self.position):magnitudeSquared()
        for _, spot in pairs(hiding_spots) do
            local dist = (spot.position - self.position):magnitudeSquared()
            if spot.position.x >= self.position.x and dist < nearest_dist then
                nearest_spot = spot
                nearest_dist = dist
            end
        end
    end
    self.flee_target = nearest_spot.position + Vector.new(nearest_spot.size.x / 2, nearest_spot.size.y)
    if self.flee_target.x < self.position.x then
        self.flee_target.x = self.flee_target.x + nearest_spot.size.x * 0.3
    else
        self.flee_target.x = self.flee_target.x - nearest_spot.size.x * 0.3
    end
    if self.flee_target == nil then
        error("Couldn't find a hiding spot")
    end
end

function Rat:update(dt, player, hiding_spots)
    if self.hiding then
        self.hiding_timer = self.hiding_timer - dt
        if self.hiding_timer <= 0 then
            local distance = (self.position - player.position):magnitudeSquared()
            if distance > Rat.SUSPICION_RANGE ^ 2 then
                self.hiding = false
            end
        end
    elseif self.fleeing then
        local distance = (self.position - self.flee_target):magnitude()
        self.position = lerp.lerp(self.position, self.flee_target, dt * FLEE_SPEED / distance, true)
        if self.position == self.flee_target then
            self.fleeing = false
            self:hide()
        end
        return
    elseif self.listening then
        if (player.position - self.position):magnitudeSquared() < Rat.AWARENESS_RANGE ^ 2 then
            if player.last_flap == 0 or player.just_hit_ground then
                self.listening = false
                self:flee(player, hiding_spots)
            end
        end
        self.listen_timer = self.listen_timer - dt
        if self.listen_timer <= 0 then
            self.listen_timer = 0
            self.listening = false
            self.sprite = QUADS.idle
        end
        return
    elseif self.moving or self.grazing then
        if (player.position - self.position):magnitudeSquared() < Rat.AWARENESS_RANGE ^ 2 then
            if player.last_flap == 0 or player.just_hit_ground then
                self:flee(player, hiding_spots)
            end
        end
        if (player.position - self.position):magnitudeSquared() < Rat.SUSPICION_RANGE ^ 2 then
            if player.last_flap == 0 or player.just_hit_ground then
                self:listen()
            end
        end
        if self.moving then
            local distance = (self.position - self.move_target):magnitude()
            self.position = lerp.lerp(self.position, self.move_target, dt * MOVE_SPEED / distance, true)
            if self.position == self.flee_target then
                self.moving = false
            end
        end
        if self.grazing then
            self.graze_timer = self.graze_timer - dt
            if self.graze_timer <= 0 then
                self.graze_timer = 0
                self:move(random_graze_spot(self, hiding_spots))
            end
        end
    end
end


function Rat:draw()
    local _, _, w, h = self.sprite:getViewport()
    local flip = 1
    if self.flee_target and self.flee_target.x < self.position.x then
        flip = -1
    end
    if self.move_target and self.move_target.x < self.position.x then
        flip = -1
    end
    local x, y = self.position.x, self.position.y
    if self.hiding then
        x = x + (math.random()- 0.5)
    end
    love.graphics.draw(IMAGE, self.sprite, x, y, 0, flip, 1, w/2, h)
    if DEBUG and not self.caught then
        love.graphics.circle("line", x, y, Rat.SUSPICION_RANGE)
        if not self.hiding then
            love.graphics.circle("line", x, y, Rat.AWARENESS_RANGE)
        end
        love.graphics.circle("fill", x, y, 2)
        love.graphics.rectangle("line", x, y, w, h)
        if self.flee_target then
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(x, y, self.flee_target.x, self.flee_target.y)
        end
        if self.move_target then
            love.graphics.setColor(1, 1, 1)
            love.graphics.line(x, y, self.move_target.x, self.move_target.y)
        end
    end
end

return Rat
