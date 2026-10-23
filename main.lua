local Game = {
    width = 1280,
    height = 720,
    state = "menu",
    selectedCharacter = 1,
    level = 1,
    coins = 0,
    timeLeft = 35,
    paused = false,
    animationTime = 0,
    countdown = 0,
    countdownMode = "level",
    menuIndex = 1,
    musicEnabled = true,
    creditsTime = 0,
    endingTime = 0,
    bossTime = 0,
    settingsIndex = 1,
    abilityCooldown = 0,
    playModeIndex = 1,
    playMode = "campaign",
    mode = "campaign",
    infiniteRound = 1,
    infiniteGoal = 0,
    uiTime = 0,
}

local assets = {}
local spriteBounds = {}
local player
local player2
local coins = {}
local saws = {}
local boss
local bossSaws = {}
local bossSpawnTimer = 0
local gamepad
local gamepadSelectionRepeat = 0

local GAMEPAD_DEADZONE = 0.2
local MENU_ITEMS = {"JOGAR", "CONFIGURACOES", "CREDITOS", "SAIR"}
local PLAY_MODE_ITEMS = {"HISTORIA", "INFINITO", "2 JOGADORES", "VOLTAR"}
local SETTINGS_ITEMS = {"MUSICA", "TELA CHEIA", "TECLAS", "CONTROLADOR", "VOLTAR"}
local CREDITS = {
    "Antony Rafael",
    "Wallace Pedroso",
    "Vitor Presot",
    "Bruno Nunes",
    "Vinicius Lucena",
    "Rafael Lisboa",
    "Luis Gustavo",
    "Lucas Mota",
}

local characters = {
    {
        name = "Bruno",
        idle = "sprites/bruno_sheet/walk_01.png",
        walk = {
            "sprites/bruno_sheet/walk_01.png",
            "sprites/bruno_sheet/walk_02.png",
            "sprites/bruno_sheet/walk_03.png",
            "sprites/bruno_sheet/walk_04.png",
            "sprites/bruno_sheet/walk_05.png",
            "sprites/bruno_sheet/walk_06.png",
        },
        punch = {
            "sprites/bruno_sheet/punch_01.png",
            "sprites/bruno_sheet/punch_02.png",
            "sprites/bruno_sheet/punch_03.png",
            "sprites/bruno_sheet/punch_04.png",
            "sprites/bruno_sheet/punch_05.png",
            "sprites/bruno_sheet/punch_06.png",
        },
    },
    {
        name = "Wallace",
        idle = "sprites/sPersonagem/db27aa64-5b19-4708-b584-4683e69978ef.png",
        walk = {
            "sprites/sPersonagemCorre/d54994e5-094f-4699-8d11-e94f29bc5d0f.png",
            "sprites/sPersonagemCorre/e082ab22-e716-4833-82eb-1427fd9dc7de.png",
            "sprites/sPersonagemCorre/70316423-7fe7-406f-9776-2f80ccbd2f1b.png",
            "sprites/sPersonagemCorre/98977d47-47d7-4ec7-83ef-ceeb4a410cd4.png",
        },
        punch = {},
    },
}

local coinFrames = {
    "sprites/sMoeda/b1c01e71-b16c-49f2-9cba-3ff07364881b.png",
    "sprites/sMoeda/d3ca5f56-83bb-4d23-853f-0ebf6cbe222b.png",
    "sprites/sMoeda/3d467fcb-9e26-43ff-857b-4d4bdda884f2.png",
    "sprites/sMoeda/6262a341-d3c5-4a3a-b842-de189fec40c5.png",
    "sprites/sMoeda/6cf58f5a-2691-47bb-b13e-c009d2b03ecc.png",
    "sprites/sMoeda/e1bcf0dc-aefd-4688-af02-991b0db6141a.png",
    "sprites/sMoeda/bb94fa78-6d62-4890-a173-edcfdef07827.png",
    "sprites/sMoeda/f92e05b0-af51-4ed1-91bd-b9892454541b.png",
}

local sawFrames = {
    "sprites/sSerrote/887a8273-b5dd-4431-a07e-de93e05d8d31.png",
    "sprites/sSerrote/9121341a-2d64-4282-a8da-cb80167ac8f1.png",
    "sprites/sSerrote/b289e95f-d53f-4c24-b230-1d4004182e45.png",
}

local function loadImage(path)
    local image = love.graphics.newImage(path)
    local data = love.image.newImageData(path)
    local width, height = data:getWidth(), data:getHeight()
    local minX, minY = width, height
    local maxX, maxY = -1, -1

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local alpha = select(4, data:getPixel(x, y))
            if alpha > 0.05 then
                minX = math.min(minX, x)
                minY = math.min(minY, y)
                maxX = math.max(maxX, x)
                maxY = math.max(maxY, y)
            end
        end
    end

    if maxX < 0 then
        minX, minY, maxX, maxY = 0, 0, width - 1, height - 1
    end
    spriteBounds[image] = {
        x = minX,
        y = minY,
        width = maxX - minX + 1,
        height = maxY - minY + 1,
    }
    return image
end

local function loadImages(paths)
    local images = {}
    for index, path in ipairs(paths) do
        images[index] = loadImage(path)
    end
    return images
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function refreshGamepad()
    gamepad = nil
    Game.controllerName = nil
    for _, joystick in ipairs(love.joystick.getJoysticks()) do
        gamepad = joystick
        Game.controllerName = joystick:getName()
        return
    end
end

local function gamepadAxis(axis)
    if not gamepad then
        return 0
    end
    local value
    if gamepad:isGamepad() then
        value = gamepad:getGamepadAxis(axis)
    else
        local rawAxis = axis == "leftx" and 1 or 2
        value = gamepad:getAxis(rawAxis) or 0
    end
    if math.abs(value) < GAMEPAD_DEADZONE then
        return 0
    end
    return value
end

local function gamepadConfirm(button)
    return button == "a" or button == "start"
end

local function rawButtonDown(button)
    return gamepad and gamepad:getButtonCount() >= button and gamepad:isDown(button)
end

local function rawDpad()
    if not gamepad or gamepad:getHatCount() == 0 then
        return 0, 0
    end
    local hat = gamepad:getHat(1)
    return (hat:find("l") and -1 or hat:find("r") and 1 or 0),
        (hat:find("u") and -1 or hat:find("d") and 1 or 0)
end

local function goToPreviousCharacter()
    Game.selectedCharacter = Game.selectedCharacter == 1 and #characters or Game.selectedCharacter - 1
end

local function goToNextCharacter()
    Game.selectedCharacter = Game.selectedCharacter == #characters and 1 or Game.selectedCharacter + 1
end

local function overlaps(a, b)
    return a.x < b.x + b.width
        and b.x < a.x + a.width
        and a.y < b.y + b.height
        and b.y < a.y + a.height
end

local function currentFrame(frames, fps)
    return frames[math.floor(Game.animationTime * fps) % #frames + 1]
end

local function playerImage(target)
    target = target or player
    local characterAssets = assets.characters[target.character or Game.selectedCharacter]
    if target.abilityActive and target.character == 1 and #characterAssets.punch > 0 then
        return currentFrame(characterAssets.punch, 14)
    elseif target.moving then
        return currentFrame(characterAssets.walk, 9)
    end
    return characterAssets.idle
end

local function playerHitbox(target)
    target = target or player
    local image = playerImage(target)
    local bounds = spriteBounds[image]
    local imageWidth = image:getWidth() * player.scale
    local imageHeight = image:getHeight() * player.scale
    local drawLeft = target.x + (target.renderWidth - imageWidth) / 2
    local drawTop = target.y + (target.renderHeight - imageHeight) / 2
    local hitboxX = bounds.x
    if target.facing < 0 then
        hitboxX = image:getWidth() - bounds.x - bounds.width
    end
    return {
        x = drawLeft + hitboxX * player.scale,
        y = drawTop + bounds.y * player.scale,
        width = bounds.width * player.scale,
        height = bounds.height * player.scale,
    }
end

local function sawHitbox(saw)
    local image = currentFrame(assets.saws, 10)
    local bounds = spriteBounds[image]
    local scaleX = saw.width / image:getWidth()
    local scaleY = saw.height / image:getHeight()
    return {
        x = saw.x + bounds.x * scaleX,
        y = saw.y + bounds.y * scaleY,
        width = bounds.width * scaleX,
        height = bounds.height * scaleY,
    }
end

local function circleOverlapsRectangle(circleX, circleY, radius, rectangle)
    local closestX = clamp(circleX, rectangle.x, rectangle.x + rectangle.width)
    local closestY = clamp(circleY, rectangle.y, rectangle.y + rectangle.height)
    local dx = circleX - closestX
    local dy = circleY - closestY
    return dx * dx + dy * dy <= radius * radius
end

local function bossSawRadius(saw)
    local image = currentFrame(assets.saws, 12)
    local bounds = spriteBounds[image]
    local scale = saw.width / image:getWidth()
    local radiusX = bounds.width * scale / 2
    local radiusY = bounds.height * scale / 2
    return math.max(radiusX, radiusY)
end

local function playerCenter(target)
    target = target or player
    return target.x + target.renderWidth / 2, target.y + target.renderHeight / 2
end

local function activateAbility(target)
    if not target or target.abilityTimer > 0 or target.abilityCooldown > 0 then
        return
    end
    target.abilityTimer = target.character == 1 and 0.5 or 1.5
    target.abilityCooldown = 6
    target.abilityActive = true
end

local function distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

local function play(sound)
    if sound then
        sound:stop()
        sound:play()
    end
end

local function stopMusic()
    if assets.menuMusic then
        assets.menuMusic:stop()
    end
    for _, track in ipairs(assets.musicTracks or {}) do
        track:stop()
    end
    assets.music = nil
end

local playMusic

local function ensureMusic(source)
    if not Game.musicEnabled or not source then
        return
    end
    if assets.music ~= source then
        playMusic(source)
    elseif not source:isPlaying() then
        source:play()
    end
end

playMusic = function(source)
    stopMusic()
    if Game.musicEnabled and source then
        source:setLooping(true)
        source:play()
        assets.music = source
    end
end

local function playMenuMusic()
    ensureMusic(assets.menuMusic)
end

local function menuLabel(index)
    return MENU_ITEMS[index]
end

local function movePlayModeSelection(direction)
    Game.playModeIndex = Game.playModeIndex + direction
    if Game.playModeIndex < 1 then
        Game.playModeIndex = #PLAY_MODE_ITEMS
    elseif Game.playModeIndex > #PLAY_MODE_ITEMS then
        Game.playModeIndex = 1
    end
end

local function activatePlayMode()
    if Game.playModeIndex == 1 then
        Game.mode = "campaign"
        Game.playMode = "campaign"
        Game.state = "select"
        stopMusic()
    elseif Game.playModeIndex == 2 then
        Game.mode = "infinite"
        Game.playMode = "infinite"
        Game.state = "select"
        stopMusic()
    elseif Game.playModeIndex == 3 then
        Game.mode = "coop"
        Game.playMode = "coop"
        Game.state = "select"
        stopMusic()
    else
        Game.state = "menu"
    end
end

local function goToMenu()
    Game.state = "menu"
    Game.paused = false
    Game.menuIndex = 1
    Game.statusMessage = nil
    playMenuMusic()
end

local function activateMenuItem()
    if Game.menuIndex == 1 then
        Game.state = "playModes"
        Game.playModeIndex = 1
        playMenuMusic()
    elseif Game.menuIndex == 2 then
        Game.state = "settings"
        Game.settingsIndex = 1
        playMenuMusic()
    elseif Game.menuIndex == 3 then
        Game.state = "credits"
        Game.creditsTime = 0
        playMenuMusic()
    elseif Game.menuIndex == 4 then
        love.event.quit()
    end
end

local function moveMenuSelection(direction)
    Game.menuIndex = Game.menuIndex + direction
    if Game.menuIndex < 1 then
        Game.menuIndex = #MENU_ITEMS
    elseif Game.menuIndex > #MENU_ITEMS then
        Game.menuIndex = 1
    end
end

local function settingsLabel(index)
    if index == 1 then
        return "MUSICA: " .. (Game.musicEnabled and "LIGADA" or "DESLIGADA")
    elseif index == 2 then
        return "TELA CHEIA: " .. (love.window.getFullscreen() and "LIGADA" or "DESLIGADA")
    elseif index == 3 then
        return "TECLAS"
    elseif index == 4 then
        return "CONTROLADOR"
    end
    return SETTINGS_ITEMS[index]
end

local function moveSettingsSelection(direction)
    Game.settingsIndex = Game.settingsIndex + direction
    if Game.settingsIndex < 1 then
        Game.settingsIndex = #SETTINGS_ITEMS
    elseif Game.settingsIndex > #SETTINGS_ITEMS then
        Game.settingsIndex = 1
    end
end

local function activateSettingsItem()
    if Game.settingsIndex == 1 then
        Game.musicEnabled = not Game.musicEnabled
        if Game.musicEnabled then
            playMenuMusic()
        else
            stopMusic()
        end
    elseif Game.settingsIndex == 2 then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif Game.settingsIndex == 5 then
        goToMenu()
    end
end

local function spawnCoin()
    local image = assets.coins[1]
    local width = image:getWidth() * 1.65
    local height = image:getHeight() * 1.65
    local playerCenterX, playerCenterY = playerCenter()
    for _ = 1, 80 do
        local coin = {
            x = love.math.random(60, Game.width - width - 60),
            y = love.math.random(95, Game.height - height - 45),
            width = width,
            height = height,
        }
        local centerX = coin.x + width / 2
        local centerY = coin.y + height / 2
        if distance(centerX, centerY, playerCenterX, playerCenterY) >= 130 then
            local overlapsCoin = false
            for _, existingCoin in ipairs(coins) do
                if overlaps(coin, existingCoin) then
                    overlapsCoin = true
                    break
                end
            end
            if not overlapsCoin then
                return coin
            end
        end
    end
    return {x = 80, y = 110, width = width, height = height}
end

local function coinHitbox(coin)
    local image = currentFrame(assets.coins, 12)
    local bounds = spriteBounds[image]
    local scaleX = coin.width / image:getWidth()
    local scaleY = coin.height / image:getHeight()
    return {
        x = coin.x + bounds.x * scaleX,
        y = coin.y + bounds.y * scaleY,
        width = bounds.width * scaleX,
        height = bounds.height * scaleY,
    }
end

local function sawOverlapsAny(saw, list)
    for _, item in ipairs(list) do
        if overlaps(saw, item) then
            return true
        end
    end
    return false
end

local function safeSawPosition(width, height, minimumDistance)
    local playerBox = playerHitbox()
    for _ = 1, 80 do
        local candidate = {
            x = love.math.random(70, Game.width - width - 70),
            y = love.math.random(90, Game.height - height - 45),
            width = width,
            height = height,
        }
        local candidateCenterX = candidate.x + width / 2
        local candidateCenterY = candidate.y + height / 2
        local playerCenterX, playerCenterY = playerCenter()
        if distance(candidateCenterX, candidateCenterY, playerCenterX, playerCenterY) >= minimumDistance
            and not sawOverlapsAny(candidate, coins)
            and not sawOverlapsAny(candidate, saws) then
            return candidate
        end
    end
    return {
        x = Game.width - width - 90,
        y = 100,
        width = width,
        height = height,
    }
end

local function spawnSaw(index, isStatic)
    local image = assets.saws[1]
    local width = image:getWidth() * 0.55
    local height = image:getHeight() * 0.55
    local saw = safeSawPosition(width, height, isStatic and 170 or 230)
    saw.static = isStatic
    saw.vx = 0
    saw.vy = 0
    if not isStatic then
        local playerCenterX, playerCenterY = playerCenter()
        local sawCenterX = saw.x + width / 2
        local sawCenterY = saw.y + height / 2
        local dx = sawCenterX - playerCenterX
        local dy = sawCenterY - playerCenterY
        local length = math.max(1, math.sqrt(dx * dx + dy * dy))
        local difficulty = Game.mode == "infinite" and Game.infiniteRound or Game.level
        local speed = 125 + difficulty * 30 + index * 12
        local direction = love.math.random() < 0.5 and -1 or 1
        local awayX = dx / length
        local awayY = dy / length
        saw.vx = awayX * speed + (-awayY * speed * 0.35 * direction)
        saw.vy = awayY * speed + (awayX * speed * 0.35 * direction)
    end
    return saw
end

local function spawnCornerSaw(index)
    local image = assets.saws[1]
    local width = image:getWidth() * 0.55
    local height = image:getHeight() * 0.55
    local margin = 30
    local route = {
        left = margin,
        top = 78,
        right = Game.width - margin - width,
        bottom = Game.height - margin - height,
    }
    local perimeter = (route.right - route.left) * 2 + (route.bottom - route.top) * 2
    return {
        x = route.left,
        y = route.top,
        width = width,
        height = height,
        corner = true,
        route = route,
        routeDistance = (index - 1) * perimeter / 2,
        routePerimeter = perimeter,
        routeSpeed = 90 + (Game.mode == "infinite" and Game.infiniteRound or Game.level) * 8,
        routeDirection = index % 2 == 0 and -1 or 1,
        vx = 0,
        vy = 0,
    }
end

local function updateCornerSaw(saw, dt)
    local route = saw.route
    saw.routeDistance = (saw.routeDistance + saw.routeSpeed * saw.routeDirection * dt) % saw.routePerimeter
    local distance = saw.routeDistance
    local topLength = route.right - route.left
    local rightLength = route.bottom - route.top

    if distance <= topLength then
        saw.x = route.left + distance
        saw.y = route.top
    elseif distance <= topLength + rightLength then
        saw.x = route.right
        saw.y = route.top + distance - topLength
    elseif distance <= topLength * 2 + rightLength then
        saw.x = route.right - (distance - topLength - rightLength)
        saw.y = route.bottom
    else
        saw.x = route.left
        saw.y = route.bottom - (distance - topLength * 2 - rightLength)
    end
end

local function updateSaw(saw, dt)
    if saw.corner then
        updateCornerSaw(saw, dt)
        return
    end
    saw.x = saw.x + saw.vx * dt
    saw.y = saw.y + saw.vy * dt
    if saw.x <= 0 or saw.x >= Game.width - saw.width then
        saw.vx = -saw.vx
        saw.x = clamp(saw.x, 0, Game.width - saw.width)
    end
    if saw.y <= 60 or saw.y >= Game.height - saw.height then
        saw.vy = -saw.vy
        saw.y = clamp(saw.y, 60, Game.height - saw.height)
    end
end

local function createPlayer(character, x, y)
    local characterAssets = assets.characters[character]
    local spriteScale = 0.35
    local renderWidth = characterAssets.idle:getWidth()
    local renderHeight = characterAssets.idle:getHeight()
    for _, image in ipairs(characterAssets.walk) do
        renderWidth = math.max(renderWidth, image:getWidth())
        renderHeight = math.max(renderHeight, image:getHeight())
    end
    for _, image in ipairs(characterAssets.punch) do
        renderWidth = math.max(renderWidth, image:getWidth())
        renderHeight = math.max(renderHeight, image:getHeight())
    end
    renderWidth = renderWidth * spriteScale
    renderHeight = renderHeight * spriteScale
    return {
        x = x,
        y = y,
        width = renderWidth,
        height = renderHeight,
        renderWidth = renderWidth,
        renderHeight = renderHeight,
        scale = spriteScale,
        facing = 1,
        moving = false,
        character = character,
        abilityTimer = 0,
        abilityCooldown = 0,
        abilityActive = false,
        alive = true,
    }
end

local function startLevel(level)
    Game.state = "countdown"
    Game.level = level
    Game.coins = 0
    Game.timeLeft = Game.mode == "infinite" and math.max(16, 34 - Game.infiniteRound * 0.45)
        or (level == 1 and 35 or 30)
    Game.paused = false
    Game.countdown = 3
    Game.countdownMode = "level"
    local firstX = Game.mode == "coop" and Game.width * 0.3 or Game.width / 2
    local secondX = Game.width * 0.7
    player = createPlayer(Game.selectedCharacter, firstX, Game.height / 2)
    player2 = Game.mode == "coop" and createPlayer(Game.selectedCharacter == 1 and 2 or 1, secondX, Game.height / 2) or nil
    coins = {}
    saws = {}

    local coinGoal = Game.mode == "infinite" and math.min(12, 3 + Game.infiniteRound) or 12
    Game.infiniteGoal = coinGoal
    for _ = 1, coinGoal do
        table.insert(coins, spawnCoin())
    end
    local movingSawCount = Game.mode == "infinite" and math.min(12, Game.infiniteRound) or level
    for index = 1, movingSawCount do
        table.insert(saws, spawnSaw(index, false))
    end
    local staticSawCount = Game.mode == "infinite" and math.min(6, math.floor(Game.infiniteRound / 2))
        or math.min(5, 1 + math.floor(level / 2))
    for index = 1, staticSawCount do
        table.insert(saws, spawnSaw(index, true))
    end
    local cornerSawCount = 0
    if Game.mode == "infinite" then
        cornerSawCount = Game.infiniteRound >= 3 and math.min(2, math.floor(Game.infiniteRound / 3)) or 0
    elseif level == 2 or level == 4 or level == 6 then
        cornerSawCount = level == 6 and 2 or 1
    end
    for index = 1, cornerSawCount do
        table.insert(saws, spawnCornerSaw(index))
    end

    playMusic(assets.musicTracks[((level - 1) % #assets.musicTracks) + 1])
end

local function startInfiniteMode()
    Game.mode = "infinite"
    Game.infiniteRound = 1
    startLevel(1)
end

local function startBoss()
    Game.state = "bossCountdown"
    Game.level = 6
    Game.countdown = 3
    Game.countdownMode = "boss"
    Game.bossTime = 30
    bossSpawnTimer = 0.8
    bossSaws = {}
    boss = {x = Game.width / 2, y = 325, radius = 72}
    playMusic(assets.musicTracks[2])
end

local function returnToSelection(message)
    Game.state = "select"
    Game.statusMessage = message
    Game.paused = false
    stopMusic()
end

local function drawCentered(text, y, font)
    love.graphics.setFont(font)
    love.graphics.printf(text, 0, y, Game.width, "center")
end


local function drawDiscoBackground(level)
    local time = Game.animationTime

    local palettes = {
        {wall = {0.12, 0.025, 0.18}, floor = {0.035, 0.015, 0.08},
         a = {0.95, 0.12, 0.55}, b = {0.1, 0.65, 1.0}},
        {wall = {0.015, 0.10, 0.16}, floor = {0.01, 0.025, 0.07},
         a = {0.0, 0.95, 0.85}, b = {0.25, 0.3, 1.0}},
        {wall = {0.18, 0.035, 0.025}, floor = {0.07, 0.015, 0.025},
         a = {1.0, 0.2, 0.08}, b = {1.0, 0.75, 0.1}},
        {wall = {0.09, 0.025, 0.2}, floor = {0.025, 0.01, 0.08},
         a = {0.7, 0.15, 1.0}, b = {0.05, 0.9, 1.0}},
    }

    local p = palettes[(level - 1) % #palettes + 1]

    -- Fundo e paredes da discoteca
    love.graphics.setColor(p.wall)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)

    -- Painéis da parede
    for x = 0, 1280, 80 do
        love.graphics.setColor(0.025, 0.015, 0.055)
        love.graphics.rectangle("fill", x, 65, 5, 235)

        local pulse = 0.35 + 0.25 * math.sin(time * 3 + x * 0.04)
        love.graphics.setColor(p.a[1], p.a[2], p.a[3], pulse)
        love.graphics.rectangle("fill", x + 12, 85, 4, 175)

        love.graphics.setColor(p.b[1], p.b[2], p.b[3], pulse)
        love.graphics.rectangle("fill", x + 23, 110, 4, 130)
    end

    -- Estrutura da cabine do DJ
    love.graphics.setColor(0.025, 0.015, 0.045)
    love.graphics.rectangle("fill", 430, 85, 420, 155)

    love.graphics.setColor(p.a)
    love.graphics.rectangle("fill", 445, 100, 390, 8)
    love.graphics.rectangle("fill", 445, 210, 390, 8)

    -- Painel luminoso atrás do DJ
    love.graphics.setColor(0.08, 0.025, 0.12)
    love.graphics.rectangle("fill", 470, 115, 340, 80)

    for i = 0, 10 do
        local h = 8 + math.abs(math.sin(time * 5 + i)) * 48
        local hue = i % 3
        if hue == 0 then
            love.graphics.setColor(1, 0.1, 0.55)
        elseif hue == 1 then
            love.graphics.setColor(0.1, 0.8, 1)
        else
            love.graphics.setColor(0.8, 0.2, 1)
        end
        love.graphics.rectangle("fill", 485 + i * 29, 185 - h, 17, h)
    end

    -- Mesa do DJ
    love.graphics.setColor(0.025, 0.02, 0.045)
    love.graphics.rectangle("fill", 450, 205, 380, 45)
    love.graphics.setColor(p.b)
    love.graphics.rectangle("fill", 450, 205, 380, 5)

    for i = 0, 7 do
        local light = 0.5 + 0.5 * math.sin(time * 6 + i)
        love.graphics.setColor(1, light * 0.4, 0.8, 1)
        love.graphics.rectangle("fill", 465 + i * 47, 220, 20, 8)
    end

    -- Caixas de som nas laterais
    for _, x in ipairs({55, 1080}) do
        love.graphics.setColor(0.018, 0.012, 0.035)
        love.graphics.rectangle("fill", x, 95, 145, 205)

        love.graphics.setColor(p.a)
        love.graphics.rectangle("line", x, 95, 145, 205)

        for _, y in ipairs({135, 225}) do
            love.graphics.setColor(0.08, 0.06, 0.12)
            love.graphics.circle("fill", x + 72, y, 39)

            love.graphics.setColor(p.b)
            love.graphics.circle("line", x + 72, y, 31)

            local pulse = 25 + math.sin(time * 7 + x + y) * 4
            love.graphics.setColor(0.025, 0.02, 0.055)
            love.graphics.circle("fill", x + 72, y, pulse)

            love.graphics.setColor(p.a)
            love.graphics.rectangle("fill", x + 66, y - 3, 12, 6)
        end
    end

    -- Globos espelhados
    local gx, gy = 640, 65
    love.graphics.setColor(0.75, 0.85, 1)
    love.graphics.circle("fill", gx, gy, 23)

    for i = 0, 7 do
        local angle = time * 1.5 + i * math.pi / 4
        local x = gx + math.cos(angle) * 17
        local y = gy + math.sin(angle) * 17
        love.graphics.setColor(i % 2 == 0 and p.a or p.b)
        love.graphics.rectangle("fill", x - 3, y - 3, 6, 6)
    end

    -- Feixes de luz na parede
    for i = 0, 5 do
        local x = 100 + i * 215
        local angle = math.sin(time * 1.4 + i * 1.8) * 0.55
        local endX = x + math.sin(angle) * 250

        love.graphics.setColor(p.b[1], p.b[2], p.b[3], 0.15)
        love.graphics.polygon("fill",
            x - 9, 250,
            x + 9, 250,
            endX + 35, 440,
            endX - 35, 440
        )
    end

    -- Piso da pista de dança
    love.graphics.setColor(p.floor)
    love.graphics.rectangle("fill", 0, 300, 1280, 420)

    local tile = 64
    for row = 0, 6 do
        for col = 0, 19 do
            local x = col * tile
            local y = 300 + row * tile
            local alternate = (row + col) % 2 == 0
            local pulse = 0.35 + 0.3 *
                math.max(0, math.sin(time * 3 + row + col * 0.7))

            if alternate then
                love.graphics.setColor(0.06, 0.025, 0.11)
            else
                love.graphics.setColor(0.025, 0.015, 0.06)
            end
            love.graphics.rectangle("fill", x, y, tile, tile)

            local color = alternate and p.a or p.b
            love.graphics.setColor(
                color[1], color[2], color[3], pulse
            )
            love.graphics.rectangle("fill", x + 5, y + 5, tile - 10, tile - 10)

            love.graphics.setColor(0.04, 0.02, 0.08, 1)
            love.graphics.rectangle("fill", x + 12, y + 12, tile - 24, tile - 24)
        end
    end

    -- Contorno da pista
    love.graphics.setColor(p.a)
    love.graphics.rectangle("fill", 0, 295, 1280, 5)
    love.graphics.rectangle("fill", 0, 300, 5, 420)
    love.graphics.rectangle("fill", 1275, 300, 5, 420)

    -- Luzes decorativas no teto
    for i = 0, 15 do
        local x = i * 80 + 20
        local pulse = (math.sin(time * 5 + i) + 1) / 2

        love.graphics.setColor(p.a[1], p.a[2], p.a[3], pulse)
        love.graphics.rectangle("fill", x, 35, 30, 8)

        love.graphics.setColor(p.b[1], p.b[2], p.b[3], pulse)
        love.graphics.rectangle("fill", x + 5, 45, 20, 4)
    end

    -- Vinheta escura nas bordas para destacar os personagens
    love.graphics.setColor(0.01, 0.005, 0.025, 0.3)
    love.graphics.rectangle("fill", 0, 0, 25, 720)
    love.graphics.rectangle("fill", 1255, 0, 25, 720)
end


local function drawMenuBackground()
    local time = Game.animationTime
    love.graphics.setColor(0.015, 0.005, 0.04, 1)
    love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)

    for index = 0, 7 do
        local x = (index + 0.5) * Game.width / 8
        local y = 110 + math.sin(time * 0.8 + index) * 65
        local radius = 80 + math.sin(time * 1.7 + index * 1.3) * 22
        local progress = (math.sin(time * 0.45 + index * 0.55) + 1) / 2
        local red = 0.25 + progress * 0.7
        local green = 0.04 + (1 - progress) * 0.18
        local blue = 0.35 + (1 - progress) * 0.6
        love.graphics.setColor(red, green, blue, 0.14)
        love.graphics.circle("fill", x, y, radius)
    end

    for row = 0, 8 do
        for column = 0, 15 do
            local progress = (math.sin(time * 0.35) + 1) / 2
            local pulse = math.max(0, math.sin(time * 3.5 + row + column * 0.8))
            local color = {0.15 + progress * 0.75, 0.06 + (1 - progress) * 0.58, 0.4 + (1 - progress) * 0.55}
            love.graphics.setColor(color[1], color[2], color[3], 0.08 + pulse * 0.18)
            love.graphics.rectangle("fill", column * 80 + 2, 360 + row * 45 + 2, 76, 41)
        end
    end

    for index = 1, 30 do
        local x = index * 44 + math.sin(time * 2 + index) * 10
        local height = 15 + (math.sin(time * 5 + index * 0.7) + 1) * 18
        love.graphics.setColor(0.95, 0.2 + (index % 3) * 0.2, 0.75, 0.25)
        love.graphics.rectangle("fill", x, 345 - height, 18, height)
    end

    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("line", 30, 30, Game.width - 60, Game.height - 60)
end

local function drawBoss()
    if not boss then
        return
    end
    local pulse = 1 + math.sin(Game.animationTime * 5) * 0.08
    love.graphics.setColor(0.9, 0.08, 0.12, 0.25)
    love.graphics.circle("fill", boss.x, boss.y, boss.radius * 1.5 * pulse)
    love.graphics.setColor(0.12, 0.02, 0.03, 1)
    love.graphics.circle("fill", boss.x, boss.y, boss.radius)
    love.graphics.setColor(1, 0.15, 0.05, 1)
    love.graphics.setLineWidth(8)
    love.graphics.circle("line", boss.x, boss.y, boss.radius)
    love.graphics.setLineWidth(3)
    for index = 0, 7 do
        local angle = Game.animationTime * 1.5 + index * math.pi / 4
        local inner = boss.radius * 0.75
        local outer = boss.radius * 1.22
        love.graphics.polygon(
            "fill",
            boss.x + math.cos(angle - 0.12) * inner,
            boss.y + math.sin(angle - 0.12) * inner,
            boss.x + math.cos(angle) * outer,
            boss.y + math.sin(angle) * outer,
            boss.x + math.cos(angle + 0.12) * inner,
            boss.y + math.sin(angle + 0.12) * inner
        )
    end
    love.graphics.setColor(1, 0.8, 0.1, 1)
    love.graphics.circle("fill", boss.x, boss.y, 18 + math.sin(Game.animationTime * 6) * 3)
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.math.setRandomSeed(os.time())
    assets.characters = {}
    for index, character in ipairs(characters) do
        assets.characters[index] = {
            idle = loadImage(character.idle),
            walk = loadImages(character.walk),
            punch = loadImages(character.punch),
        }
    end
    assets.coins = loadImages(coinFrames)
    assets.saws = loadImages(sawFrames)
    assets.font = love.graphics.newFont("datafiles/HomeVideo-BLG6G.ttf", 24)
    assets.smallFont = love.graphics.newFont("datafiles/HomeVideo-BLG6G.ttf", 16)
    assets.titleFont = love.graphics.newFont("datafiles/HomeVideo-BLG6G.ttf", 52)
    assets.musicTracks = {
        love.audio.newSource("sounds/Final_Quarter_Dash.mp3", "stream"),
        love.audio.newSource("sounds/Frame_Perfect.mp3", "stream"),
    }
    assets.menuMusic = love.audio.newSource("sounds/High_Score_Serenade.mp3", "stream")
    assets.coinSound = love.audio.newSource("sounds/somMoeda/somMoeda.mp3", "static")
    refreshGamepad()
    playMenuMusic()
end

function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
        return
    end

    if key == "f5" then
        returnToSelection("Escolha um personagem para reiniciar.")
        return
    end

    if Game.state == "menu" then
        if key == "up" or key == "w" then
            moveMenuSelection(-1)
        elseif key == "down" or key == "s" then
            moveMenuSelection(1)
        elseif key == "return" or key == "space" then
            activateMenuItem()
        elseif key == "escape" then
            love.event.quit()
        end
        return
    end

    if Game.state == "playModes" then
        if key == "up" or key == "w" then
            movePlayModeSelection(-1)
        elseif key == "down" or key == "s" then
            movePlayModeSelection(1)
        elseif key == "return" or key == "space" then
            activatePlayMode()
        elseif key == "escape" then
            Game.state = "menu"
        end
        return
    end

    if Game.state == "settings" then
        if key == "up" or key == "w" then
            moveSettingsSelection(-1)
        elseif key == "down" or key == "s" then
            moveSettingsSelection(1)
        elseif key == "return" or key == "space" then
            activateSettingsItem()
        elseif key == "escape" then
            goToMenu()
        end
        return
    end

    if Game.state == "select" then
        if key == "left" or key == "a" then
            Game.selectedCharacter = 1
        elseif key == "right" or key == "d" then
            Game.selectedCharacter = 2
        elseif key == "return" or key == "space" then
            if Game.mode == "infinite" then
                startInfiniteMode()
            else
                startLevel(1)
            end
        elseif key == "escape" then
            goToMenu()
        end
        return
    end

    if (Game.state == "playing" or Game.state == "boss") and key == "escape" then
        Game.paused = not Game.paused
        if Game.paused then
            if assets.music then assets.music:pause() end
        elseif assets.music then
            assets.music:play()
        end
        return
    end

    if (Game.state == "playing" or Game.state == "boss") and key == "space" then
        activateAbility(player)
        return
    end
    if Game.mode == "coop" and (Game.state == "playing" or Game.state == "boss") and key == "v" then
        activateAbility(player2)
        return
    end

    if Game.state == "credits" and (key == "return" or key == "space" or key == "escape") then
        goToMenu()
    elseif Game.state == "ending" and (key == "return" or key == "space" or key == "escape") then
        goToMenu()
    elseif (Game.state == "gameover" or Game.state == "victory") and (key == "return" or key == "space") then
        returnToSelection()
    elseif key == "escape" then
        goToMenu()
    end
end

function love.joystickadded(joystick)
    if not gamepad then
        gamepad = joystick
        Game.controllerName = joystick:getName()
    end
end

function love.joystickremoved(joystick)
    if gamepad == joystick then
        refreshGamepad()
    end
end

function love.gamepadpressed(joystick, button)
    if joystick ~= gamepad then
        return
    end

    if Game.state == "menu" then
        if button == "dpup" or button == "leftshoulder" then
            moveMenuSelection(-1)
        elseif button == "dpdown" or button == "rightshoulder" then
            moveMenuSelection(1)
        elseif gamepadConfirm(button) then
            activateMenuItem()
        elseif button == "b" or button == "back" then
            love.event.quit()
        end
    elseif Game.state == "playModes" then
        if button == "dpup" or button == "leftshoulder" then
            movePlayModeSelection(-1)
        elseif button == "dpdown" or button == "rightshoulder" then
            movePlayModeSelection(1)
        elseif gamepadConfirm(button) then
            activatePlayMode()
        elseif button == "b" or button == "back" then
            Game.state = "menu"
        end
    elseif Game.state == "settings" then
        if button == "dpup" or button == "leftshoulder" then
            moveSettingsSelection(-1)
        elseif button == "dpdown" or button == "rightshoulder" then
            moveSettingsSelection(1)
        elseif gamepadConfirm(button) then
            activateSettingsItem()
        elseif button == "b" or button == "back" then
            goToMenu()
        end
    elseif Game.state == "select" then
        if button == "dpleft" or button == "leftshoulder" then
            goToPreviousCharacter()
        elseif button == "dpright" or button == "rightshoulder" then
            goToNextCharacter()
        elseif gamepadConfirm(button) then
            if Game.mode == "infinite" then
                startInfiniteMode()
            else
                startLevel(1)
            end
        elseif button == "b" or button == "back" then
            goToMenu()
        end
    elseif Game.state == "playing" or Game.state == "boss" then
        if button == "x" or button == "y" then
            activateAbility()
        elseif button == "start" or button == "back" then
            Game.paused = not Game.paused
            if Game.paused then
                if assets.music then assets.music:pause() end
            elseif assets.music then
                assets.music:play()
            end
        end
    elseif Game.state == "credits" and (gamepadConfirm(button) or button == "b" or button == "back") then
        goToMenu()
    elseif Game.state == "ending" and (gamepadConfirm(button) or button == "b" or button == "back") then
        goToMenu()
    elseif (Game.state == "gameover" or Game.state == "victory") and gamepadConfirm(button) then
        returnToSelection()
    end
end

function love.joystickpressed(joystick, button)
    if joystick ~= gamepad or joystick:isGamepad() then
        return
    end

    if button == 1 then
        love.gamepadpressed(joystick, "a")
    elseif button == 2 then
        love.gamepadpressed(joystick, "b")
    elseif button == 3 then
        love.gamepadpressed(joystick, "x")
    elseif button == 4 then
        love.gamepadpressed(joystick, "y")
    elseif button == 7 then
        love.gamepadpressed(joystick, "back")
    elseif button == 8 then
        love.gamepadpressed(joystick, "start")
    elseif button == 11 then
        love.gamepadpressed(joystick, "dpup")
    elseif button == 12 then
        love.gamepadpressed(joystick, "dpdown")
    elseif button == 13 then
        love.gamepadpressed(joystick, "dpleft")
    elseif button == 14 then
        love.gamepadpressed(joystick, "dpright")
    end
end

local function readMovement(scheme)
    if scheme == "arrows" then
        return (love.keyboard.isDown("right") and 1 or 0) - (love.keyboard.isDown("left") and 1 or 0),
            (love.keyboard.isDown("down") and 1 or 0) - (love.keyboard.isDown("up") and 1 or 0)
    end
    if scheme == "wasd" then
        return (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0),
            (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0)
    end
    local horizontal = (love.keyboard.isDown("right", "d") and 1 or 0)
        - (love.keyboard.isDown("left", "a") and 1 or 0)
    local vertical = (love.keyboard.isDown("down", "s") and 1 or 0)
        - (love.keyboard.isDown("up", "w") and 1 or 0)
    local gamepadHorizontal = gamepadAxis("leftx")
    local gamepadVertical = gamepadAxis("lefty")
    if gamepad then
        local hatHorizontal, hatVertical = rawDpad()
        local dpadLeft = gamepad:isGamepad() and gamepad:isGamepadDown("dpleft") or rawButtonDown(13)
        local dpadRight = gamepad:isGamepad() and gamepad:isGamepadDown("dpright") or rawButtonDown(14)
        local dpadUp = gamepad:isGamepad() and gamepad:isGamepadDown("dpup") or rawButtonDown(11)
        local dpadDown = gamepad:isGamepad() and gamepad:isGamepadDown("dpdown") or rawButtonDown(12)
        if dpadLeft then
            gamepadHorizontal = -1
        elseif dpadRight then
            gamepadHorizontal = 1
        elseif hatHorizontal ~= 0 then
            gamepadHorizontal = hatHorizontal
        end
        if dpadUp then
            gamepadVertical = -1
        elseif dpadDown then
            gamepadVertical = 1
        elseif hatVertical ~= 0 then
            gamepadVertical = hatVertical
        end
    end
    if gamepadHorizontal ~= 0 or gamepadVertical ~= 0 then
        horizontal = gamepadHorizontal
        vertical = gamepadVertical
    end
    local length = math.sqrt(horizontal * horizontal + vertical * vertical)
    if length > 1 then
        horizontal = horizontal / length
        vertical = vertical / length
    end
    return horizontal, vertical
end

local function movePlayer(dt, target, scheme)
    if not target or not target.alive then
        return
    end
    local horizontal, vertical = readMovement(scheme)
    local length = math.sqrt(horizontal * horizontal + vertical * vertical)
    target.moving = length > 0
    if math.abs(horizontal) > 0.01 then
        target.facing = horizontal
    end
    local speed = 235
    target.x = clamp(target.x + horizontal * speed * dt, 0, Game.width - target.renderWidth)
    target.y = clamp(target.y + vertical * speed * dt, 60, Game.height - target.renderHeight)
end

local function updateAbility(dt, target)
    if not target then
        return
    end
    target.abilityCooldown = math.max(0, target.abilityCooldown - dt)
    if target.abilityTimer > 0 then
        target.abilityTimer = math.max(0, target.abilityTimer - dt)
        if target.abilityTimer == 0 then
            target.abilityActive = false
        end
    end
end

local function repelSawFromPlayer(saw, target)
    local playerCenterX, playerCenterY = playerCenter(target)
    local sawCenterX = saw.x + saw.width / 2
    local sawCenterY = saw.y + saw.height / 2
    local dx = sawCenterX - playerCenterX
    local dy = sawCenterY - playerCenterY
    local length = math.max(1, math.sqrt(dx * dx + dy * dy))
    local force = 560
    saw.vx = (dx / length) * force
    saw.vy = (dy / length) * force
    saw.corner = false
    saw.x = saw.x + (dx / length) * 18
    saw.y = saw.y + (dy / length) * 18
    target.abilityActive = false
    target.abilityTimer = 0
end

local function eliminatePlayer(target, message)
    if not target or not target.alive then
        return
    end
    target.alive = false
    target.moving = false
    target.abilityActive = false
    if Game.mode ~= "coop" then
        Game.state = "gameover"
        Game.statusMessage = message
        stopMusic()
    elseif not (player and player.alive) and not (player2 and player2.alive) then
        Game.state = "gameover"
        Game.statusMessage = "Os dois jogadores foram derrotados."
        stopMusic()
    end
end

local function spawnBossWave()
    local baseAngle = Game.animationTime * 0.7
    for index = 0, 3 do
        local angle = baseAngle + index * math.pi / 2
        local speed = 145 + index * 18
        table.insert(bossSaws, {
            x = boss.x - 18,
            y = boss.y - 18,
            width = 52,
            height = 52,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            angle = angle,
            life = 0,
        })
    end
end

local function updateBoss(dt)
    Game.bossTime = Game.bossTime - dt
    bossSpawnTimer = bossSpawnTimer - dt
    movePlayer(dt, player, "coop" == Game.mode and "wasd" or nil)
    if player2 then
        movePlayer(dt, player2, "arrows")
    end
    if bossSpawnTimer <= 0 then
        spawnBossWave()
        bossSpawnTimer = 1.25
    end

    for index = #bossSaws, 1, -1 do
        local saw = bossSaws[index]
        saw.x = saw.x + saw.vx * dt
        saw.y = saw.y + saw.vy * dt
        saw.angle = saw.angle + dt * 7
        saw.life = saw.life + dt
        if saw.life > 7 or saw.x < -80 or saw.x > Game.width + 80 or saw.y < -80 or saw.y > Game.height + 80 then
            table.remove(bossSaws, index)
        elseif player.alive and circleOverlapsRectangle(
            saw.x + saw.width / 2,
            saw.y + saw.height / 2,
            bossSawRadius(saw),
            playerHitbox()
        ) then
            if player.alive and player.character == 1 and player.abilityActive then
                repelSawFromPlayer(saw, player)
            elseif player.alive and not (player.character == 2 and player.abilityActive) then
                eliminatePlayer(player, "O jogador foi derrotado.")
            end
        elseif player2 and player2.alive and circleOverlapsRectangle(
            saw.x + saw.width / 2, saw.y + saw.height / 2, bossSawRadius(saw), playerHitbox(player2)
        ) then
            if player2.alive and player2.character == 1 and player2.abilityActive then
                repelSawFromPlayer(saw, player2)
            elseif player2.alive and not (player2.character == 2 and player2.abilityActive) then
                eliminatePlayer(player2, "O jogador foi derrotado.")
            end
        end
    end

    if Game.bossTime <= 0 then
        Game.state = "ending"
        Game.endingTime = 0
        stopMusic()
    end
end

function love.update(dt)
    Game.animationTime = Game.animationTime + dt
    Game.uiTime = Game.uiTime + dt

    if Game.state == "select" and gamepad then
        local horizontal = gamepadAxis("leftx")
        local hatHorizontal = rawDpad()
        if math.abs(horizontal) < 0.6 then
            horizontal = hatHorizontal
        end
        gamepadSelectionRepeat = math.max(0, gamepadSelectionRepeat - dt)
        if gamepadSelectionRepeat == 0 and horizontal <= -0.6 then
            goToPreviousCharacter()
            gamepadSelectionRepeat = 0.25
        elseif gamepadSelectionRepeat == 0 and horizontal >= 0.6 then
            goToNextCharacter()
            gamepadSelectionRepeat = 0.25
        end
    end

    if Game.state == "credits" then
        Game.creditsTime = Game.creditsTime + dt
        return
    end

    if Game.state == "ending" then
        Game.endingTime = Game.endingTime + dt
        if Game.endingTime >= 12 then
            goToMenu()
        end
        return
    end

    if Game.state == "countdown" or Game.state == "bossCountdown" then
        Game.countdown = Game.countdown - dt
        if Game.countdown <= 0 then
            Game.countdown = 0
            Game.state = Game.countdownMode == "boss" and "boss" or "playing"
        end
        return
    end

    if Game.state == "boss" and not Game.paused then
        updateAbility(dt, player)
        updateAbility(dt, player2)
        updateBoss(dt)
        return
    end

    if Game.state ~= "playing" or Game.paused then
        return
    end

    updateAbility(dt, player)
    updateAbility(dt, player2)
    Game.timeLeft = Game.timeLeft - dt
    if Game.timeLeft <= 0 then
        returnToSelection("O tempo acabou. Tente novamente!")
        return
    end

    movePlayer(dt, player, Game.mode == "coop" and "wasd" or nil)
    if player2 then
        movePlayer(dt, player2, "arrows")
    end

    for _, saw in ipairs(saws) do
        updateSaw(saw, dt)
        local hitTarget = player.alive and overlaps(playerHitbox(), sawHitbox(saw)) and player
        if not hitTarget and player2 and player2.alive and overlaps(playerHitbox(player2), sawHitbox(saw)) then
            hitTarget = player2
        end
        if hitTarget then
            if hitTarget.character == 1 and hitTarget.abilityActive then
                repelSawFromPlayer(saw, hitTarget)
            elseif not (hitTarget.character == 2 and hitTarget.abilityActive) then
                eliminatePlayer(hitTarget, "O jogador foi derrotado.")
            end
        end
    end

    for index = #coins, 1, -1 do
        if (player.alive and overlaps(playerHitbox(), coinHitbox(coins[index])))
            or (player2 and player2.alive and overlaps(playerHitbox(player2), coinHitbox(coins[index]))) then
            table.remove(coins, index)
            Game.coins = Game.coins + 1
            play(assets.coinSound)
            if Game.coins == Game.infiniteGoal then
                if Game.mode == "infinite" then
                    Game.infiniteRound = Game.infiniteRound + 1
                    startLevel(1)
                elseif Game.level == 6 then
                    startBoss()
                else
                    startLevel(Game.level + 1)
                end
            end
        end
    end
end

function love.draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local viewScale = math.min(windowWidth / Game.width, windowHeight / Game.height)
    local viewOffsetX = (windowWidth - Game.width * viewScale) / 2
    local viewOffsetY = (windowHeight - Game.height * viewScale) / 2
    love.graphics.push()
    love.graphics.translate(viewOffsetX, viewOffsetY)
    love.graphics.scale(viewScale, viewScale)
    love.graphics.setColor(1, 1, 1)
    if Game.state == "playing" or Game.state == "countdown"
        or Game.state == "boss" or Game.state == "bossCountdown" then
        drawDiscoBackground(Game.level)
    else
        drawMenuBackground()
    end

    if Game.state == "menu" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("SAWS AND PARTIES", 68, assets.titleFont)
        drawCentered("DISCOTECA DE SOBREVIVENCIA", 135, assets.font)
        for index = 1, #MENU_ITEMS do
            local selected = index == Game.menuIndex
            local y = 245 + index * 48
            local entryOffset = math.max(0, 0.55 - Game.uiTime) * (6 - index) * 24
            local pulse = selected and math.sin(Game.uiTime * 5) * 3 or 0
            if selected then
                love.graphics.setColor(0.1, 0.8, 1, 0.18)
                love.graphics.rectangle("fill", 380 - pulse, y - 10 - entryOffset, 520 + pulse * 2, 44, 8, 8)
            end
            love.graphics.setColor(selected and 1 or 0.65, selected and 0.85 or 0.65, selected and 0.2 or 0.9, 1)
            love.graphics.printf(menuLabel(index), 420, y - entryOffset, 440, "center")
        end
        love.graphics.setColor(1, 1, 1, 0.8)
        drawCentered("Setas/WASD ou D-pad para navegar | ENTER/A confirmar", 610, assets.font)
        drawCentered(Game.controllerName and ("Controle detectado: " .. Game.controllerName) or "Nenhum controle detectado", 655, assets.font)
    elseif Game.state == "playModes" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("ESCOLHA O MODO", 90, assets.titleFont)
        drawCentered("Selecione como deseja jogar", 150, assets.font)
        for index, label in ipairs(PLAY_MODE_ITEMS) do
            local selected = index == Game.playModeIndex
            if selected then
                love.graphics.setColor(0.1, 0.8, 1, 0.2)
                love.graphics.rectangle("fill", 370, 220 + index * 58, 540, 50)
            end
            love.graphics.setColor(selected and 1 or 0.65, selected and 0.85 or 0.65, selected and 0.2 or 0.9, 1)
            love.graphics.printf(label, 390, 232 + index * 58, 500, "center")
        end
        love.graphics.setColor(1, 1, 1, 0.8)
        drawCentered("↑↓ navegar | ENTER/A confirmar | ESC/B voltar", 650, assets.font)
    elseif Game.state == "settings" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("CONFIGURACOES", 75, assets.titleFont)
        drawCentered("Ajuste a experiencia da pista", 140, assets.font)
        for index = 1, #SETTINGS_ITEMS do
            local selected = index == Game.settingsIndex
            if selected then
                love.graphics.setColor(0.95, 0.2, 0.65, 0.2)
                love.graphics.rectangle("fill", 360, 205 + index * 58, 560, 48, 8, 8)
            end
            love.graphics.setColor(selected and 1 or 0.7, selected and 0.85 or 0.7, selected and 0.25 or 0.95, 1)
            love.graphics.printf(settingsLabel(index), 380, 216 + index * 58, 520, "center")
        end
        love.graphics.setColor(1, 1, 1, 0.8)
        if Game.settingsIndex == 3 then
            drawCentered("Mover: Setas ou WASD | Pausar: ESC | Tela cheia: F11", 585, assets.font)
        elseif Game.settingsIndex == 4 then
            drawCentered(Game.controllerName and ("Detectado: " .. Game.controllerName .. " | Analógico esquerdo/D-pad")
                or "Nenhum controlador detectado", 585, assets.font)
        end
        drawCentered("ENTER/A selecionar | ESC/B voltar", 650, assets.font)
    elseif Game.state == "select" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("ESCOLHA SEU PERSONAGEM", 65, assets.titleFont)
        if Game.statusMessage then
            drawCentered(Game.statusMessage, 135, assets.font)
        end
        if Game.controllerName then
            drawCentered("Controle: " .. Game.controllerName, 170, assets.font)
        end
        for index, character in ipairs(characters) do
            local x = index == 1 and 350 or 850
            local selected = index == Game.selectedCharacter
            local cardY = 205
            love.graphics.setColor(selected and 1 or 0.55, selected and 0.85 or 0.55, 0.15, 1)
            love.graphics.setLineWidth(selected and 5 or 2)
            love.graphics.rectangle("line", x - 150, cardY, 300, 340, 8, 8)
            love.graphics.setColor(1, 1, 1)
            local image = assets.characters[index].idle
            local spriteScale = math.min(190 / image:getWidth(), 220 / image:getHeight())
            love.graphics.draw(image, x, cardY + 150, 0, spriteScale, spriteScale, image:getWidth() / 2, image:getHeight() / 2)
            love.graphics.setFont(assets.font)
            love.graphics.printf(character.name, x - 135, 475, 270, "center")
            love.graphics.setColor(1, 1, 1, 0.65)
            love.graphics.setFont(assets.smallFont)
            love.graphics.printf(index == 1 and "Soco" or "Intangivel", x - 125, 515, 250, "center")
            love.graphics.setFont(assets.font)
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
        drawCentered("← → / analógico para selecionar | ENTER/A começar", 610, assets.font)
    elseif Game.state == "credits" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("CREDITOS", 90, assets.titleFont)
        drawCentered("Criado por", 180, assets.font)
        for index, name in ipairs(CREDITS) do
            love.graphics.printf(name, 0, 225 + index * 42, Game.width, "center")
        end
        love.graphics.setColor(1, 1, 1, 0.8)
        drawCentered("ENTER/A ou ESC/B para voltar", 650, assets.font)
    elseif Game.state == "ending" then
        love.graphics.setColor(1, 1, 1)
        drawCentered("FIM DE JOGO", 115, assets.titleFont)
        drawCentered("A pista foi salva e a festa continua!", 220, assets.font)
        drawCentered("Obrigado por jogar Saws and Parties", 285, assets.font)
        drawCentered("Antony Rafael, Vitor Presot, Bruno Nunes, Vinicius Lucena,", 390, assets.font)
        drawCentered("Rafael Lisboa, Wallace Pedroso, Luis Gustavo e Lucas Mota", 430, assets.font)
        love.graphics.setColor(1, 1, 1, 0.8)
        drawCentered("ENTER/A ou ESC/B para pular", 650, assets.font)
    elseif Game.state == "playing" or Game.state == "countdown"
        or Game.state == "boss" or Game.state == "bossCountdown" then
        love.graphics.setColor(1, 1, 1, 1)
        for _, coin in ipairs(coins) do
            local image = currentFrame(assets.coins, 12)
            love.graphics.setColor(1.0, 0.8, 0.1, 0.22)
            love.graphics.circle(
                "fill",
                coin.x + coin.width / 2,
                coin.y + coin.height / 2,
                math.max(coin.width, coin.height) * 0.9
            )
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(image, coin.x, coin.y, 0, coin.width / image:getWidth(), coin.height / image:getHeight())
        end
        for _, saw in ipairs(saws) do
            local image = currentFrame(assets.saws, 10)
            love.graphics.draw(image, saw.x, saw.y, 0, saw.width / image:getWidth(), saw.height / image:getHeight())
        end
        if Game.state == "boss" or Game.state == "bossCountdown" then
            drawBoss()
            for _, saw in ipairs(bossSaws) do
                local image = currentFrame(assets.saws, 12)
                love.graphics.draw(
                    image,
                    saw.x + saw.width / 2,
                    saw.y + saw.height / 2,
                    saw.angle,
                    saw.width / image:getWidth(),
                    saw.height / image:getHeight(),
                    image:getWidth() / 2,
                    image:getHeight() / 2
                )
            end
        end
        local function drawPlayer(target)
            local image = playerImage(target)
            local centerX, centerY = playerCenter(target)
            local alpha = target.alive and (target.character == 2 and target.abilityActive and 0.42 or 1) or 0.18
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(image, centerX, centerY, 0,
                target.facing < 0 and -target.scale or target.scale, target.scale,
                image:getWidth() / 2, image:getHeight() / 2)
        end
        drawPlayer(player)
        if player2 then drawPlayer(player2) end
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setColor(0.015, 0.01, 0.06, 0.88)
        love.graphics.rectangle("fill", 12, 10, Game.width - 24, 86, 10, 10)
        love.graphics.setColor(0.2, 0.8, 1, 0.55)
        love.graphics.rectangle("line", 12, 10, Game.width - 24, 86, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(assets.font)
        local stageLabel = (Game.state == "boss" or Game.state == "bossCountdown")
            and "BOSS FINAL" or (Game.mode == "infinite"
                and ("INFINITO - RODADA %d"):format(Game.infiniteRound)
                or ("FASE %d/6"):format(Game.level))
        love.graphics.print(stageLabel, 32, 19)
        local coinGoal = Game.mode == "infinite" and Game.infiniteGoal or 12
        love.graphics.printf(("MOEDAS %d/%d"):format(Game.coins, coinGoal), 0, 19, Game.width, "center")
        local displayedTime = Game.state == "boss" and Game.bossTime or Game.timeLeft
        love.graphics.printf(("TEMPO %d"):format(math.ceil(displayedTime)), -32, 19, Game.width, "right")
        local function drawAbilityHud(target, x, label)
            local status = target.abilityActive and "ATIVA"
                or (target.abilityCooldown > 0 and ("%.1fs"):format(target.abilityCooldown) or "PRONTA")
            local color = not target.alive and {0.5, 0.5, 0.5} or target.abilityActive and {0.2, 1, 0.3} or
                (target.abilityCooldown > 0 and {1, 0.2, 0.2} or {1, 0.85, 0.25})
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.print(label .. ": " .. status, x, 48)
            local progress = target.abilityActive and 1 or 1 - target.abilityCooldown / 6
            love.graphics.setColor(0.08, 0.08, 0.15, 1)
            love.graphics.rectangle("fill", x, 70, 150, 8)
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", x, 70, 150 * progress, 8)
        end
        drawAbilityHud(player, 32, player.character == 1 and "Soco" or "Intangivel")
        if player2 then
            drawAbilityHud(player2, 690, player2.character == 1 and "Soco" or "Intangivel")
        end
        if Game.state == "countdown" or Game.state == "bossCountdown" then
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)
            love.graphics.setColor(1, 1, 1, 1)
            drawCentered(Game.state == "bossCountdown" and "BOSS FINAL" or "PREPARE-SE", 220, assets.font)
            drawCentered(tostring(math.ceil(Game.countdown)), 275, assets.titleFont)
        elseif Game.paused then
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)
            love.graphics.setColor(1, 1, 1)
            drawCentered("JOGO PAUSADO", 310, assets.titleFont)
            drawCentered("ESC para continuar", 390, assets.font)
        end
    else
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)
        love.graphics.setColor(1, 1, 1)
        drawCentered(Game.statusMessage, 270, assets.titleFont)
        drawCentered("ENTER/A para voltar à seleção", 370, assets.font)
    end

    love.graphics.pop()
end
