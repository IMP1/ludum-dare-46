local controls = require 'controls'

local ParallaxManager = require 'lib.parallax_manager'
local Camera          = require 'lib.camera'
local Player          = require 'cls.player'
local Rat             = require 'cls.rat'
local HidingSpot      = require 'cls.hiding_spot'

local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

function Scene.new()
    local self = BaseScene.new("Forest")
    setmetatable(self, Scene)
    return self
end

function Scene:load()
    self.player = Player.new(-120, -120)
    self.camera = Camera.new()
    self.camera:scale(4)
    -- self.camera:setBounds(0, 0, 10000, 240)

    self.parallax_manager = ParallaxManager.new(10)
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/bg1.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 0,
        repeat_x = true,
        movement = 0,
        width    = 1920,
    })
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/midground.png"), {
        y        = 0,
        oy       = 320,
        z_index  = 5,
        repeat_x = false,
        movement = 1,
    })

    self.nest = {898, -139, 9, 6}

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
end

function Scene:keyPressed(key, isRepeat)
    local landing = false
    for _, c in pairs(controls.move_land) do
        if c == key then
            landing = true
        end
    end
    if landing then
        print("pressing R")
        local x, y = self.nest[1] + self.nest[3] / 2, self.nest[2] + self.nest[4] / 2
        local dx = x - self.player.position.x
        local dy = y - self.player.position.y
        local some_arbitrary_distance = 128
        if dx ^ 2 + dy ^ 2 < some_arbitrary_distance ^ 2 then
            -- TODO: make player land
            self.player.roosting = true
        end
    end
end

function Scene:mouseReleased(mx, my, key)

end

function Scene:update(dt, mx, my)
    self.player:update(dt)
    local x, y = unpack(self.player.position.data)
    self.camera:centreOn(x, y)
end

function Scene:draw()
    love.graphics.setColor(1, 1, 1)
    self.camera:set()
    love.graphics.setColor(0.8, 0.8, 1)
    self.parallax_manager:drawBackground()
    for _, animal in pairs(self.fauna) do
        animal:draw()
    end
    self.player:draw()
    self.parallax_manager:drawForeground()
    if DEBUG then
        love.graphics.setColor(1, 0, 0)
        love.graphics.line(0, 0, self.player.position.x, self.player.position.y)
        love.graphics.circle("fill", self.player.position.x, self.player.position.y, 3)
        love.graphics.circle("fill", self.nest[1], self.nest[2], 3)
        love.graphics.setColor(1, 0, 1)
        for _, obj in pairs(self.hiding_spots) do
            love.graphics.circle("fill", obj.position.x, obj.position.y, 2)
        end
    end
    self.camera:unset()
end

function Scene:close()

end

return Scene
