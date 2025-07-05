-- Sound Effects Module
local sounds = {}

function sounds.load()
    -- Create procedural sound effects using Love2D's audio
    sounds.effects = {}
    
    -- We'll use Love2D's built-in sound generation for simple effects
    -- These are placeholder functions - you can replace with actual sound files
    sounds.enabled = true
end

function sounds.play(soundName, volume, pitch)
    if not sounds.enabled then return end
    
    volume = volume or 0.5
    pitch = pitch or 1.0
    
    -- Procedural sound generation using math
    if soundName == "shoot" then
        sounds.generateShootSound(volume, pitch)
    elseif soundName == "explosion" then
        sounds.generateExplosionSound(volume, pitch)
    elseif soundName == "powerup" then
        sounds.generatePowerupSound(volume, pitch)
    elseif soundName == "hit" then
        sounds.generateHitSound(volume, pitch)
    elseif soundName == "levelup" then
        sounds.generateLevelupSound(volume, pitch)
    end
end

function sounds.generateShootSound(volume, pitch)
    -- Simple shoot sound using frequency sweep
    local duration = 0.1
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local freq = 800 * pitch * (1 - t * 3)  -- Frequency sweep down
        local amplitude = volume * 0.3 * (1 - t / duration)  -- Fade out
        local sample = math.sin(2 * math.pi * freq * t) * amplitude
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:play()
end

function sounds.generateExplosionSound(volume, pitch)
    -- Explosion sound using noise
    local duration = 0.3
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local amplitude = volume * 0.4 * (1 - t / duration)  -- Fade out
        local sample = (math.random() * 2 - 1) * amplitude  -- Noise
        -- Add some low frequency rumble
        sample = sample + math.sin(2 * math.pi * 60 * pitch * t) * amplitude * 0.5
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:play()
end

function sounds.generatePowerupSound(volume, pitch)
    -- Ascending tone for powerup
    local duration = 0.4
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local freq = 400 * pitch * (1 + t * 2)  -- Frequency sweep up
        local amplitude = volume * 0.3 * math.sin(math.pi * t / duration)  -- Bell curve
        local sample = math.sin(2 * math.pi * freq * t) * amplitude
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:play()
end

function sounds.generateHitSound(volume, pitch)
    -- Sharp hit sound
    local duration = 0.15
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local freq = 200 * pitch
        local amplitude = volume * 0.4 * math.exp(-t * 8)  -- Sharp decay
        local sample = math.sin(2 * math.pi * freq * t) * amplitude
        -- Add some noise for impact
        sample = sample + (math.random() * 2 - 1) * amplitude * 0.3
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:play()
end

function sounds.generateLevelupSound(volume, pitch)
    -- Triumphant ascending chord
    local duration = 0.6
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local amplitude = volume * 0.25 * (1 - t / duration)
        
        -- Chord: C, E, G
        local freq1 = 523 * pitch  -- C
        local freq2 = 659 * pitch  -- E
        local freq3 = 784 * pitch  -- G
        
        local sample = (math.sin(2 * math.pi * freq1 * t) +
                       math.sin(2 * math.pi * freq2 * t) +
                       math.sin(2 * math.pi * freq3 * t)) * amplitude / 3
        
        soundData:setSample(i, sample)
    end
    
    local source = love.audio.newSource(soundData)
    source:play()
end

function sounds.toggle()
    sounds.enabled = not sounds.enabled
    return sounds.enabled
end

return sounds