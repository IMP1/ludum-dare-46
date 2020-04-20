local ParallaxManager = {}
ParallaxManager.__index = ParallaxManager

function ParallaxManager.new(midground_index)
    local self = {}
    setmetatable(self, ParallaxManager)
    self.layers = {}
    self.midground_index = (midground_index or 0)
    return self
end

function ParallaxManager:add_layer(image, options)
    local layer = {}
    layer.image   = image
    local wrap_horz = "clampzero"
    local wrap_vert = "clampzero"
    if options.pad_x then
        wrap_horz = "clamp"
    end
    if options.pad_y then
        wrap_vert = "clamp"
    end
    if options.repeat_x then
        wrap_horz = "repeat"
    end
    if options.repeat_y then
        wrap_vert = "repeat"
    end
    layer.image:setWrap(wrap_horz, wrap_vert)
    layer.x       = options.x or 0
    layer.y       = options.y or 0
    layer.ox      = options.ox or 0
    layer.oy      = options.oy or 0
    layer.width   = options.width or image:getWidth()
    layer.height  = options.height or image:getHeight()
    layer.quad    = love.graphics.newQuad(0, 0, layer.width, layer.height, image:getWidth(), image:getHeight())
    layer.z_index = options.z_index or self.midground_index
    layer.tint    = options.tint or {1, 1, 1}

    local index = (#self.layers + 1)
    for i, l in ipairs(self.layers) do
        if l.z_index > layer.z_index then
            index = i
            break
        end
    end
    table.insert(self.layers, index, layer)
end

function ParallaxManager:drawBackground()
    for _, layer in ipairs(self.layers) do
        if layer.z_index < self.midground_index then
            local scale = 1
            love.graphics.setColor(layer.tint)
            love.graphics.draw(layer.image, layer.quad, layer.x, layer.y, 0, scale, scale, layer.ox, layer.oy)
        end
    end
end

function ParallaxManager:drawMidground()
    for _, layer in ipairs(self.layers) do
        if layer.z_index == self.midground_index then
            local scale = 1
            love.graphics.setColor(layer.tint)
            love.graphics.draw(layer.image, layer.quad, layer.x, layer.y, 0, scale, scale, layer.ox, layer.oy)
        end
    end
end


function ParallaxManager:drawForeground()
    for _, layer in ipairs(self.layers) do
        if layer.z_index > self.midground_index then
            local scale = 1
            love.graphics.setColor(layer.tint)
            love.graphics.draw(layer.image, layer.quad, layer.x, layer.y, 0, scale, scale, layer.ox, layer.oy)
        end
    end
end

return ParallaxManager