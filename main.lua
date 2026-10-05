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
}

local assets = {}
local player
local coins = {}
local saws = {}

local characters = {
    {
        name = "Bruno",
        idle = "sprites/sPersonagem2/b6bfda77-a011-4736-98f2-588dfa55bdf5.png",
        walk = {
            "sprites/sPersonagemCorre2/f9944722-b388-4d94-bf51-8fce15ca37c0.png",
            "sprites/sPersonagemCorre2/aecc1f46-2542-42b7-8267-12ccdd2b5520.png",
            "sprites/sPersonagemCorre2/3f3b3436-6192-48e9-bc60-649e8f3a4234.png",
            "sprites/sPersonagemCorre2/0e76ca2a-0dc4-48e9-b593-214800769c36.png",
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
    return love.graphics.newImage(path)
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

local function overlaps(a, b)
    return a.x < b.x + b.width
        and b.x < a.x + a.width
        and a.y < b.y + b.height
        and b.y < a.y + a.height
end

local function currentFrame(frames, fps)
    return frames[math.floor(Game.animationTime * fps) % #frames + 1]
end

local function play(sound)
    if sound then
        sound:stop()
        sound:play()
    end
end

local function spawnCoin()
    local image = assets.coins[1]
    return {
        x = love.math.random(80, Game.width - 80),
        y = love.math.random(120, Game.height - 80),
        width = image:getWidth() * 0.9,
        height = image:getHeight() * 0.9,
    }
end

local function spawnSaw(index)
    local image = assets.saws[1]
    local speed = 125 + Game.level * 30 + index * 12
    return {
        x = love.math.random(100, Game.width - 150),
        y = love.math.random(100, Game.height - 150),
        width = image:getWidth() * 0.55,
        height = image:getHeight() * 0.55,
        vx = love.math.random() < 0.5 and speed or -speed,
        vy = love.math.random() < 0.5 and speed or -speed,
    }
end

local function startLevel(level)
    Game.state = "playing"
    Game.level = level
    Game.coins = 0
    Game.timeLeft = level == 1 and 35 or 30
    Game.paused = false
    player = { x = Game.width / 2, y = Game.height / 2, width = 52, height = 52, facing = 1, moving = false }
    coins = {}
    saws = {}

    for _ = 1, 12 do
        table.insert(coins, spawnCoin())
    end
    for index = 1, level do
        table.insert(saws, spawnSaw(index))
    end

    if assets.music then
        assets.music:setLooping(true)
        assets.music:play()
    end
end

local function returnToSelection(message)
    Game.state = "select"
    Game.statusMessage = message
    Game.paused = false
    if assets.music then
        assets.music:stop()
    end
end

local function drawCentered(text, y, font)
    love.graphics.setFont(font)
    love.graphics.printf(text, 0, y, Game.width, "center")
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.math.setRandomSeed(os.time())
    assets.background = loadImage("sprites/Sprite6/b4fb1ee4-44a0-4392-95d2-1636c1094d13.png")
    assets.characters = {}
    for index, character in ipairs(characters) do
        assets.characters[index] = { idle = loadImage(character.idle), walk = loadImages(character.walk) }
    end
    assets.coins = loadImages(coinFrames)
    assets.saws = loadImages(sawFrames)
    assets.font = love.graphics.newFont("datafiles/HomeVideo-BLG6G.ttf", 28)
    assets.titleFont = love.graphics.newFont("datafiles/HomeVideo-BLG6G.ttf", 52)
    assets.music = love.audio.newSource("sounds/musicaJogo/musicaJogo.mp3", "stream")
    assets.coinSound = love.audio.newSource("sounds/somMoeda/somMoeda.mp3", "static")
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

    if Game.state == "menu" and (key == "return" or key == "space") then
        Game.state = "select"
        return
    end

    if Game.state == "select" then
        if key == "left" or key == "a" then
            Game.selectedCharacter = 1
        elseif key == "right" or key == "d" then
            Game.selectedCharacter = 2
        elseif key == "return" or key == "space" then
            startLevel(1)
        elseif key == "escape" then
            Game.state = "menu"
        end
        return
    end

    if Game.state == "playing" and key == "escape" then
        Game.paused = not Game.paused
        if Game.paused then
            love.audio.pause()
        else
            love.audio.resume()
        end
        return
    end

    if (Game.state == "gameover" or Game.state == "victory") and (key == "return" or key == "space") then
        returnToSelection()
    elseif key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    Game.animationTime = Game.animationTime + dt
    if Game.state ~= "playing" or Game.paused then
        return
    end

    Game.timeLeft = Game.timeLeft - dt
    if Game.timeLeft <= 0 then
        returnToSelection("O tempo acabou. Tente novamente!")
        return
    end

    local horizontal = (love.keyboard.isDown("right", "d") and 1 or 0) - (love.keyboard.isDown("left", "a") and 1 or 0)
    local vertical = (love.keyboard.isDown("down", "s") and 1 or 0) - (love.keyboard.isDown("up", "w") and 1 or 0)
    player.moving = horizontal ~= 0 or vertical ~= 0
    if horizontal ~= 0 and vertical ~= 0 then
        horizontal = horizontal * 0.707
        vertical = vertical * 0.707
    end
    if horizontal ~= 0 then
        player.facing = horizontal
    end

    local speed = 235
    player.x = clamp(player.x + horizontal * speed * dt, 0, Game.width - player.width)
    player.y = clamp(player.y + vertical * speed * dt, 60, Game.height - player.height)

    for _, saw in ipairs(saws) do
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
        if overlaps(player, saw) then
            Game.state = "gameover"
            Game.statusMessage = "Game Over!"
            assets.music:stop()
            return
        end
    end

    for index = #coins, 1, -1 do
        if overlaps(player, coins[index]) then
            table.remove(coins, index)
            Game.coins = Game.coins + 1
            play(assets.coinSound)
            if Game.coins == 12 then
                if Game.level == 4 then
                    Game.state = "victory"
                    Game.statusMessage = "Vitória conquistada!"
                    assets.music:stop()
                else
                    startLevel(Game.level + 1)
                end
            end
        end
    end
end

function love.draw()
    local scaleX = love.graphics.getWidth() / Game.width
    local scaleY = love.graphics.getHeight() / Game.height
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(assets.background, 0, 0, 0, Game.width / assets.background:getWidth(), Game.height / assets.background:getHeight())

    if Game.state == "menu" then
        love.graphics.setColor(0, 0, 0, 0.65)
        love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)
        love.graphics.setColor(1, 1, 1)
        drawCentered("SAWS AND PARTIES", 200, assets.titleFont)
        drawCentered("Colete moedas e fuja das serras!", 300, assets.font)
        drawCentered("ENTER  Jogar", 390, assets.font)
        drawCentered("F11  Tela cheia     ESC  Sair", 440, assets.font)
    elseif Game.state == "select" then
        love.graphics.setColor(0, 0, 0, 0.65)
        love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)
        love.graphics.setColor(1, 1, 1)
        drawCentered("ESCOLHA SEU PERSONAGEM", 65, assets.titleFont)
        if Game.statusMessage then
            drawCentered(Game.statusMessage, 135, assets.font)
        end
        for index, character in ipairs(characters) do
            local x = index == 1 and 350 or 850
            local selected = index == Game.selectedCharacter
            love.graphics.setColor(selected and 1 or 0.55, selected and 0.85 or 0.55, 0.15, 1)
            love.graphics.rectangle("line", x - 135, 220, 270, 310, 5)
            love.graphics.setColor(1, 1, 1)
            local image = assets.characters[index].walk[1]
            local spriteScale = math.min(220 / image:getWidth(), 220 / image:getHeight())
            love.graphics.draw(image, x - image:getWidth() * spriteScale / 2, 270, 0, spriteScale, spriteScale)
            drawCentered("", 0, assets.font)
            love.graphics.printf(character.name, x - 135, 500, 270, "center")
        end
        love.graphics.setColor(1, 1, 1)
        drawCentered("← → para selecionar    ENTER para começar", 610, assets.font)
    elseif Game.state == "playing" then
        for _, coin in ipairs(coins) do
            local image = currentFrame(assets.coins, 12)
            love.graphics.draw(image, coin.x, coin.y, 0, coin.width / image:getWidth(), coin.height / image:getHeight())
        end
        for _, saw in ipairs(saws) do
            local image = currentFrame(assets.saws, 10)
            love.graphics.draw(image, saw.x, saw.y, 0, saw.width / image:getWidth(), saw.height / image:getHeight())
        end
        local characterAssets = assets.characters[Game.selectedCharacter]
        local image = player.moving and currentFrame(characterAssets.walk, 9) or characterAssets.idle
        local spriteScale = player.height / image:getHeight()
        love.graphics.draw(
            image,
            player.x + (player.facing == -1 and player.width or 0),
            player.y,
            0,
            spriteScale * player.facing,
            spriteScale
        )
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Game.width, 55)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(assets.font)
        love.graphics.print(("Fase: %d/4"):format(Game.level), 24, 14)
        love.graphics.printf(("Moedas: %d/12"):format(Game.coins), 0, 14, Game.width, "center")
        love.graphics.printf(("Tempo: %d"):format(math.ceil(Game.timeLeft)), -24, 14, Game.width, "right")
        if Game.paused then
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
        drawCentered("ENTER para voltar à seleção", 370, assets.font)
    end

    love.graphics.pop()
end
