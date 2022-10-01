player = world:newRectangleCollider(100, love.graphics.getHeight() / 2, 45, 35, {
    collision_class = "Player"
})
player.speed = 8000
player.alive = true
player.rotation = 0
player.animation = animations.fly

mouse = {}

function updatePlayer(dt)

    mouse.x, mouse.y = love.mouse.getPosition()

    -- Get current velocity of player
    local vx, vy = player:getLinearVelocity()
    -- Get current position of player
    local px, py = player:getPosition()

    if py < mouse.y and vy < 250 then
        player:applyForce(0, player.speed)
    elseif py > mouse.y and vy > -250 then
        player:applyForce(0, -player.speed)
    end

    if player:enter("Bounds") then
        if py < love.graphics.getHeight() / 2 then
            player:applyLinearImpulse(0, 1000)
        else
            player:applyLinearImpulse(0, -1000)
        end
    end

    player.animation:update(dt)

end

function drawPlayer()
    if player.alive then
        local px, py = player:getPosition()
        player.animation:draw(sprites.player, px, py, playerMouseAngle(px, py), 0.5, 0.5, 50, 50)
    end
end

-- Control rotation of player
function playerMouseAngle(px, py)
    -- Don't let player turn backwards and prevent strange rotation when mouse is near player
    local mx = 0
    if mouse.x < 300 then
        mx = 300
    else
        mx = mouse.x
    end
    -- Angle between two points in radians is atan2(y1 - y2, x1 - x2)
    return math.atan2(mouse.y - py, mx - px)
end
