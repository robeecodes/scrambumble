-- Store all flowers in a table
flowers = {}

-- Store all flower types in a table
flowerTypes = {}
flowerTypes[0] = {}
flowerTypes[0].animation = animations.daisy
flowerTypes[0].speedMin = 100
flowerTypes[0].speedMax = 300
flowerTypes[0].score = 200
flowerTypes[0].sprite = sprites.daisy
flowerTypes[1] = tulip
flowerTypes[2] = sunflower

-- Time for initial flower spawn
spawnTime = math.random(2, 4)
flowerTimer = spawnTime

function updateFlowers(dt)

    flowerTimer = flowerTimer - dt
    if flowerTimer <= 0 and #flowers < 10 then
        spawnFlowers()
        if spawnTime > 0.35 then
            spawnTime = spawnTime * 0.99
        end
        flowerTimer = spawnTime
    end

    for i, flower in ipairs(flowers) do
        flower.animation:update(dt)

        local px, py = flower:getPosition()

        moveFlower(flower, px, dt)

        if px < -50 then
            removeOverflow(flower, i)
        end

        if flower:enter("Player") then
            score = score + flower.score
            removeOverflow(flower, i)
        end

    end
end

function drawFlowers()
    for i, flower in ipairs(flowers) do
        local px, py = flower:getPosition()
        flower.animation:draw(flower.sprite, px, py, null, 0.5, 0.5, 50, 50)
    end
end

function spawnFlowers()
    flower = world:newRectangleCollider(love.graphics.getWidth() + 20, math.random(50, love.graphics.getHeight() - 50),
        25, 35, {
            collision_class = "Flowers",
        })
    flower.animation = flowerTypes[0].animation
    flower.speed = math.random(flowerTypes[0].speedMin, flowerTypes[0].speedMax)
    flower.score = flowerTypes[0].score
    flower.sprite = flowerTypes[0].sprite
    table.insert(flowers, flower)
end

function moveFlower(flower, px, dt)
    px = px - flower.speed * dt
    flower:setX(px)
end

function removeOverflow(flower, i)
    flower:destroy()
    table.remove(flowers, i)
end
