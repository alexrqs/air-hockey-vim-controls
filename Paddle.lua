Paddle = Class {}

PADDLE_SPEED = 200

function Paddle:init(x, y, width, height, field)
    -- starting position
    self.x = x
    self.y = y
    -- dimensions
    self.width = width
    self.height = height
    -- speed
    self.dy = 0
    self.dx = 0
    -- identify the left or right field with 0 or 1 respectively 
    self.field = field
end

function Paddle:update(dt)
    -- TODO add fps for debugging
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
    local isLeftField = self.field == 0

    if isLeftField then

        if self.dx < 0 then
            self.x = math.max(0, self.x + self.dx * dt)
        else
            self.x = math.min((VIRTUAL_WIDTH / 3), self.x + self.dx * dt)
        end
    else
        if self.dx < 0 then
            self.x = math.max((VIRTUAL_WIDTH / 3) * 2, self.x + self.dx * dt)
        else
            self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
        end
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

function Paddle:moveLeft()
    self.dx = -PADDLE_SPEED
end

function Paddle:moveRight()
    self.dx = PADDLE_SPEED
end

function Paddle:stop()
    self.dy = 0
    self.dx = 0
end
