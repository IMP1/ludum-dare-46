local BaseScene = require 'scn._base'
local Scene = {}
setmetatable(Scene, BaseScene)
Scene.__index = Scene

function Scene.new()
    local self = BaseScene.new("Loss")
    setmetatable(self, Scene)
    return self
end

return Scene
