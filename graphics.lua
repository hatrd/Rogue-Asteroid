-- Graphics Assets Module
local graphics = {}

function graphics.load()
    graphics.stars = {}
    graphics.generateStarfield()
end

function graphics.generateStarfield()
    -- Generate random starfield background
    local starCount = 100
    for i = 1, starCount do
        table.insert(graphics.stars, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            brightness = math.random(0.2, 1.0),
            size = math.random(1, 3),
            twinkle = math.random() * 6.28
        })
    end
end

function graphics.updateStars(dt)
    for _, star in ipairs(graphics.stars) do
        star.twinkle = star.twinkle + dt * 2
    end
end

function graphics.drawStarfield()
    for _, star in ipairs(graphics.stars) do
        local alpha = star.brightness * (0.5 + 0.5 * math.sin(star.twinkle))
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.circle("fill", star.x, star.y, star.size * 0.5)
    end
end

function graphics.drawShip(x, y, angle, size, alpha, thrustEffect)
    alpha = alpha or 1
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Ship body (triangle)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.polygon("line", -size, -size/2, size, 0, -size, size/2)
    
    -- Ship details
    love.graphics.setColor(0.8, 0.8, 1, alpha)
    love.graphics.polygon("line", -size*0.3, -size*0.2, size*0.7, 0, -size*0.3, size*0.2)
    
    -- Cockpit
    love.graphics.setColor(0.5, 0.8, 1, alpha)
    love.graphics.circle("fill", size*0.3, 0, size*0.15)
    
    -- Engine glow when thrusting
    if thrustEffect then
        love.graphics.setColor(1, 0.5, 0, alpha * 0.8)
        love.graphics.polygon("fill", -size, -size*0.3, -size*1.5, 0, -size, size*0.3)
        love.graphics.setColor(1, 1, 0, alpha * 0.6)
        love.graphics.polygon("fill", -size, -size*0.2, -size*1.2, 0, -size, size*0.2)
    end
    
    love.graphics.pop()
end

function graphics.drawAsteroid(x, y, angle, size)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Main asteroid shape
    love.graphics.setColor(0.7, 0.6, 0.5)
    love.graphics.circle("line", 0, 0, size)
    
    -- Asteroid details (jagged edges)
    local points = {}
    local segments = 8
    for i = 0, segments do
        local a = (i / segments) * 2 * math.pi
        local variance = size * (0.8 + 0.4 * math.sin(a * 3 + angle * 2))
        table.insert(points, math.cos(a) * variance)
        table.insert(points, math.sin(a) * variance)
    end
    love.graphics.polygon("line", points)
    
    -- Inner details
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.circle("line", size*0.2, size*0.1, size*0.2)
    love.graphics.circle("line", -size*0.3, -size*0.2, size*0.15)
    
    love.graphics.pop()
end

function graphics.drawBullet(x, y, size)
    -- Glowing bullet effect
    size = size or 3
    
    -- Outer glow
    love.graphics.setColor(1, 1, 0, 0.3)
    love.graphics.circle("fill", x, y, size * 2)
    
    -- Inner bullet
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.circle("fill", x, y, size)
    
    -- Core
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", x, y, size * 0.5)
end

function graphics.drawPowerup(x, y, angle, type)
    local colors = {
        health = {1, 0, 0},
        fireRate = {1, 1, 0},
        multiShot = {0, 1, 1}
    }
    
    local color = colors[type] or {1, 1, 1}
    
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    
    -- Outer glow
    love.graphics.setColor(color[1], color[2], color[3], 0.3)
    love.graphics.circle("fill", 0, 0, 12)
    
    -- Main shape
    love.graphics.setColor(color[1], color[2], color[3], 0.8)
    love.graphics.rectangle("line", -8, -8, 16, 16)
    
    -- Inner symbol
    love.graphics.setColor(1, 1, 1, 1)
    if type == "health" then
        -- Cross
        love.graphics.rectangle("fill", -1, -6, 2, 12)
        love.graphics.rectangle("fill", -6, -1, 12, 2)
    elseif type == "fireRate" then
        -- Lightning bolt
        love.graphics.polygon("fill", -3, -6, 0, -2, -2, -1, 3, 6, 0, 2, 2, 1)
    elseif type == "multiShot" then
        -- Triple dots
        love.graphics.circle("fill", -4, 0, 1.5)
        love.graphics.circle("fill", 0, 0, 1.5)
        love.graphics.circle("fill", 4, 0, 1.5)
    end
    
    love.graphics.pop()
end

function graphics.drawExplosion(x, y, size, intensity)
    intensity = intensity or 1
    
    -- Multiple explosion rings
    for i = 1, 3 do
        local radius = size * i * 0.4
        local alpha = intensity * (1 - i * 0.3)
        
        love.graphics.setColor(1, 1 - i * 0.3, 0, alpha)
        love.graphics.circle("line", x, y, radius)
        
        -- Explosion rays
        for j = 1, 8 do
            local angle = j * math.pi / 4 + i * 0.2
            local length = radius * 1.5
            local x2 = x + math.cos(angle) * length
            local y2 = y + math.sin(angle) * length
            love.graphics.line(x, y, x2, y2)
        end
    end
end

function graphics.drawUI()
    -- UI background panels
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 220, 160)  -- Main UI panel
    
    love.graphics.setColor(0.3, 0.3, 0.5, 0.8)
    love.graphics.rectangle("line", 5, 5, 220, 160)
end

return graphics