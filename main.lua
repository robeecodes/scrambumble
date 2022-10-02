function love.load()

    math.randomseed(os.time())

    -- init mouse
    love.mouse.setVisible(true)
    handCursor = love.mouse.getSystemCursor("hand")

    gameOverTimer = 100

    -- Library to manipulate physics engine
    wf = require('libs/windfield/windfield')
    -- Animation library
    anim8 = require('libs/anim8')
    -- Save data
    require('libs/show')

    -- Font for all text etc
    countFont = love.graphics.newFont("assets/SigmarOne-Regular.ttf", 150)
    gameFont = love.graphics.newFont("assets/SigmarOne-Regular.ttf", 20)

    -- Music and SFX
    sounds = {}

    -- Sprites
    sprites = {}
    sprites.clouds = love.graphics.newImage("assets/img/clouds.png")
    sprites.player = love.graphics.newImage("assets/img/player_grid.png")
    sprites.daisy = love.graphics.newImage("assets/img/daisy_grid.png")
    sprites.tulip = love.graphics.newImage("assets/img/tulip_grid.png")
    sprites.sunflower = love.graphics.newImage("assets/img/sunflower_grid.png")
    sprites.wasp = love.graphics.newImage("assets/img/wasp_grid.png")
    sprites.sting = love.graphics.newImage("assets/img/sting.png")
    sprites.rain = love.graphics.newImage("assets/img/rain.png")

    -- Animations
    local player_grid = anim8.newGrid(100, 100, sprites.player:getWidth(), sprites.player:getHeight())
    local daisy_grid = anim8.newGrid(100, 100, sprites.daisy:getWidth(), sprites.daisy:getHeight())
    local tulip_grid = anim8.newGrid(100, 100, sprites.tulip:getWidth(), sprites.tulip:getHeight())
    local sunflower_grid = anim8.newGrid(100, 100, sprites.sunflower:getWidth(), sprites.sunflower:getHeight())
    local wasp_grid = anim8.newGrid(100, 100, sprites.wasp:getWidth(), sprites.wasp:getHeight())

    animations = {}
    animations.fly = anim8.newAnimation(player_grid("1 - 2", 1), 0.05)
    animations.daisy = anim8.newAnimation(daisy_grid("1 - 4", 1), 0.5)
    animations.tulip = anim8.newAnimation(tulip_grid("1 - 4", 1), 0.5)
    animations.sunflower = anim8.newAnimation(sunflower_grid("1 - 4", 1), 0.5)
    animations.wasp = anim8.newAnimation(player_grid("1 - 2", 1), 0.05)

    -- Creating world physics
    world = wf.newWorld(0, 0, false)
    world:setQueryDebugDrawing(false)
    -- Set Colliders
    world:addCollisionClass("Danger", {
        ignores = {"Danger"}
    })
    world:addCollisionClass("Wet", {
        ignores = {"Wet"}
    })
    world:addCollisionClass("Flowers", {
        ignores = {"Flowers", "Danger", "Wet"}
    })
    world:addCollisionClass("Player", {
        ignores = {"Flowers", "Danger", "Wet"}
    })
    world:addCollisionClass("Bounds")

    -- Don't let the player leave the window
    top = world:newRectangleCollider(0, 0, love.graphics.getWidth(), 1, {
        collision_class = "Bounds"
    })
    bottom = world:newRectangleCollider(0, love.graphics.getHeight(), love.graphics.getWidth(), 1, {
        collision_class = "Bounds"
    })
    top:setType("static")
    bottom:setType("static")

    -- Entities
    -- Player
    require("assets/entities/player")
    -- Flowers
    require("assets/entities/flowers")
    -- Wasps
    require("assets/entities/wasps")
    -- Raindrops
    require("assets/entities/rain")
    -- Clouds
    require("assets/entities/clouds")

    -- Audio
    click = love.audio.newSource("assets/sound/click.wav", "static")
    countdown = love.audio.newSource("assets/sound/countdown.wav", "static")
    death = love.audio.newSource("assets/sound/death.wav", "static")
    hit = love.audio.newSource("assets/sound/hit.wav", "static")
    pickup = love.audio.newSource("assets/sound/flower.wav", "static")
    timeUp = love.audio.newSource("assets/sound/time-up.wav", "static")

    -- Initial score
    score = 0

    -- Event Trigger
    event = 7
    trigger = 3

    -- Init gameState
    gameState = 1

    -- bg
    bgImage = love.graphics.newImage("assets/map/bg.png")
    posX = 0
    imageWidth = 800

    -- splash
    splashScreen = love.graphics.newImage("assets/img/splash.png")
    startButtonImg = love.graphics.newImage("assets/img/start.png")
    startButton = {
        x = 233,
        y = 441,
        w = 330,
        h = 100
    }

    -- game over
    gameEnd = love.graphics.newImage("assets/img/win-screen.png")
    gameDeath = love.graphics.newImage("assets/img/death-screen.png")

end

function love.update(dt)

    if gameState == 0 then
        destroyAll()
        gameOverTimer = 100
        event = 7
        trigger = 3
        -- reconfig flowers
        spawnTime = math.random(2, 4)
        flowerTimer = spawnTime
        for i, flower in ipairs(flowers) do
            flower:destroy()
            table.remove(flowers, i)
        end
    end

    if gameState == 1 or gameState == 2 then
        destroyAll()
    end

    if gameState > 1 then
        world:update(dt)

        updatePlayer(dt)
        updateFlowers(dt)

        gameOverTimer = gameOverTimer - dt
        timeUpSound = true

        if gameOverTimer <= 0 then
            gameState = 0
        end

        if event > 0 then
            event = event - dt
        end

        if event <= 0 and gameState == 2 then
            gameState = math.random(3, 5)
        end

        if gameState ~= 2 then
            if trigger > 0 then
                trigger = trigger - dt
            end
        end

        if gameState == 5 then
            if trigger <= 0 then
                updateRain(dt)
            end
        end

        if gameState == 4 then
            if trigger <= 0 then
                updateClouds(dt)
            end
        end

        if gameState == 3 then
            if trigger <= 0 then
                updateWasps(dt)
            end
        end
    end

end

function love.draw()

    if gameState == 0 then
        if player.lives == 0 then
            love.graphics.draw(gameDeath, 0, 0)
        else
            love.graphics.draw(gameEnd, 0, 0)
        end
        love.graphics.setFont(countFont)
        love.graphics.setColor(30 / 255, 32 / 255, 48 / 255)
        love.graphics.printf(score, 0, (love.graphics.getHeight() / 2) - (countFont:getHeight() / 2),
            love.graphics.getWidth(), "center")
        love.graphics.setColor(255, 255, 255)
        local mx, my = love.mouse.getPosition()
        if (mx > startButton.x and mx < startButton.x + startButton.w) and
            (my > startButton.y and my < startButton.y + startButton.h) then
            love.mouse.setCursor(handCursor)
        else
            love.mouse.setCursor()
        end
    end

    if gameState == 1 then
        love.graphics.draw(splashScreen, 0, 0)
        love.graphics.draw(startButtonImg, startButton.x, startButton.y)
        local mx, my = love.mouse.getPosition()
        if (mx > startButton.x and mx < startButton.x + startButton.w) and
            (my > startButton.y and my < startButton.y + startButton.h) then
            love.mouse.setCursor(handCursor)
        else
            love.mouse.setCursor()
        end
    end

    if gameState > 1 then
        love.mouse.setCursor()
        printBackground()
        love.graphics.setFont(gameFont)
        love.graphics.printf("Score: " .. score, 5, 5, love.graphics.getWidth(), "left")
        love.graphics.printf("Time remaining: " .. math.ceil(gameOverTimer) .. "s", -5, 5, love.graphics.getWidth(),
            "right")
        love.graphics.printf("Lives: " .. player.lives, -5, 25, love.graphics.getWidth(), "right")
        if gameState == 2 then
            playCount = true
        end

        if gameState ~= 2 then
            if trigger > 0 then
                love.graphics.setFont(countFont)
                love.graphics.printf(math.ceil(trigger), 0,
                    (love.graphics.getHeight() / 2) - (countFont:getHeight() / 2), love.graphics.getWidth(), "center")
                if playCount then
                    countdown:play()
                    playCount = false
                end
            end
        end

        drawPlayer()
        drawFlowers()

        if gameState == 5 then
            if trigger <= 0 then
                drawRain()
            end
        end

        if gameState == 4 then
            if trigger <= 0 then
                drawClouds()
            end
        end

        if gameState == 3 then
            if trigger <= 0 then
                drawWasps()
            end
        end

        if math.ceil(gameOverTimer) <= 3 then
            love.graphics.setColor(255, 0, 0)
            love.graphics.setFont(countFont)
            love.graphics.printf(math.ceil(gameOverTimer), 0,
                (love.graphics.getHeight() / 2) - (countFont:getHeight() / 2), love.graphics.getWidth(), "center")
            if timeUpSound then
                timeUpSound = false
                timeUp:play()
            end
        end
        love.graphics.setColor(255, 255, 255)
    end
end

function love.keypressed(key, isrepeat)
    -- Exit game using esc
    if key == "escape" then
        local title = "Exit the game?"
        local message = "Do you really want to exit the game?"
        local buttons = {
            "Restart",
            "No",
            "Yes",
            escapebutton = 2
        }
        local exitGame = love.window.showMessageBox(title, message, buttons)
        if exitGame == 3 then
            love.event.quit()
        elseif exitGame == 1 then
            love.event.quit("restart")
        end
    end
end

function love.mousepressed(x, y, key)
    if gameState == 1 or gameState == 0 then
        if key == 1 then
            if (x > startButton.x and x < startButton.x + startButton.w) and
                (y > startButton.y and y < startButton.y + startButton.h) then
                click:play()
                player.lives = 3
                score = 0
                gameState = 2
            end
        end
    end
end

function destroyAll()
    destroyWasps()
    for i, stinger in ipairs(stingers) do
        destroyStingers(stinger, i)
    end
    for i, drop in ipairs(drops) do
        destroyDrops(drop, i)
    end
end

function printBackground()
    love.graphics.draw(bgImage, posX, 0)
    love.graphics.draw(bgImage, posX + imageWidth, 0)

    posX = posX - 0.5

    if posX <= -imageWidth then
        posX = 0
    end
end
