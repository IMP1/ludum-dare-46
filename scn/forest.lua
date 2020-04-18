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
    
end

function Scene:keyPressed(key, isRepeat)

end


function Scene:keyReleased(key, isRepeat)

end

function Scene:mousePressed(mx, my, key)

end

function Scene:mouseReleased(mx, my, key)

end

function Scene:update(dt, mx, my)

end

function Scene:draw()

end

function Scene:close()

end

return Scene
