drops = {}

rainTimer = 10
maxRain = 5

function updateRain(dt)
    rainTimer = rainTimer - dt
    if rainTimer <= 0 then
        if maxRain < 20 then
            maxRain = maxRain + 1
        end
        rainTimer = 10
        event = 7
        trigger = 3
        gameState = 2
    end

    if #drops < maxRain then
        spawnRain()
    end

    if #drops > 0 then
        for i, drop in ipairs(drops) do
            local px, py = drop:getPosition()
            drop:setPosition(px - drop.speed * dt, py)
            if px < -50 then
                destroyDrops(drop, i)
            end
        end
    end
end

function drawRain()
    for _, drop in ipairs(drops) do
        local px, py = drop:getPosition()
        love.graphics.draw(sprites.rain, px, py, null, 0.5, 0.5, 50, 50)
    end
end

function spawnRain()
    drop = world:newRectangleCollider(love.graphics.getWidth(), math.random(50, love.graphics.getHeight() - 50),
        25, 35, {
            collision_class = "Wet"
        })
    drop.speed = math.random(300, 1000)
    table.insert(drops, drop)
end

function destroyDrops(drop, i)
    drop:destroy()
    table.remove(drops, i)
end