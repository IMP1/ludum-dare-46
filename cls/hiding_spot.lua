local vec2 = require 'lib.vector2'

local hiding_spot = {}
hiding_spot.__index = hiding_spot

function hiding_spot.new(name, x, y, w, h)
    local self = {}
    setmetatable(self, hiding_spot)
    self.name = name
    self.position = vec2.new(x, y)
    self.size = vec2.new(w, h)
    return self
end

function hiding_spot:canHide(animal)

end

return hiding_spot