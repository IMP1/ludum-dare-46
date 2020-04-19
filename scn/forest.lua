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
    hit_ground = love.audio.newSource("sfx/floof.ogg", "static")
}

local BACKGROUND = love.graphics.newImage("gfx/bg1.png")
local BACKGROUND_LOOP = love.graphics.newQuad(0, 0, 1920, BACKGROUND:getHeight(), BACKGROUND:getWidth(), BACKGROUND:getHeight())
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

function Scene.new()
    local self = BaseScene.new("Forest")
    setmetatable(self, Scene)
    return self
end

function Scene:load()
    love.graphics.setBackgroundColor(34/255,32/255,52/255)
    self.camera = Camera.new()
    self.camera:scale(4)
    -- self.camera:setBounds(0, 0, 10000, 240)

    self.parallax_manager = ParallaxManager.new(10)
    -- TODO: Add background layers
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/midground.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 5,
        repeat_x = false,
        movement = 1,
        tint     = {0.7, 0.8, 1},
    })
    -- TODO: Add foreground layer

    self.nest = {898, -139, 9, 6}
    self.roost_spot = {self.nest[1] + 10, self.nest[2] - 2}

    self.hiding_spots = {
        HidingSpot.new("Hole",  162,  -41, 6, 5),
        HidingSpot.new("Stick", 298,  -48, 19, 6),
        HidingSpot.new("Rock",  377,  -49, 11, 8),
        HidingSpot.new("Rock",  386,  -58, 20, 15),
        HidingSpot.new("Log",   747,  -55, 22, 12),
        HidingSpot.new("Rock",  1060, -58, 17, 12),
        HidingSpot.new("Hole",  1335, -49, 7, 6),
        HidingSpot.new("Rock",  1536, -56, 20, 15),
        HidingSpot.new("Stick", 1771, -50, 22, 7),
    }

    self.fauna = {}
    table.insert(self.fauna, Rat.new(0, 0))

    self.player = Player.new(0, 0)
    self.player:roost(self.roost_spot[1], self.roost_spot[2])
    self.camera:centreOn(self.player.position.x, self.player.position.y)
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
        local some_arbitrary_distance = 128
        if dx ^ 2 + dy ^ 2 < some_arbitrary_distance ^ 2 then
            self.player:roost(self.roost_spot[1], self.roost_spot[2])
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

function Scene:update(dt, mx, my)
    self.player:update(dt)
    if self.player.position.y > -30 and self.player.velocity.y > 0 then
        SOUNDS.hit_ground:play()
        self.player.position.y = math.min(self.player.position.y, -29)
        self.player.velocity.y = -self.player.velocity.y
        local speed = self.player.velocity:magnitude()
        self.player.velocity = self.player.velocity:normalise() * speed * 0.2
    end
    if self.player.position.y < -350 and self.player.velocity.y < 0 then
        self.player.velocity.y = -self.player.velocity.y * 0.1
    end
    local x, y = unpack(self.player.position.data)
    if self.player.roosting then
        local cam_x, cam_y = self.camera:getCentre()
        local cam_vec = self.player.position - Vector.new(cam_x, cam_y)
        local cam_move = lerp.lerp(Vector.new(0, 0), cam_vec, dt * CAMERA_SNAP, true)
        self.camera:move(cam_move.x, cam_move.y)
    else
        self.camera:centreOn(x, y)
    end
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1)
    self.camera:set()
    love.graphics.draw(BACKGROUND, BACKGROUND_LOOP, 0, 0, 0, 1, 1, 0, 320)
    -- self.parallax_manager:add_layer(BACKGROUND, {
        -- y        = 0,
        -- oy       = 320,
        -- z_index  = 0,
        -- repeat_x = true,
        -- pad_y    = true,
        -- movement = 0,
        -- width    = 1920,
    -- })
    self.parallax_manager:drawBackground()
    for _, animal in pairs(self.fauna) do
        animal:draw()
    end
    if self.player.position.y > -100 then
        -- draw player shadow 
        local dist = (self.player.position.y + 100) / 70
        local x = self.player.position.x
        local y = self.player.position.y
        local opacity = 0.5 * dist
        local size = 11 / dist
        love.graphics.stencil(function() 
            love.graphics.setShader(SHADOW_MASK)
            self.parallax_manager:drawBackground()
            love.graphics.setShader()
        end, "replace", 1)
        love.graphics.setColor(0, 0, 0, opacity)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.ellipse("fill", x, -30, size, size / 3)
        love.graphics.setStencilTest()
    end
    love.graphics.setColor(1, 1, 1)
    self.player:draw()
    self.parallax_manager:drawForeground()
    if DEBUG then
        love.graphics.setColor(1, 1, 1)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.print(tostring(self.player.position), 0, 0)
        love.graphics.pop()
        -- love.graphics.line(0, 0, self.player.position.x, self.player.position.y)
        -- love.graphics.circle("fill", self.player.position.x, self.player.position.y, 3)
        -- love.graphics.setColor(1, 0, 0)
        -- love.graphics.circle("fill", self.nest[1], self.nest[2], 3)
        -- love.graphics.setColor(1, 0, 1)
        -- for _, obj in pairs(self.hiding_spots) do
            -- love.graphics.circle("fill", obj.position.x, obj.position.y, 2)
        -- end
    end
    self.camera:unset()
end

function Scene:close()

end

return Scene
