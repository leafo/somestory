debugMode = false
drawDebug = false
stableMemory = true
paused = false

require "tlz"
require "scenes"
---------------------------------

function love.load()
	print('loading 0%')
	tlz.plainYellowBG = love.graphics.newImage("graphics/plainYellow.png")
	tlz.plainBlackBG = love.graphics.newImage("graphics/plainBlack.png")
	tlz.frame = 0
	tlz.collider = Collider:new()
	Player:load()

	tlz.collider:addScene(scenes.home)

	--tlz.collider:addScene(scenes.home)
	tlz.noBugsYet = true
	local playa = Player:new(140,136)
	tlz.collider:add(playa,scenes.home)
	tlz.collider:addUniqueID(playa,'Player')
	--tlz.collider.workingScene = scenes.home
	--scenes.home:spawn()
	scenes.home:spawn()
	--Player.usedInScenes = Player.usedInScenes + 1
	--scenes.yourRoom.x = scenes.yourRoom.x
	--scenes.yourRoom.y = scenes.yourRoom.y - tlz.SCREEN_HEIGHT
	print(scenes.yourRoom.x,scenes.yourRoom.y)
	love.graphics.setBackgroundColor(9,9,17)
	print('loading 100%')
end

function love.draw()
	tlz.collider:draw()
	if debugMode then
		love.graphics.setColor(255,0,0,255 * 0.8)
		love.graphics.print('Memory(kB): ' .. collectgarbage('count'), 5,5)
		love.graphics.print('FPS: ' .. love.timer.getFPS(), 5,25)
		love.graphics.print('Mouse: (' .. love.mouse.getX() .. ',' .. love.mouse.getY() .. ')', 85,25)
		love.graphics.setColor(255,255,255)
	end
end

function love.focus(focused)
	if not debugMode then paused = not focused end
end

SPF = 1 / 60
function love.update(dt)
	if debugMode and stableMemory then
		collectgarbage()
	end
	if not paused then
		local cap_dt = math.min(dt,SPF)
		tlz.frame = tlz.frame + 1
		
		tlz.collider:update(cap_dt)
		
		love.keyboard.resetKeys()
	end
end

function love.keypressed(key)
	love.keyboard.keysPressed[key] = true
	--print(key..' pressed '..love.timer.getTime())
	if key == '`' then
		debugMode = not debugMode
	end
	if key == '1' and debugMode then
		paused = not paused
		--[[paused = true
		love.audio.pause()
		debug.debug()
		love.audio.resume()
		paused = false]]--
	end
	if key == '2' and debugMode then
		drawDebug = not drawDebug
	end
	if key == '3' and debugMode then
		stableMemory = not stableMemory
	end
end

function love.keyreleased(key)
	--print(key..' released '..love.timer.getTime())
end

function love.mousepressed(x,y,key)
	--game.mousepressed(x,y,key)
end