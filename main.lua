WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PEDAL_SPEED = 200

push = require 'push'
Class = require 'class'

require 'Ball'
require 'Paddle'

function love.load()
	math.randomseed(os.time())

	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong')

	smallFont = love.graphics.newFont('font.ttf', 8)


	scoreFont = love.graphics.newFont('font.ttf',32)

	victoryFont = love.graphics.newFont('font.ttf',24)

	sounds = {
		['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
		['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
		['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')

	}

	player1Score = 0
	player2Score = 0

	servingPlayer =  math.random(2) == 1 and 1 or 2 -- coin flip attırıyoruz.

	winningPlayer = 0

	paddle1 = Paddle(5,20,5,20)
	paddle2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)

	ball = Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,5,5)
	--ballX = VIRTUAL_WIDTH/2-2
	--ballY = VIRTUAL_HEIGHT/2-2

	--ballDX = math.random(2) == 1 and -100 or 100
	--ballDY = math.random(-50,50)
	if servingPlayer == 1 then --coin flipi tanımlaşmış olduk random seçmiyor yani
		ball.dx = 100
	else
		ball.dx = -100
	end

	gameState = 'start'

	push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
		fullscreen = false,
		vsync = true,
		resizable = true
	})

end
function love.resize(w,h)
	push:resize(w,h)
end

function love.update(dt)-- PC nin fps sine göre ayarlıyor.
	if gameState == 'play' then
		if ball.x<= 0 then
			player2Score = player2Score+1
			servingPlayer = 1
			sounds['point_scored']:play()
			ball:reset()
			ball.dx =100-- playerscore yaparsa öbürü servise başlar.

			if player2Score>= 3 then
				gameState = 'victory'
				winningPlayer = 2
			else
			    gameState = 'serve'
			end

		end

		if ball.x >= VIRTUAL_WIDTH-4 then
			player1Score = player1Score+1
			servingPlayer= 2
			sounds['point_scored']:play()
			ball:reset()
			ball.dx = -100
			if player1Score>= 3 then
				gameState = 'victory'
				winningPlayer = 1
			else
			    gameState = 'serve'
			end
		end

		if ball:collides (paddle1) then
			--deflect ball to the right
			ball.dx = -ball.dx*1.03
			ball.x = paddle1.x +5

			sounds['paddle_hit']:play()
			--keep velocity going in the same direction, but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10,150)
			    --do
			else
				ball.dy = math.random(10,150)
			end
		end

		if ball:collides (paddle2) then
			--deflect ball yo the left
			ball.dx = -ball.dx*1.03
			ball.x = paddle2.x -4

			sounds['paddle_hit']:play()

			if ball.dy <0 then
				ball.dy = -math.random(10,150)
			else
			    ball.dy = math.random(10,150)
			end
		end

		if ball.y <= 0 then
			--deflect the ball down
			ball.dy = -ball.dy
			ball.y = 0
			sounds['wall_hit']:play()
		end

		if ball.y>= VIRTUAL_HEIGHT-4 then
		    --deflect the ball up
		    ball.dy = -ball.dy
		    ball.y = VIRTUAL_HEIGHT-4
		    sounds['wall_hit']:play()
		end
	end

	paddle1:update(dt)
	paddle2:update(dt)

	if paddle1:Down(ball) then
		paddle1.dy =-PEDAL_SPEED

	elseif paddle1:Up(ball) then
		paddle1.dy = PEDAL_SPEED
	else
		paddle1.dy = 0

	end

	if love.keyboard.isDown('up') then
			--player2Y = math.max(0,player2Y - PEDAL_SPEED*dt)
		paddle2.dy = -PEDAL_SPEED
	elseif love.keyboard.isDown('down') then
			--player2Y = math.min(VIRTUAL_HEIGHT-20, player2Y+PEDAL_SPEED*dt)
		paddle2.dy = PEDAL_SPEED
	else
		paddle2.dy = 0
	end


	if gameState == 'play' then
		ball:update(dt)
		--ballX = ballX + ballDX * dt
		--ballY = ballY + ballDY * dt
	end
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState== 'victory' then
			gameState = 'start'
			player1Score=0
			player2Score=0
		    --do

		elseif gameState == 'serve' then
		    gameState = 'play'

		   	--ball:reset()
		   -- ballX = VIRTUAL_WIDTH/2-2
			--ballY = VIRTUAL_HEIGHT/2-2

			--ballDX = math.random(2) == 1 and -100 or 100
			--ballDY = math.random(-50,50)

		end
	end

end

function love.draw()
	push:apply('start')

	love.graphics.clear(40/255,45/255,52/255,255/255)

	ball:render()

	paddle1:render()
	paddle2:render()


	love.graphics.setFont(smallFont)

	if gameState=='start' then
		love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center' )

	elseif gameState=='serve' then
		love.graphics.printf("Player ".. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
		love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center' )

	elseif gameState=='victory' then
		love.graphics.setFont(victoryFont)
		love.graphics.printf("Player ".. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf("Press Enter to Serve!", 0, 42, VIRTUAL_WIDTH, 'center' )

		--victory message
	elseif gameState == 'play' then
	    --do
	
	end
	--if gameState=='start' then
		--love.graphics.printf(
		--"Hello Start State!",
		--0,
		--20,
		--VIRTUAL_WIDTH,
		--'center')
	    --do
	--elseif gameState == 'play' then
		--love.graphics.printf(
		--"Hello Play State!",
		--0,
		--20,
		--VIRTUAL_WIDTH,
		--'center')
	    --do
	--end



	love.graphics.setFont(scoreFont)
	love.graphics.print(player1Score, VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/3)
	love.graphics.print(player2Score, VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/3)



	displayFPS()

	push:apply('end')
end

function displayFPS()
	love.graphics.setColor(0, 1, 0, 1) --rgb için yaptık red için 0 green için 1 blue için 0 alpha için 1 seçtik.
	love.graphics.setFont(smallFont)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 40, 20) -- yanyana iki nokta string ekliyeceğimizi söyler.
	love.graphics.setColor(1, 1, 1, 1)
end