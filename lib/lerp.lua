local lerp = {}

function lerp.lerp(a, b, t, clamp)
    if clamp then
        if t < 0 then
            return a
        elseif t > 1 then
            return b
        end
    end
    return a + (b - a) * t
end

return lerp