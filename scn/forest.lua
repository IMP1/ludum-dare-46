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
        y        = 240,
        oy       = 640,
        z_index  = 0,
        repeat_x = true,
        movement = 0,
        width    = 1920,
    })
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/midground.png"), {
        y        = 240,
        oy       = 640,
        z_index  = 5,
        repeat_x = false,
        movement = 1,
    })

    self.nest = {}
    self.hiding_spots = {
        HidingSpot.new("Hole",  162, 279, 6, 5),
        HidingSpot.new("Stick", 298, 272, 19, 6),
        HidingSpot.new("Rock",  377, 271, 11, 8),
        HidingSpot.new("Rock",  386, 262, 20, 15),
        HidingSpot.new("Log",   747, 265, 22, 12),
        HidingSpot.new("Rock",  1060, 262, 17, 12),
        HidingSpot.new("Hole",  1335, 271, 7, 6),
        HidingSpot.new("Rock",  1536, 264, 20, 15),
        HidingSpot.new("Stick", 1771, 270, 22, 7),
    }
    self.fauna = {}
    table.insert(self.fauna, Rat.new(0, 0))
end

function Scene:keyPressed(key, isRepeat)

end

function Scene:mouseReleased(mx, my, key)

end

function Scene:update(dt, mx, my)
    self.player:update(dt)
    local x, y = unpack(self.player.position.data)
    self.camera:centreOn(x, y)
end

function Scene:draw()
    self.camera:set()
    self.parallax_manager:drawBackground()
    for _, animal in pairs(self.fauna) do
        animal:draw()
    end
    self.player:draw()
    self.parallax_manager:drawForeground()
    self.camera:unset()
end

function Scene:close()

end

return Scene
