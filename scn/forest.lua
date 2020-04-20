local controls = require 'controls'
local lerp     = require 'lib.lerp'

local Vector          = require 'lib.vector2'
local ParallaxManager = require 'lib.parallax_manager'
local Camera          = require 'lib.camera'
local Player          = require 'cls.player'
local Rat             = require 'cls.rat'
local HidingSpot      = require 'cls.hiding_spot'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

local CAMERA_SNAP = 3
local SOUNDS = {
    hit_ground = love.audio.newSource("sfx/floof.ogg", "static"),
    chewing = love.audio.newSource("sfx/chewing.ogg", "static"),
    catch = love.audio.newSource("sfx/catch.ogg", "static"),
}

local SHADOW_MASK = love.graphics.newShader([[
    vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        if (Texel(texture, texture_coords).a == 0)
        {
            discard;
        }
        return vec4(1.0);
    }
]])
local NEST_ARROW_IMAGE = love.graphics.newImage("gfx/nest_indicator.png")
local NEST_ARROWS = {
    love.graphics.newQuad(1, 1, 4, 5, 32, 32),  -- left
    love.graphics.newQuad(23, 1, 5, 5, 32, 32), -- up_left
    love.graphics.newQuad(17, 1, 5, 4, 32, 32), -- up
    love.graphics.newQuad(1, 7, 5, 5, 32, 32),  -- up_right
    love.graphics.newQuad(6, 1, 4, 5, 32, 32),  -- right
    love.graphics.newQuad(13, 7, 5, 5, 32, 32), -- down_right
    love.graphics.newQuad(11, 2, 5, 4, 32, 32), -- down
    love.graphics.newQuad(7, 7, 5, 5, 32, 32),  -- down_left
}

local ROOST_DISTANCE = 32
local SWOOP_SLOWDOWN = 4

function Scene.new()
    local self = BaseScene.new("Forest")
    setmetatable(self, Scene)
    return self
end

function Scene:load()
    love.graphics.setBackgroundColor(34/255,32/255,52/255)
    self.camera = Camera.new()
    self.camera:scale(4)
    self.camera:setBounds(0, -500, 1920 - 240, -160)

    self.parallax_manager = ParallaxManager.new(10)
    -- TODO: Add background layers
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/bg1.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 0,
        repeat_x = true,
        pad_y    = true,
        movement = 1,
        width    = 1920,
    })
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/midground.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 10,
        repeat_x = false,
        movement = 1,
        tint     = {0.7, 0.8, 1},
    })
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/objects.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 11,
        repeat_x = false,
        movement = 1,
        tint     = {0.7, 0.8, 1},
    })

    self.nest = {898, -139, 9, 6}
    self.roost_spot = {self.nest[1] + 10, self.nest[2] - 2}

    self.hiding_spots = {
        HidingSpot.new("Hole",  162,  -26, 6, 5),
        HidingSpot.new("Stick", 298,  -33, 19, 6),
        HidingSpot.new("Rock",  377,  -34, 11, 8),
        HidingSpot.new("Rock",  386,  -43, 20, 15),
        HidingSpot.new("Log",   747,  -40, 22, 12),
        HidingSpot.new("Rock",  1060, -43, 17, 12),
        HidingSpot.new("Hole",  1335, -34, 7, 6),
        HidingSpot.new("Rock",  1536, -41, 20, 15),
        HidingSpot.new("Stick", 1771, -35, 22, 7),
    }

    self.fauna = {}
    table.insert(self.fauna, Rat.new(500, -20))

    self.player = Player.new(0, 0)
    self.player:roost(self.roost_spot[1], self.roost_spot[2])
    self.camera:centreOn(self.player.position.x, self.player.position.y)
    self.owlet_hunger = 0

    TUTORIAL.timers.movement = 0
end

function Scene:keyPressed(key, isRepeat)
    local landing = false
    for _, c in pairs(controls.move_land) do
        if c == key then
            landing = true
        end
    end
    if landing then
        local x, y = self.nest[1] + self.nest[3] / 2, self.nest[2] + self.nest[4] / 2
        local dx = x - self.player.position.x
        local dy = y - self.player.position.y
        if dx ^ 2 + dy ^ 2 < ROOST_DISTANCE ^ 2 then
            self.player:roost(self.roost_spot[1], self.roost_spot[2])
            if self.player.carried_prey then
                self.player.carried_prey = nil
                SOUNDS.chewing:play()
                -- TODO: lower hunger
            end
        end
    end
    local taking_off = false
    for _, c in pairs(controls.move_up) do 
        if c == key then taking_off = true end
    end
    for _, c in pairs(controls.move_left) do 
        if c == key then taking_off = true end
    end
    for _, c in pairs(controls.move_down) do 
        if c == key then taking_off = true end
    end
    for _, c in pairs(controls.move_right) do 
        if c == key then taking_off = true end
    end
    if taking_off then
        self.player.roosting = false
    end
end

function Scene:mouseReleased(mx, my, key)

end

function Scene:updatePlayer(dt)
    self.player:update(dt)
    if self.player.position.y > -30 and self.player.velocity.y > 0 then
        SOUNDS.hit_ground:play()
        self.player.position.y = math.min(self.player.position.y, -29)
        self.player.velocity.y = -self.player.velocity.y
        local speed = self.player.velocity:magnitude()
        self.player.velocity = self.player.velocity:normalise() * speed * 0.2
        self.player.just_hit_ground = true
    end
    if self.player.position.y < -350 and self.player.velocity.y < 0 then
        self.player.velocity.y = -self.player.velocity.y * 0.1
    end
    if self.player.position.x < 170 then
        self.player:accelerate(dt, Vector.new(2, 0))
    end
    if self.player.position.x > 1780 then
        self.player:accelerate(dt, Vector.new(-2, 0))
    end
    if self.player.swooping and #self.fauna > 0 then
        local animal_index   = 1
        local nearest_animal = self.fauna[animal_index]
        local nearest_dist   = (nearest_animal.position - self.player.position):magnitudeSquared()
        for i, animal in pairs(self.fauna) do
            local dist = (animal.position - self.player.position):magnitudeSquared()
            if dist < nearest_dist and not animal.hiding then
                nearest_animal = animal
                nearest_dist = dist
                animal_index = i
            end
        end
        if nearest_dist < Player.CATCH_DISTANCE ^ 2 and not nearest_animal.hiding then
            table.remove(self.fauna, animal_index)
            self.player:catch(nearest_animal)
            nearest_animal:die()
            SOUNDS.catch:play()
        end
    end
    if self.player.roosting then
        local cam_x, cam_y = self.camera:getCentre()
        local cam_vec = self.player.position - Vector.new(cam_x, cam_y)
        local cam_move = lerp.lerp(Vector.new(0, 0), cam_vec, dt * CAMERA_SNAP, true)
        self.camera:move(cam_move.x, cam_move.y)
    else
        self.camera:centreOn(self.player.position.x, self.player.position.y)
    end
end

function Scene:update(dt)
    if self.player.swooping then
        dt = dt / SWOOP_SLOWDOWN
    end
    self:updatePlayer(dt)
    for _, animal in pairs(self.fauna) do
        animal:update(dt, self.player, self.hiding_spots)
    end
    -- TODO: Spawn of rats
end

function Scene:drawPlayer()
    if self.player.position.y > -100 then
        -- draw player shadow 
        local dist = (self.player.position.y + 100) / 70
        local x = self.player.position.x
        local y = self.player.position.y
        local opacity = 0.5 * dist
        local size = 1 / dist
        love.graphics.stencil(function() 
            love.graphics.setShader(SHADOW_MASK)
            self.parallax_manager:drawMidground()
            love.graphics.setShader()
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(0, 0, 0, opacity)
        local _, _, w, h = self.player.sprite:getViewport()
        local flip = 1
        if self.player.velocity.x < 0 then
            flip = -1
        end
        love.graphics.draw(Player.IMAGE, self.player.sprite, x, -30, 0, flip * size, size, w/2, h/2)
        love.graphics.setStencilTest()
    end
    love.graphics.setColor(1, 1, 1)
    self.player:draw()
end

function Scene:drawNestIndicator()
    local nest_position = Vector.new(self.nest[1], self.nest[2])
    local dist = 64
    local dir = nest_position - self.player.position
    if dir:magnitudeSquared() > dist ^ 2 then
        local midpoint = (nest_position + self.player.position) / 2
        midpoint.x = math.max(self.player.position.x - 100, math.min(self.player.position.x + 100, midpoint.x))
        midpoint.y = math.max(self.player.position.y - 50, math.min(self.player.position.y + 50, midpoint.y))
        local angle = math.floor((((math.atan2(dir.y, dir.x) / math.pi) + 1) * 4) + 0.5) % 8
        local arrow = NEST_ARROWS[angle + 1]
        love.graphics.draw(NEST_ARROW_IMAGE, arrow, midpoint.x, midpoint.y)
    end
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1)
    self.camera:set()
    self.parallax_manager:drawBackground()
    self.parallax_manager:drawMidground()
    for _, animal in pairs(self.fauna) do
        animal:draw()
    end
    self:drawPlayer()
    self.parallax_manager:drawForeground()
    self:drawNestIndicator()
    if TUTORIAL.timers.movement and TUTORIAL.timers.movement > 4 and not TUTORIAL.movement_displayed then
        love.graphics.printf("Use WASD or the Arrow keys to move.", self.player.position.x - 500, self.player.position.y - 24, 1000, "center")
    end
    if DEBUG then
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.print(tostring(self.player.position), 0, 0)
        love.graphics.print(tostring(self.player.last_flap), 0, 16)
        love.graphics.pop()
        love.graphics.circle("line", self.roost_spot[1], self.roost_spot[2], ROOST_DISTANCE)
        for _, obj in pairs(self.hiding_spots) do
            love.graphics.rectangle("line", obj.position.x, obj.position.y, obj.size.x, obj.size.y)
        end
        love.graphics.circle("line", self.player.position.x, self.player.position.y, Player.CATCH_DISTANCE)
    end
    self.camera:unset()
end

function Scene:close()

end

return Scene
