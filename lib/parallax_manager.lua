local ParallaxManager = {}
ParallaxManager.__index = ParallaxManager

function ParallaxManager.new()
    local self = {}
    setmetatable(self, ParallaxManager)
    self.layers = {}
    return self
end

function ParallaxManager:add_layer(image, options)
    local layer = {}
    layer.image   = image
    local wrap_horz = "clampzero"
    local wrap_vert = "clampzero"
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
    layer.z_index = options.z_index or 0

    local index = (#self.layers + 1)
    for i, l in ipairs(self.layers) do
        if l.z_index > layer.z_index then
            index = i
            break
        end
    end
    print(index)
    table.insert(self.layers, index, layer)
end

function ParallaxManager:drawBackground()
    for _, layer in ipairs(self.layers) do
        if layer.z_index <= 0 then
            love.graphics.draw(layer.image, layer.quad, layer.x, layer.y)
        end
    end
end

function ParallaxManager:drawForeground()
    for _, layer in ipairs(self.layers) do
        if layer.z_index > 0 then
            local scale = 1
            love.graphics.draw(layer.image, layer.quad, layer.x, layer.y, 0, scale, scale, layer.ox, layer.oy)
        end
    end
end

return ParallaxManager