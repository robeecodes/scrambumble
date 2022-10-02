wasps = {}
stingers = {}

waspTimer = 10

maxWasps = 5

function updateWasps(dt)
    waspTimer = waspTimer - dt
    if waspTimer <= 0 then
        if maxWasps < 10 then
            maxWasps = maxWasps + 1
        end
        waspTimer = 10
        event = 7
        trigger = 3
        player.lives = 3
        gameState = 2
    end

    if #wasps < maxWasps then
        spawnWasps()
    end

    if #wasps > 0 then
        bounceWasps()
        if #stingers < 5 and waspTimer <= 9 then
            shoot()
        end
    end

    wasp.animation:update(dt)

    -- stingers
    if #stingers > 0 then
        for i, stinger in ipairs(stingers) do
            local px, py = stinger:getPosition()
            stinger:setPosition(px - stinger.speed * dt, py)
            if px < -50 then
                destroyStingers(stinger, i)
            end
        end
    end
end

function drawWasps()
    for _, wasp in ipairs(wasps) do
        local px, py = wasp:getPosition()
        wasp.animation:draw(sprites.wasp, px, py, null, 0.5, 0.5, 50, 50)
    end

    for _, stinger in ipairs(stingers) do
        local px, py = stinger:getPosition()
        love.graphics.draw(stinger.sprite, px, py, null, 0.25, 0.25, 50, 50)
    end
end

function spawnWasps()
    wasp = world:newRectangleCollider(love.graphics.getWidth() - 100, math.random(50, love.graphics.getHeight() - 50),
        25, 35, {
            collision_class = "Danger"
        })
    wasp.speed = math.random(3000, 5000)
    wasp.animation = animations.wasp
    table.insert(wasps, wasp)
end

function destroyWasps()
    for i, wasp in ipairs(wasps) do
        wasp:destroy()
        table.remove(wasps, i)
    end
end

function bounceWasps()
    for _, wasp in ipairs(wasps) do
        movement = math.random(0, 1)
        if movement == 0 then
            wasp:applyForce(0, wasp.speed)
        else
            wasp:applyForce(0, -wasp.speed)
        end
        wasp:setX(love.graphics.getWidth() - 100)
    end
end

function shoot()
    for _, wasp in ipairs(wasps) do
        go = math.random(0, 1)
        if go == 1 then
            local px, py = wasp:getPosition()
            stinger = spawnStingers(px, py)
        end
    end
end

function spawnStingers(px, py)
    stinger = world:newRectangleCollider(px, py, 10, 10, {
        collision_class = "Danger"
    })
    stinger.speed = math.random(300, 1000)
    stinger.sprite = sprites.sting
    table.insert(stingers, stinger)
    return stinger
end

function destroyStingers(stinger, i)
    stinger:destroy()
    table.remove(stingers, i)
end
