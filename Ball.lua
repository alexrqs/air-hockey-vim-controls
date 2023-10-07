Ball = Class {}

function Ball:init(x, y, radius)
    self.x = x
    self.y = y
    self.radius = radius
    self.dy = 0
    self.dx = 0
end

function Ball:collides(paddle)
    local ball = self

    -- print('ball.x: ' .. ball.x .. ' ball.y: ' .. ball.y .. ' paddle.x: ' .. paddle.x .. ' paddle.y: ' .. paddle.y .. ' paddle.height: ' .. paddle.height .. ' paddle.width: ' .. paddle.width)
    -- TODO also take in consideration the GAP between the paddle and the end of the screen
    if paddle.x < 100 then
        local collideWithLeftPaddleX = ball.x - ball.radius < paddle.x + paddle.width
        local collideWithLeftFromBehind = ball.x + ball.radius > paddle.x
        local collideWithPaddleYTop = ball.y - ball.radius > paddle.y
        local collideWithPaddleYBottom = ball.y + ball.radius < paddle.y + paddle.height

        if collideWithLeftFromBehind and collideWithLeftPaddleX and collideWithPaddleYTop and collideWithPaddleYBottom then
            print('true paddle x < 100 ballx ' .. ball.x .. ' bally ' .. ball.y)
            print('paddlex ' .. paddle.x .. ' paddley ' .. paddle.y)
            print('paddleheight ' .. paddle.height .. ' paddlewidth ' .. paddle.width)
            return true
        end

        return false
    else
        local collideWithRightPaddleX = ball.x + ball.radius > paddle.x
        local collideWithPaddleYTop = ball.y - ball.radius > paddle.y
        local collideWithPaddleYBottom = ball.y + ball.radius < paddle.y + paddle.height

        if collideWithRightPaddleX and collideWithPaddleYTop and collideWithPaddleYBottom then
            return true
        end

        return false
    end

    return false
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.circle('fill', self.x, self.y, self.radius)
end
