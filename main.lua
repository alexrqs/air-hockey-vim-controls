-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
local push = require 'push'

-- the "Class" library allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
-- docs https://hump.readthedocs.io/en/latest/class.html
-- srchttps://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- require order matters
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = WINDOW_WIDTH / 4
VIRTUAL_HEIGHT = WINDOW_HEIGHT / 4

BALL_RADIUS = 4
BALL_SPEED = 135

SCORE_TO_WIN = 10

function love.load()
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')
    -- love.graphics.setDefaultFilter("linear", "linear") -- default filter

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        borderless = true
    })

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('Nabla.ttf', 64)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
        canvas = true
    })
    push:setBorderColor{0, 0, 0} -- default value

    background = love.graphics.newImage("background.png")

    -- push:setBorderColor(30, 30, 30, 0.5) -- also accepts a table

    -- place a ball in the middle of the screen
    ball = Ball((VIRTUAL_WIDTH / 2) - BALL_RADIUS, (VIRTUAL_HEIGHT / 2) - BALL_RADIUS, BALL_RADIUS)

    -- 0 at the end for left field, 1 for right field
    player1 = Paddle(10, 30, 5, 20, 0)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20, 1)
    -- initialize score variables
    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    winningPlayer = 0

    -- 1. 'start' 
    -- 2. 'serve' waiting
    -- 3. 'play' 
    -- 4. 'done'
    gameState = 'start'
end

local function serveGame()
    ball.dy = BALL_SPEED

    if servingPlayer == 1 then
        ball.dx = BALL_SPEED
    else
        ball.dx = -BALL_SPEED
    end
end

local function handleBallPaddleCollisions(player)
    if ball:collides(player) then
        ball.dx = -ball.dx * 1
        -- is probably player.x + player.width
        --  or ball.halfRadius
        if ball.x < VIRTUAL_WIDTH / 2 then
            ball.x = player.x + player.width + 4
        else
            ball.x = player.x - 4
        end

        if ball.dy < 0 then
            ball.dy = -BALL_SPEED
        else
            ball.dy = BALL_SPEED
        end

        sounds['paddle_hit']:play()
    end

end

local function handleBallScreenCollisions()
    -- top screen collision
    if ball.y <= BALL_RADIUS then
        ball.y = BALL_RADIUS + 1
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - BALL_RADIUS then
        ball.y = VIRTUAL_HEIGHT - BALL_RADIUS
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end
end

function love.update(dt)
    -- print(dt)
    -- delta time helps to ensure that if any frame is skipped, the game will continue
    -- to run at the same speed and won't accelerate or decelarate depending on the cpu
    if gameState == 'serve' then
        serveGame()
    elseif gameState == 'play' then
        handleBallPaddleCollisions(player1)
        handleBallPaddleCollisions(player2)

        handleBallScreenCollisions()

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == SCORE_TO_WIN then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            sounds['score']:play()
            player1Score = player1Score + 1
            servingPlayer = 2

            if player1Score == SCORE_TO_WIN then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if love.keyboard.isDown('d') then
        player1:moveUp()
    elseif love.keyboard.isDown('f') then
        player1:moveDown()
    elseif love.keyboard.isDown('s') then
        player1:moveLeft()
    elseif love.keyboard.isDown('g') then
        player1:moveRight()
    else
        player1:stop()
    end

    if love.keyboard.isDown('k') then
        player2:moveUp()
    elseif love.keyboard.isDown('j') then
        player2:moveDown()
    elseif love.keyboard.isDown('h') then
        player2:moveLeft()
    elseif love.keyboard.isDown('l') then
        player2:moveRight()
    else
        player2:stop()
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:start()

    -- love.graphics.clear(40, 45, 52, 0.2)
    love.graphics.draw(background, 0, 0, 0, 5, 2.85)
    love.graphics.setColor(50, 100, 150)
    -- love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    -- same as request animation frame in js content has to be erased

    -- love.graphics.setColor(255, 100, 150)
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Space to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Space to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Get that punk!', 0, 20, VIRTUAL_WIDTH, 'center')

        -- TODO implement a sassy function about bullying the other player
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore(player1Score, player2Score)

    player1:render()
    player2:render()
    ball:render()

    -- end our drawing to push
    -- push:apply('end')
    push:finish()
end

function displayScore(scoreP1, scoreP2)
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(scoreP1), VIRTUAL_WIDTH / 2 - 64, VIRTUAL_HEIGHT / 5)
    love.graphics.print(tostring(scoreP2), VIRTUAL_WIDTH / 2 + 32, VIRTUAL_HEIGHT / 5)
end
