function love.load()
    love.window.setTitle("Rogue Asteroid")
    love.graphics.setBackgroundColor(0, 0, 0.05)
    
    -- Load assets
    sounds = require("sounds")
    graphics = require("graphics")
    
    sounds.load()
    graphics.load()
    
    -- Initialize random seed
    math.randomseed(os.time())
    
    -- Game state
    gameState = "playing"
    
    -- Player stats
    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        angle = 0,
        speed = 200,
        size = 10,
        health = 100,
        maxHealth = 100,
        level = 1,
        xp = 0,
        xpToNext = 100,
        invulnerable = 0,
        thrusting = false
    }
    
    -- Game systems
    bullets = {}
    asteroids = {}
    particles = {}
    powerups = {}
    
    -- Screen shake
    camera = {
        x = 0,
        y = 0,
        shake = 0
    }
    
    -- Game progression
    wave = 1
    enemiesKilled = 0
    score = 0
    
    -- Player upgrades
    upgrades = {
        fireRate = 1,
        bulletSpeed = 1,
        bulletDamage = 1,
        health = 1,
        speed = 1,
        multiShot = 1
    }
    
    -- Timing
    shootTimer = 0
    waveTimer = 30
    
    spawnWave()
end

function love.update(dt)
    if gameState == "playing" then
        updateGame(dt)
    elseif gameState == "levelup" then
        updateLevelUp(dt)
    end
end

function updateGame(dt)
    -- Update timers
    shootTimer = math.max(0, shootTimer - dt)
    waveTimer = waveTimer - dt
    player.invulnerable = math.max(0, player.invulnerable - dt)
    
    -- Update graphics
    graphics.updateStars(dt)
    
    -- Camera shake
    camera.shake = math.max(0, camera.shake - dt * 5)
    if camera.shake > 0 then
        camera.x = (math.random() - 0.5) * camera.shake * 10
        camera.y = (math.random() - 0.5) * camera.shake * 10
    else
        camera.x = 0
        camera.y = 0
    end
    
    -- Player movement
    local moveSpeed = player.speed * upgrades.speed
    local rotationSpeed = 4
    
    -- Reset thrusting
    player.thrusting = false
    
    -- Rotation
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.angle = player.angle - rotationSpeed * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.angle = player.angle + rotationSpeed * dt
    end
    
    -- Thrust forward
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.thrusting = true
        player.x = player.x + math.cos(player.angle) * moveSpeed * dt
        player.y = player.y + math.sin(player.angle) * moveSpeed * dt
        
        -- Thruster particles
        if math.random() < 0.3 then
            addParticle(
                player.x - math.cos(player.angle) * 15,
                player.y - math.sin(player.angle) * 15,
                -math.cos(player.angle) * 50 + (math.random() - 0.5) * 100,
                -math.sin(player.angle) * 50 + (math.random() - 0.5) * 100,
                {1, 0.5, 0}, 0.5
            )
        end
    end
    
    -- Reverse thrust
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.x = player.x - math.cos(player.angle) * moveSpeed * 0.5 * dt
        player.y = player.y - math.sin(player.angle) * moveSpeed * 0.5 * dt
    end
    
    -- Auto-fire
    if (love.keyboard.isDown("space") or love.mouse.isDown(1)) and shootTimer <= 0 then
        shoot()
        shootTimer = 0.1 / upgrades.fireRate
    end
    
    -- Wrap player around screen
    if player.x < 0 then
        player.x = love.graphics.getWidth()
    elseif player.x > love.graphics.getWidth() then
        player.x = 0
    end
    if player.y < 0 then
        player.y = love.graphics.getHeight()
    elseif player.y > love.graphics.getHeight() then
        player.y = 0
    end
    
    -- Update bullets
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        if bullet then
            bullet.x = bullet.x + bullet.vx * dt
            bullet.y = bullet.y + bullet.vy * dt
            bullet.life = bullet.life - dt
            
            if bullet.life <= 0 then
                table.remove(bullets, i)
            end
        end
    end
    
    -- Limit bullet count
    if #bullets > 200 then
        for i = 1, 50 do
            if #bullets > 0 then
                table.remove(bullets, 1)
            end
        end
    end
    
    -- Update asteroids
    for i = 1, #asteroids do
        local asteroid = asteroids[i]
        if asteroid then
            asteroid.x = asteroid.x + asteroid.vx * dt
            asteroid.y = asteroid.y + asteroid.vy * dt
            asteroid.angle = asteroid.angle + asteroid.rotation * dt
            
            -- Wrap asteroids around screen
            if asteroid.x < -asteroid.size then
                asteroid.x = love.graphics.getWidth() + asteroid.size
            elseif asteroid.x > love.graphics.getWidth() + asteroid.size then
                asteroid.x = -asteroid.size
            end
            if asteroid.y < -asteroid.size then
                asteroid.y = love.graphics.getHeight() + asteroid.size
            elseif asteroid.y > love.graphics.getHeight() + asteroid.size then
                asteroid.y = -asteroid.size
            end
        end
    end
    
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        if p then
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.life = p.life - dt
            p.vx = p.vx * 0.98
            p.vy = p.vy * 0.98
            
            if p.life <= 0 then
                table.remove(particles, i)
            end
        end
    end
    
    -- Limit particle count
    if #particles > 300 then
        for i = 1, 100 do
            if #particles > 0 then
                table.remove(particles, 1)
            end
        end
    end
    
    -- Update powerups
    for i = #powerups, 1, -1 do
        local powerup = powerups[i]
        if powerup then
            powerup.life = powerup.life - dt
            powerup.angle = powerup.angle + dt * 2
            
            if powerup.life <= 0 then
                table.remove(powerups, i)
            end
        end
    end
    
    -- Check bullet-asteroid collisions
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        if bullet then
            for j = #asteroids, 1, -1 do
                local asteroid = asteroids[j]
                if asteroid then
                    local distance = math.sqrt((bullet.x - asteroid.x)^2 + (bullet.y - asteroid.y)^2)
                    
                    if distance < asteroid.size then
                        table.remove(bullets, i)
                        
                        -- Play explosion sound
                        sounds.play("explosion", 0.6, 0.8 + math.random() * 0.4)
                        
                        -- Create explosion particles
                        for k = 1, 5 do
                            addParticle(
                                asteroid.x, asteroid.y,
                                (math.random() - 0.5) * 200,
                                (math.random() - 0.5) * 200,
                                {0.8, 0.8, 0.8}, 0.8
                            )
                        end
                        
                        -- Screen shake
                        camera.shake = 0.2
                        
                        -- Split asteroid or remove
                        if asteroid.size > 15 and #asteroids < 30 then
                            for k = 1, 2 do
                                table.insert(asteroids, {
                                    x = asteroid.x + math.random(-20, 20),
                                    y = asteroid.y + math.random(-20, 20),
                                    vx = math.random(-100, 100),
                                    vy = math.random(-100, 100),
                                    size = asteroid.size * 0.6,
                                    angle = 0,
                                    rotation = math.random(-3, 3)
                                })
                            end
                        end
                        
                        table.remove(asteroids, j)
                        enemiesKilled = enemiesKilled + 1
                        score = score + math.floor(50 / asteroid.size * 10)
                        
                        -- Gain XP
                        gainXP(10)
                        
                        -- Chance to drop powerup
                        if math.random() < 0.1 then
                            spawnPowerup(asteroid.x, asteroid.y)
                        end
                        
                        break
                    end
                end
            end
        end
    end
    
    -- Check player-asteroid collisions
    if player.invulnerable <= 0 then
        for i, asteroid in ipairs(asteroids) do
            if asteroid then
                local distance = math.sqrt((player.x - asteroid.x)^2 + (player.y - asteroid.y)^2)
                if distance < asteroid.size + player.size then
                    takeDamage(20)
                    player.invulnerable = 1
                    camera.shake = 0.5
                    sounds.play("hit", 0.8, 1.0)
                    break
                end
            end
        end
    end
    
    -- Check player-powerup collisions
    for i = #powerups, 1, -1 do
        local powerup = powerups[i]
        if powerup then
            local distance = math.sqrt((player.x - powerup.x)^2 + (player.y - powerup.y)^2)
            if distance < 20 then
                applyPowerup(powerup.type)
                sounds.play("powerup", 0.5, 1.0)
                table.remove(powerups, i)
            end
        end
    end
    
    -- Wave management
    if #asteroids == 0 or waveTimer <= 0 then
        wave = wave + 1
        waveTimer = 30
        spawnWave()
    end
    
    -- Check game over
    if player.health <= 0 then
        gameState = "dead"
    end
end

function updateLevelUp(dt)
    -- Handle level up selection
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(camera.x, camera.y)
    
    if gameState == "playing" then
        drawGame()
    elseif gameState == "levelup" then
        drawLevelUp()
    elseif gameState == "dead" then
        drawGameOver()
    end
    
    love.graphics.pop()
end

function drawGame()
    -- Draw starfield background
    graphics.drawStarfield()
    
    -- Draw UI background
    graphics.drawUI()
    
    -- Draw particles
    for _, p in ipairs(particles) do
        if p then
            local alpha = p.life / p.maxLife
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            love.graphics.circle("fill", p.x, p.y, 2)
        end
    end
    
    -- Draw player with enhanced graphics
    local alpha = 1
    if player.invulnerable > 0 then
        alpha = math.sin(player.invulnerable * 20) * 0.5 + 0.5
    end
    graphics.drawShip(player.x, player.y, player.angle, player.size, alpha, player.thrusting)
    
    -- Draw bullets with enhanced graphics
    for _, bullet in ipairs(bullets) do
        if bullet then
            graphics.drawBullet(bullet.x, bullet.y, 3)
        end
    end
    
    -- Draw asteroids with enhanced graphics
    for _, asteroid in ipairs(asteroids) do
        if asteroid then
            graphics.drawAsteroid(asteroid.x, asteroid.y, asteroid.angle, asteroid.size)
        end
    end
    
    -- Draw powerups with enhanced graphics
    for _, powerup in ipairs(powerups) do
        if powerup then
            graphics.drawPowerup(powerup.x, powerup.y, powerup.angle, powerup.type)
        end
    end
    
    -- UI Text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Wave: " .. wave, 10, 30)
    love.graphics.print("Level: " .. player.level, 10, 50)
    
    -- Health bar
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, 70, 200 * (player.health / player.maxHealth), 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 10, 70, 200, 10)
    love.graphics.print("HP: " .. player.health .. "/" .. player.maxHealth, 10, 85)
    
    -- XP bar
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 10, 105, 200 * (player.xp / player.xpToNext), 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 10, 105, 200, 10)
    love.graphics.print("XP: " .. player.xp .. "/" .. player.xpToNext, 10, 120)
    
    -- Wave timer
    love.graphics.print("Next wave: " .. math.ceil(waveTimer), 10, 140)
    love.graphics.print("WASD/Arrows: Move, Space/Mouse: Shoot, M: Toggle Sound", 10, love.graphics.getHeight() - 30)
end

function drawLevelUp()
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("LEVEL UP!", 0, 200, love.graphics.getWidth(), "center")
    love.graphics.printf("Choose an upgrade:", 0, 250, love.graphics.getWidth(), "center")
    
    local upgradeNames = {"Fire Rate", "Bullet Speed", "Multi-Shot", "Health", "Speed"}
    local maxValues = {5, 3, 10, 200, 2}
    local currentValues = {upgrades.fireRate, upgrades.bulletSpeed, upgrades.multiShot, player.maxHealth, upgrades.speed}
    
    for i, upgrade in ipairs(upgradeNames) do
        local isMaxed = currentValues[i] >= maxValues[i]
        if isMaxed then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.printf(i .. ". " .. upgrade .. " (MAX)", 0, 280 + i * 30, love.graphics.getWidth(), "center")
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(i .. ". " .. upgrade .. " (" .. string.format("%.1f", currentValues[i]) .. ")", 0, 280 + i * 30, love.graphics.getWidth(), "center")
        end
    end
end

function drawGameOver()
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("GAME OVER", 0, 250, love.graphics.getWidth(), "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. score, 0, 300, love.graphics.getWidth(), "center")
    love.graphics.printf("Press R to restart", 0, 350, love.graphics.getWidth(), "center")
end

function love.keypressed(key)
    if gameState == "playing" then
        if key == "p" then
            gameState = "paused"
        elseif key == "m" then
            local enabled = sounds.toggle()
            -- Could add a visual indicator here
        end
    elseif gameState == "levelup" then
        local num = tonumber(key)
        if num and num >= 1 and num <= 5 then
            -- Check if upgrade is maxed out
            local maxValues = {5, 3, 10, 200, 2}
            local currentValues = {upgrades.fireRate, upgrades.bulletSpeed, upgrades.multiShot, player.maxHealth, upgrades.speed}
            
            if currentValues[num] < maxValues[num] then
                applyUpgrade(num)
                gameState = "playing"
            end
        end
    elseif gameState == "dead" then
        if key == "r" then
            love.load()
        end
    end
end

function shoot()
    local bullets_to_fire = math.min(upgrades.multiShot, 10)
    local spread = 0.2
    
    -- Play shoot sound
    sounds.play("shoot", 0.3, 0.9 + math.random() * 0.2)
    
    for i = 1, bullets_to_fire do
        local angle = player.angle
        if bullets_to_fire > 1 then
            angle = angle + (i - (bullets_to_fire + 1) / 2) * spread
        end
        
        table.insert(bullets, {
            x = player.x + math.cos(angle) * 15,
            y = player.y + math.sin(angle) * 15,
            vx = math.cos(angle) * 500 * upgrades.bulletSpeed,
            vy = math.sin(angle) * 500 * upgrades.bulletSpeed,
            life = 3
        })
    end
end

function spawnWave()
    local asteroidCount = math.min(3 + wave * 2, 15)
    for i = 1, asteroidCount do
        table.insert(asteroids, createAsteroid())
    end
end

function createAsteroid()
    local x, y
    local attempts = 0
    repeat
        x = math.random(0, love.graphics.getWidth())
        y = math.random(0, love.graphics.getHeight())
        attempts = attempts + 1
    until math.sqrt((x - player.x)^2 + (y - player.y)^2) > 150 or attempts > 20
    
    return {
        x = x,
        y = y,
        vx = math.random(-100, 100),
        vy = math.random(-100, 100),
        size = math.random(20, 40),
        angle = 0,
        rotation = math.random(-2, 2)
    }
end

function addParticle(x, y, vx, vy, color, life)
    table.insert(particles, {
        x = x, y = y, vx = vx, vy = vy,
        color = color, life = life, maxLife = life
    })
end

function spawnPowerup(x, y)
    local types = {"health", "fireRate", "multiShot"}
    local type = types[math.random(#types)]
    local colors = {
        health = {1, 0, 0},
        fireRate = {1, 1, 0},
        multiShot = {0, 1, 1}
    }
    
    table.insert(powerups, {
        x = x, y = y, type = type,
        color = colors[type],
        angle = 0, life = 10
    })
end

function applyPowerup(type)
    if type == "health" then
        player.health = math.min(player.maxHealth, player.health + 25)
    elseif type == "fireRate" then
        upgrades.fireRate = math.min(upgrades.fireRate + 0.5, 5)
    elseif type == "multiShot" then
        upgrades.multiShot = math.min(upgrades.multiShot + 1, 10)
    end
end

function gainXP(amount)
    player.xp = player.xp + amount
    if player.xp >= player.xpToNext then
        player.xp = player.xp - player.xpToNext
        player.level = player.level + 1
        player.xpToNext = player.xpToNext + 50
        sounds.play("levelup", 0.7, 1.0)
        gameState = "levelup"
    end
end

function applyUpgrade(choice)
    if choice == 1 then
        upgrades.fireRate = math.min(upgrades.fireRate + 0.3, 5)
    elseif choice == 2 then
        upgrades.bulletSpeed = math.min(upgrades.bulletSpeed + 0.2, 3)
    elseif choice == 3 then
        upgrades.multiShot = math.min(upgrades.multiShot + 1, 10)
    elseif choice == 4 then
        player.maxHealth = math.min(player.maxHealth + 20, 200)
        player.health = player.maxHealth
    elseif choice == 5 then
        upgrades.speed = math.min(upgrades.speed + 0.2, 2)
    end
end

function takeDamage(amount)
    player.health = player.health - amount
    for i = 1, 10 do
        addParticle(
            player.x, player.y,
            (math.random() - 0.5) * 200,
            (math.random() - 0.5) * 200,
            {1, 0, 0}, 0.8
        )
    end
end