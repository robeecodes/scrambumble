function love.load()

    love.mouse.setVisible(true)

    -- Library to manipulate physics engine
    wf = require('libs/windfield/windfield')
    -- Animation library
    anim8 = require('libs/anim8')
    -- Camera library
    humpCam = require('libs/hump/camera')
    -- Save data
    require('libs/show')

    gameState = 1

    -- Font for all text etc
    gameFont = love.graphics.newFont("assets/SigmarOne-Regular.ttf")

    -- Music and SFX
    sounds = {}

    -- Sprites
    sprites = {}
    sprites.player = love.graphics.newImage("assets/img/player_grid.png")

    -- Animations
    local player_grid = anim8.newGrid(100, 100, sprites.player:getWidth(), sprites.player:getHeight())

    animations = {}
    animations.fly = anim8.newAnimation(player_grid("1 - 2", 1), 0.05)

    -- Creating world physics
    world = wf.newWorld(0, 0, false)
    world:setQueryDebugDrawing(true)
    world:addCollisionClass("Player")
    world:addCollisionClass("Bounds")

    -- Don't let the player leave the window
    top = world:newRectangleCollider(0, 0, love.graphics.getWidth(), 1, {collision_class = "Bounds"})
    bottom = world:newRectangleCollider(0, love.graphics.getHeight(), love.graphics.getWidth(), 1, {collision_class = "Bounds"})
    top:setType("static")
    bottom:setType("static")


    -- Entities
    -- Player
    require("assets/entities/player")
    -- Flowers
    -- Wasps
    -- Raindrops
    -- Lightning
    -- Clouds

end

function love.update(dt)

    world:update(dt)

    updatePlayer(dt)

end

function love.draw()

    love.graphics.setBackgroundColor(255, 255, 255)

    world:draw()

    drawPlayer()
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
