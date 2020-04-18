local ParallaxManager = require 'lib.parallax_manager'
local Camera          = require 'lib.camera'
local Player          = require 'cls.player'

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
    self.player = Player.new(0, -120)
    self.camera = Camera.new()
    self.camera:setBounds(0, 0, 10000, 240)

    self.parallax_manager = ParallaxManager.new()
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/bg1.png"), {
        y        = 0,
        z_index  = 0,
        repeat_x = true,
        movement = 0,
        width    = 960,
        oy       = 240,
    })
    self.parallax_manager:add_layer(love.graphics.newImage("gfx/tree1.png"), {
        y        = 240,
        z_index  = 5,
        repeat_x = true,
        movement = 0.1,
        width    = 960,
    })
end

function Scene:keyPressed(key, isRepeat)

end

function Scene:mouseReleased(mx, my, key)

end

function Scene:update(dt, mx, my)
    self.player:update(dt)
    local x, y = unpack(self.player.position)
    self.camera:centreOn(x, y)
end

function Scene:draw()
    self.camera:set()
    self.parallax_manager:drawBackground()
    self.player:draw()
    self.parallax_manager:drawForeground()
    self.camera:unset()
end

function Scene:close()

end

return Scene
