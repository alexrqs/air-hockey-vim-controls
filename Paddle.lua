Paddle = Class{}

PADDLE_SPEED = 200

function Paddle:init(x, y, width, height)
    -- starting position
    self.x = x
    self.y = y
    -- dimensions
    self.width = width
    self.height = height
    -- speed
    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Paddle:moveUp()
    self.dy = -PADDLE_SPEED
end

function Paddle:moveDown()
    self.dy = PADDLE_SPEED
end

function Paddle:stop()
    self.dy = 0
end