cloudTimer = 10

function updateClouds(dt)
    cloudTimer = cloudTimer - dt
    if cloudTimer <= 0 then
        cloudTimer = 10
        event = 7
        trigger = 3
        gameState = 2
    end
end

function drawClouds()
    love.graphics.draw(sprites.clouds, 0, 0, null)
end
