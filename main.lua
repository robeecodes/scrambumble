function love.load()

    math.randomseed(os.time())

    love.mouse.setVisible(true)

    -- Library to manipulate physics engine
    wf = require('libs/windfield/windfield')
    -- Animation library
    anim8 = require('libs/anim8')
    -- Save data
    require('libs/show')

    gameState = 1

    -- Font for all text etc
    gameFont = love.graphics.newFont(30)

    -- Music and SFX
    sounds = {}

    -- Sprites
    sprites = {}
    sprites.clouds = love.graphics.newImage("assets/img/clouds.png")
    sprites.player = love.graphics.newImage("assets/img/player_grid.png")
    sprites.daisy = love.graphics.newImage("assets/img/daisy_grid.png")
    sprites.wasp = love.graphics.newImage("assets/img/wasp_grid.png")
    sprites.sting = love.graphics.newImage("assets/img/sting.png")

    -- Animations
    local player_grid = anim8.newGrid(100, 100, sprites.player:getWidth(), sprites.player:getHeight())
    local daisy_grid = anim8.newGrid(100, 100, sprites.daisy:getWidth(), sprites.daisy:getHeight())
    local wasp_grid = anim8.newGrid(100, 100, sprites.wasp:getWidth(), sprites.wasp:getHeight())

    animations = {}
    animations.fly = anim8.newAnimation(player_grid("1 - 2", 1), 0.05)
    animations.daisy = anim8.newAnimation(daisy_grid("1 - 4", 1), 0.5)
    animations.wasp = anim8.newAnimation(player_grid("1 - 2", 1), 0.05)

    -- Creating world physics
    world = wf.newWorld(0, 0, false)
    world:setQueryDebugDrawing(true)
    -- Set Colliders
    world:addCollisionClass("Danger", {
        ignores = {"Danger"}
    })
    world:addCollisionClass("Flowers", {
        ignores = {"Flowers", "Danger"}
    })
    world:addCollisionClass("Player", {
        ignores = {"Flowers"}
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
    -- Lightning
    -- Clouds
    require("assets/entities/clouds")

    -- Initial score
    score = 0

    -- Event Trigger
    event = 7
    trigger = 3

    -- Init gameState
    gameState = 1
end

function love.update(dt)

    world:update(dt)

    updatePlayer(dt)
    updateFlowers(dt)

    if event > 0 then
        event = event - dt
    end

    if event <= 0 then
        gameState = 4
    end

    if gameState ~= 1 then
        if trigger > 0 then
            trigger = trigger - dt
        end
    end

    if gameState == 4 then
        updateClouds(dt)
    end

    if gameState == 3 then
        if trigger <= 0 then
            updateWasps(dt)
        end
    end

    if gameState == 1 then
        destroyAll()
    end
end

function love.draw()

    -- love.graphics.setBackgroundColor(255, 255, 255)

    if gameState ~= 1 then
        if trigger > 0 then
            love.graphics.printf("Countdown: " .. math.ceil(trigger) .. "s", love.graphics.getWidth() / 2,
                love.graphics.getHeight() / 2, love.graphics.getWidth() / 2, "left")
        end
    end

    if gameState == 3 then
        if trigger <= 0 then
            drawWasps()
        end
    end

    world:draw()

    drawPlayer()
    drawFlowers()

    if gameState == 4 then
        if trigger <= 0 then
            drawClouds()
        end
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

    -- Pause with spacebar
    if key == "space" then
    end
end

function destroyAll()
    destroyWasps()
    for i, stinger in ipairs(stingers) do
        destroyStingers(stinger, i)
    end
end
