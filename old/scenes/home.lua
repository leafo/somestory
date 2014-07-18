scenes.home = {name = 'home', width = 432, height=240}

function scenes.home:load()
	self.imageBG = love.graphics.newImage("graphics/homeBG.png")
	self.imageFG = love.graphics.newImage("graphics/homeFG.png")
	
	self.spriteSheet = SpriteSheet:new("graphics/homeBGOverlay.png")
	self.spriteSheet:addAnim('',0,1,1,self.width,self.height)
	
	Char:load()
	Mom:load()
	Stairs:load()
	Door:load()
	
	--- sub scenes
	if scenes.yourRoom.closed then
		self.collider:openScene(scenes.yourRoom,true)
	else
		tlz.collider:addScene(scenes.yourRoom,'right',nil,-162,8,self)
	end
	scenes.yourRoom.timeScale = 0
end
function scenes.home:unload()
	self.imageBG = nil
	self.imageFG = nil
	self.spriteSheet:remove()
	Char:unload()
	Mom:unload()
	Stairs:unload()
	Door:unload()
	self.collider:closeScene(scenes.yourRoom)
end
function scenes.home:spawn()
	--additional scene images
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite.draw = function(self)
		love.graphics.setColor(255,255,255,255 * self.scene.alpha)
		love.graphics.draw(self.spriteSheet.image,self:getFrame(),math.ceil(self.x),math.ceil(self.y))
		love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha)
		love.graphics.draw(self.scene.imageFG,math.ceil(self.x),math.ceil(self.y))
	end
	self.sprite.reinit = function(self)
		self.spriteSheet = self.scene.spriteSheet
	end
	self.collider:addNonCollidable(self.sprite,self,-5)

	--borders
	self.collider:add(Wall:new(96,40,8,184,tlz.RADDOWN),self)
	self.collider:add(Wall:new(96,232,8,232,tlz.RADRIGHT),self)
	self.collider:add(Wall:new(336,232,8,184,tlz.RADUP),self)
	self.collider:add(Wall:new(336,40,8,104,tlz.RADLEFT),self)
	self.collider:add(Wall:new(96,40,8,104,tlz.RADRIGHT),self)
	
	--walls
	self.collider:add(Wall:new(332,188,4,37,tlz.RADLEFT),self)
	self.collider:add(Wall:new(176,104,8,24,tlz.RADRIGHT),self) -- couch top
	self.collider:add(Wall:new(176,168,8,24,tlz.RADRIGHT),self) -- couch bot
	self.collider:add(Wall:new(192,104,8,72,tlz.RADDOWN),self) -- couch mid
	self.collider:add(Wall:new(320,40,8,104,tlz.RADDOWN),self) -- counter length
	self.collider:add(Wall:new(336,136,8,16,tlz.RADLEFT),self) -- counter bot-corner
	
	self.collider:add(CircleWall:new(156,76,20.5),self) -- dining table
	self.collider:add(CircleWall:new(257,104,20.5),self) -- kitchen table
	
	--objects
	self.collider:add(Mom:new(295,86),self)
	self.collider:addNonCollidable(Stairs:new(333,200,scenes.yourRoom),self,9)
	self.entryToOutsideHome = Door:new(200,3,scenes.outsideHome,scenes.outsideHome.entryToHome)
	self.collider:addNonCollidable(self.entryToOutsideHome,self,-7)
	
	--sub scenes
	scenes.yourRoom:spawn()
end
function scenes.home:draw()
	love.graphics.setColor(255,255,255,255 * self.bgAlpha)
	love.graphics.draw(self.imageBG,math.ceil(self.x),math.ceil(self.y))
end

------------Room Specific Objects-----------
class "Mom" : extends(Circle) {
	radius = 12,
	xVel = 0,
	yVel = 0,
	movSpd = 9,
	movAcl = 9 / 0.3,
	solid = true,
	dMoveY = 0,
	moveY = 10,
	waitTime = 0
}
function Mom:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new("graphics/mom.png")
		self.spriteSheet:addAnim('idle',0,1,1,24,24)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Mom:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet:remove()
		-------------------------------
		self.loaded = false
	end
end
function Mom:init(x,y)
	self:super('init',x,y)
	
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite:setState('idle')
	
	self.bubble = PlayerBubble:new(self,'large')
end
function Mom:reinit()
	self.sprite.spriteSheet = self.spriteSheet
end
function Mom:init_collider()
	self.collider:add(self.bubble,self.scene)

	self.collider:makeCollidable(self,Wall)
	self.collider:makeCollidable(self,CircleWall)
	self.collider:makeCollidable(self,Player)
	
	self.collider:makeThisMovableByThat(self,Wall)
	self.collider:makeThisMovableByThat(self,CircleWall)
	self.collider:makeThisMovableByThat(Player,self)
end
function Mom:interact() 
	if self.state ~= 'interact' then
		self.state = 'interact'
		self.texts = {}
		local text = Text:new(self.scene.worldX + 337,self.scene.worldY + 55)
		text.defaultDelay = 0.06
		text:addChar('h')
		text:addChar('i',-8,8)
		text:addChar('s',-8,16)
		text:addChar('w',-9,8)
		text:addChar('e',-10,8)
		text:addChar('e',-9,8)
		text:addChar('t',-8,8)
		text:addChar('y',-7,8)
		text:addChar('!',-6,8)
		self.collider:addNonCollidable(text,self.scene,1)
		table.insert(self.texts,text)
		self.bubble.canInteract = false
		
		text = Text:new(self.scene.worldX + 242,self.scene.worldY + 24,text)
		text.defaultDelay = 0.06
		text:addChar('',0,0,.5)
		text:addString('did')
		text:addString('you clean your room?',-8*3,10)
		self.collider:addNonCollidable(text,self.scene,1)
		table.insert(self.texts,text)
		
		--[[text = Text:new(343,73+8,text)
		text:addString('some')
		self.collider:addNonCollidable(text,3)
		table.insert(self.texts,text)
		
		text = Text:new(343,73+16,text)
		text:addString('food')
		self.collider:addNonCollidable(text,3)
		table.insert(self.texts,text)]]--
	end
end
function Mom:updateEndFrame(dt)
	if self.state == 'interact' then
		if self.bubble.alpha == 0 and self.texts[#self.texts].finDisplay then
			for i,v in pairs(self.texts) do
				v:fade()
			end
			self.texts = nil
			self.state = 'idle'
			self.bubble.canInteract = true
		end
	else
		if self.waitTime <= 0 then
			self.dMoveY = self.dMoveY + math.abs(self.moveY) * dt
			self.y = self.y + self.moveY * dt
			if math.random() < 0.01 then
				self.waitTime = math.random(0,3) + math.random()
				if math.random() < .5 then
					self.dMoveY = 27 - self.dMoveY
					self.moveY = -self.moveY
				end
			end
		else
			self.waitTime = self.waitTime - dt
		end
		if self.dMoveY > 27 then
			self.dMoveY = 0
			self.moveY = -self.moveY
			self.waitTime = math.random(0,3) + math.random()
		end
	end
end
function Mom:onCollision(other,data)end
function Mom:draw()
	local image = self.spriteSheet.image
	local quad = self.sprite:getFrame()
	love.graphics.setColor(255,255,255,255 * self.scene.alpha)
	love.graphics.draw(image,quad,math.ceil(self.x),math.ceil(self.y),0,1,1,
		self.spriteSheet.image:getWidth()/2,self.spriteSheet.image:getHeight()/2)
end

class "Stairs" : extends(Sprite){}
function Stairs:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new('graphics/stairs.png')
		self.spriteSheet:addAnim('',0,1,1,38,38)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Stairs:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet:remove()
		self.spriteSheet = nil
		-------------------------------
		self.loaded = false
	end
end
function Stairs:init(x,y,otherScene)
	self.x = x
	self.y = y
	self.otherScene = otherScene
	
	self.entryWay1 = PlayerBubble:new(self,'small',true)
	self.entryWay1.interact = Stairs.interactEnter1
	self.entryWay1.xOffset = -13
	self.entryWay1.yOffset = 16
	self.entryWay1:updateEndFrame()
	self.entryWay1.updateEndFrame=tlz.NILFUNCTION
	
	self.exitWay1 = PlayerBubble:new(self,'small',true,false)
	self.exitWay1.interactionRadius = 1
	self.exitWay1.interact = Stairs.interactExit1
	self.exitWay1:setDisplay(false)
	self.exitWay1.xOffset = -13+18
	self.exitWay1.yOffset = 16+1
	self.exitWay1:updateEndFrame()
	self.exitWay1.updateEndFrame=tlz.NILFUNCTION
	
	self.entryWay2 = PlayerBubble:new(self,'small',true)
	self.entryWay2.interact = Stairs.interactEnter2
	self.entryWay2.xOffset = 49 - otherScene.x
	self.entryWay2.yOffset = -8 - otherScene.y
	self.entryWay2:updateEndFrame()
	self.entryWay2.updateEndFrame=tlz.NILFUNCTION
	
	self.exitWay2 = PlayerBubble:new(self,'small',true)
	self.exitWay2.interact = Stairs.interactExit2
	self.exitWay2.interactionRadius = 1
	self.exitWay2:setDisplay(false)
	self.exitWay2.xOffset = 49-18+1 - otherScene.x
	self.exitWay2.yOffset = -8+1 - otherScene.y
	self.exitWay2:updateEndFrame()
	self.exitWay2.updateEndFrame=tlz.NILFUNCTION
	
	self.updateEndFrame = tlz.NILFUNCTION
	self.otherScene.drawable = false
end
function Stairs:reinit()
	self.otherScene.drawable = false
end
function Stairs:init_collider()
	self.collider:add(self.entryWay1,self.scene)
	self.collider:add(self.exitWay1,self.scene)
	
	self.collider:add(self.entryWay2,self.otherScene)
	self.collider:add(self.exitWay2,self.otherScene)
	
	self.collider:moveSceneTo(self.otherScene,nil,self.otherScene.y - self.otherScene.height)
end
function Stairs:updateEndFrame(dt)
	--print(string.format("%.20e",self.entryWay1.y),self.entryWay1.y == self.y + self.entryWay1.yOffset,self.y + self.entryWay1.yOffset,self.entryWay1.scene.y,self.scene.y)
	local player = self.collider.uniqueID.Player
	--print(self.exitWay1.x,player.x,self.exitWay1.y,player.y)
	local blackYstart = 140 + self.entryWay1.scene.worldY
	local blackYend = 188 + self.entryWay1.scene.worldY
	
	local scale = tlz.scale(blackYstart,self.entryWay1.scene.y,blackYend)
	self.entryWay1.scene.bgAlpha = scale
	scale = tlz.scale(0,player.x - self.entryWay1.x,18)
	self.entryWay1.scene.timeScale = scale
	scale = scale * .8 + tlz.scale(0,self.entryWay1.scene.y,blackYstart) * .2
	self.entryWay1.scene.alpha = scale
	scale = 1 - tlz.scale(18,player.x - self.entryWay1.x,18+12)
	self.collider:moveSceneTo(self.entryWay1.scene,nil,scale * (self.entryWay1.scene.height + self.entryWay2.scene.worldY) + self.entryWay1.scene.worldY,0.7)
	
	blackYstart = self.entryWay1.scene.height - blackYstart - self.entryWay2.scene.height
	blackYend = self.entryWay1.scene.height - blackYend - self.entryWay2.scene.height
	
	scale = 1 - tlz.scale(blackYend,self.entryWay2.scene.y,blackYstart)
	self.entryWay2.scene.bgAlpha = scale
	scale = tlz.scale(0,self.entryWay2.x - player.x,17)
	self.entryWay2.scene.timeScale = scale
	scale = scale * .8 + (1 - tlz.scale(blackYstart,self.entryWay2.scene.y,0)) * .2
	self.entryWay2.scene.alpha = scale
	scale = tlz.scale(17,self.entryWay2.x - player.x,17+12)
	self.collider:moveSceneTo(self.entryWay2.scene,nil,scale * (self.entryWay2.scene.height + self.entryWay2.scene.worldY) - self.entryWay2.scene.height,0.7)
	
	scale = 1 - tlz.scale(self.exitWay1.x,player.x,self.exitWay2.x)
	local camX = (self.entryWay2.scene.worldX - self.entryWay1.scene.worldX) * scale + self.entryWay1.scene.worldX
	scale = tlz.scale(self.exitWay2.y+1,player.y,self.exitWay1.y)
	local camY = (self.entryWay2.scene.worldY - self.entryWay1.scene.worldY) * scale + self.entryWay1.scene.worldY
	self.collider:moveCameraTo(camX,camY,1)
end
function Stairs:interactEnter1()
	self:enter()
end
function Stairs:interactEnter2()
	self:enter(true)
end
function Stairs:interactExit1()
	self:exit()
end
function Stairs:interactExit2()
	self:exit(true)
end
function Stairs:draw(x,y)
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha)
	love.graphics.draw(self.spriteSheet.image,self:getFrame(),math.ceil(self.x),math.ceil(self.y),0,1,1,0,0)
end
function Stairs:updateStairs(dt)
	local player = self.collider.uniqueID.Player
	local overlay = player.negativeOverlay

	local oldY = player.y
	local oldX = player.x
	
	player:updateMovement(dt)
	if self.section % 2 == 1 then
		local deltaX = -(player.x - oldX) / 2
		player.x = oldX
		
		player.y = player.y + deltaX
		self.sectionD = self.sectionD + (player.y - oldY)
		if self.sectionD < -12 then
			player.y = player.y + (-12 - self.sectionD)
			self.sectionD = 0
			self.section = self.section + 1
		elseif self.sectionD > 0 then
			player.y = player.y - self.sectionD
			if self.section == 1 then
				self.sectionD = 0
			else
				self.sectionD = 12
				self.section = self.section - 1
			end
		end
		local finalDelta = player.y - oldY
	elseif self.section % 2 == 0 then
		local deltaY = -(player.y - oldY) / 2
		player.y = oldY
		
		player.x = player.x + deltaY
		self.sectionD = self.sectionD + (player.x - oldX)
		
		if self.section ~= 4 and self.sectionD > 12 then
			player.x = player.x - (self.sectionD - 12)
			self.sectionD = 12
			self.sectionD = 0
			self.section = self.section + 1
		elseif self.section == 4 and self.sectionD > 15 then
			player.x = player.x - (self.sectionD - 15)
			self.sectionD = 15
			if self.section == 4 then
				self.sectionD = 15
			else
				self.sectionD = 0
				self.section = self.section + 1
			end
		elseif self.sectionD < 0 then
			player.x = player.x - self.sectionD
			self.sectionD = -12
			self.section = self.section - 1
		end
		local finalDelta = player.x - oldX
	end
	--[[if self.section ~= 4 then
		self.collider:moveCameraTo((self.section - 1) / 4 * (self.entryWay2.scene.worldX-18*2) + math.abs(self.sectionD) / 12 / 4 * (self.entryWay2.scene.worldX-18*2)+18 + self.entryWay1.scene.worldX,
								(self.section - 1) / 4 * (self.entryWay2.scene.worldY-0) + math.abs(self.sectionD) / 12 / 4 * (self.entryWay2.scene.worldY-0)+0 + self.entryWay1.scene.worldY,1)
	else
		self.collider:moveCameraTo((self.section - 1) / 4 * (self.entryWay2.scene.worldX-18*2) + math.abs(self.sectionD) / 15 / 4 * (self.entryWay2.scene.worldX-18*2)+18 + self.entryWay1.scene.worldX,
								(self.section - 1) / 4 * (self.entryWay2.scene.worldY-0) + math.abs(self.sectionD) / 12 / 4 * (self.entryWay2.scene.worldY-0)+0 + self.entryWay1.scene.worldY,1)
	end]]--
end
function Stairs:updateEnterRight(dt)
	local player = self.collider.uniqueID.Player
	local overlay = player.sprite
	if overlay.justFinAnim then
		player:resetVels()
		player.x = 1 + self.entryWay1.x + 1 + 2 + 3 + 4 + 4 + 3 - 1 + 1
		player.hp.draw = tlz.NILFUNCTION
		player.canInteract = true
		
		self.update = Stairs.updateStairs
		
		self.entryWay2.scene.drawable = true
		self.collider:moveCameraTo(18,nil,0.3)
	elseif overlay.justFinFrame then
		if overlay.frame == 1 then	
			player.x = 1 + self.entryWay1.x + 1
		elseif overlay.frame == 2 then
			player.x = 1 + self.entryWay1.x + 1 + 2
		elseif overlay.frame == 3 then
			player.x = 1 + self.entryWay1.x + 1 + 2 + 3
		elseif overlay.frame == 4 then
			player.x = 1 + self.entryWay1.x + 1 + 2 + 3 + 4
		elseif overlay.frame == 5 then
			player.x = 1 + self.entryWay1.x + 1 + 2 + 3 + 4 + 4
		elseif overlay.frame == 6 then
			player.x = 1 + self.entryWay1.x + 1 + 2 + 3 + 4 + 4 + 3
		else
			player.x = 1 + self.entryWay1.x + 1 + 2 + 3 + 4 + 4 + 3 - 1
		end
	end
end
function Stairs:updateEnterLeft(dt)
	local player = self.collider.uniqueID.Player
	local overlay = player.sprite
	if overlay.justFinAnim then
		player:resetVels()
		player.x = self.entryWay2.x - 1 - 2 - 3 - 4 - 4 - 3 + 1 - 1
		player.hp.draw = tlz.NILFUNCTION
		player.canInteract = true
		
		self.update = Stairs.updateStairs
		
		self.entryWay1.scene.drawable = true
		self.collider:moveCameraTo(self.entryWay2.scene.worldX-18,nil,0.3)
	elseif overlay.justFinFrame then
		if overlay.frame == 1 then	
			player.x = self.entryWay2.x - 1
		elseif overlay.frame == 2 then
			player.x = self.entryWay2.x - 1 - 2
		elseif overlay.frame == 3 then
			player.x = self.entryWay2.x - 1 - 2 - 3
		elseif overlay.frame == 4 then
			player.x = self.entryWay2.x - 1 - 2 - 3 - 4
		elseif overlay.frame == 5 then
			player.x = self.entryWay2.x - 1 - 2 - 3 - 4 - 4
		elseif overlay.frame == 6 then
			player.x = self.entryWay2.x - 1 - 2 - 3 - 4 - 4 - 3
		else
			player.x = self.entryWay2.x - 1 - 2 - 3 - 4 - 4 - 3 + 1
		end
	end
end
function Stairs:updateExitRight(dt)
	local player = self.collider.uniqueID.Player
	local overlay = player.sprite
	if overlay.justFinAnim then
		player.shove.vX = math.cos(tlz.RADLEFT)
		player.shove.vY = 0
		player.shove.vL = 60

		player.hp.draw = PlayerHP.draw
		player.update = Player.update
		player.canInteract = true
		
		player.sword.rotation.a = tlz.RADLEFT
		player.sword:setState('sheath')
		
		player.sprite:setState('')
		
		self.collider:makeCollidable(player,Wall)
		self.collider:makeCollidable(player,CircleWall)
		
		player:moveToScene(self.entryWay1.scene)
		self.collider:moveToScene(self,self.entryWay1.scene)
	
		self.update = Stairs.update
		self.updateEndFrame = tlz.NILFUNCTION
		
		self.entryWay2.scene.drawable = false

		self.collider:moveCameraTo(self.entryWay1.scene.worldX,nil,0.3+self.collider.camera.xTime)
		self.collider:repositionWorld(self.entryWay1.scene)
	elseif overlay.justFinFrame then
		if overlay.frame == 1 then	
			player.x = self.exitWay1.x - 1
		elseif overlay.frame == 2 then
			player.x = self.exitWay1.x - 1 - 2
		elseif overlay.frame == 3 then
			player.x = self.exitWay1.x - 1 - 2 - 3
		elseif overlay.frame == 4 then
			player.x = self.exitWay1.x - 1 - 2 - 3 - 4
		elseif overlay.frame == 5 then
			player.x = self.exitWay1.x - 1 - 2 - 3 - 4 - 4
		elseif overlay.frame == 6 then
			player.x = self.exitWay1.x - 1 - 2 - 3 - 4 - 4 - 3
		end
	end
end
function Stairs:updateExitLeft(dt)
	local player = self.collider.uniqueID.Player
	local overlay = player.sprite
	if overlay.justFinAnim then
		player.shove.vX = math.cos(tlz.RADRIGHT)
		player.shove.vY = 0
		player.shove.vL = 60

		player.hp.draw = PlayerHP.draw
		player.update = Player.update
		player.canInteract = true
		
		player.sword.rotation.a = tlz.RADRIGHT
		player.sword:setState('sheath')
		
		player.sprite:setState('')
		
		self.collider:makeCollidable(player,Wall)
		self.collider:makeCollidable(player,CircleWall)
		
		player:moveToScene(self.entryWay2.scene)
		self.collider:moveToScene(self,self.entryWay2.scene)
		
		self.update = tlz.NILFUNCTION
		self.updateEndFrame = tlz.NILFUNCTION
		self.entryWay1.scene.drawable = false

		self.collider:moveCameraTo(self.entryWay2.scene.worldX,nil,0.3+self.collider.camera.xTime)
		self.collider:repositionWorld(self.entryWay2.scene)
	elseif overlay.justFinFrame then
		if overlay.frame == 1 then	
			player.x = self.exitWay2.x + 1
		elseif overlay.frame == 2 then
			player.x = self.exitWay2.x + 1 + 2
		elseif overlay.frame == 3 then
			player.x = self.exitWay2.x + 1 + 2 + 3
		elseif overlay.frame == 4 then
			player.x = self.exitWay2.x + 1 + 2 + 3 + 4
		elseif overlay.frame == 5 then
			player.x = self.exitWay2.x + 1 + 2 + 3 + 4 + 4
		elseif overlay.frame == 6 then
			player.x = self.exitWay2.x + 1 + 2 + 3 + 4 + 4 + 3
		end
	end
end
function Stairs:enter(two)
	local player = self.collider.uniqueID.Player
	
	player.update = tlz.NILFUNCTION
	player.sword:setState('hidden')
	player.canInteract = false
	player:resetVels()
	self.collider:makeUncollidable(player,Wall)
	self.collider:makeUncollidable(player,CircleWall)
	
	player:moveToScene(scenes.NILSCENE)
	self.collider:moveToScene(self,scenes.NILSCENE)
	self.updateEndFrame = Stairs.updateEndFrame
	
	if two then
		player.x = self.entryWay2.x
		player.y = self.entryWay2.y + 1
		player.sprite:setState('enterLeft')
		
		self.update = Stairs.updateEnterLeft
		self.sectionD = 15
		self.section = 4
	else
		player.x = self.entryWay1.x + 1
		player.y = self.entryWay1.y + 1
		player.sprite:setState('enterRight')
		
		self.update = Stairs.updateEnterRight
		self.sectionD = 0
		self.section = 1
	end
end
function Stairs:exit(two)
	local player = self.collider.uniqueID.Player
	player.update = tlz.NILFUNCTION
	player.hp.draw = PlayerHP.draw
	player.canInteract = false
	player:resetVels()
	
	if two then
		player.x = self.exitWay2.x
		player.y = self.exitWay2.y
		player.sprite:setState('exitLeft')
		
		self.update = Stairs.updateExitLeft
	else
		player.x = self.exitWay1.x
		player.y = self.exitWay1.y
		player.sprite:setState('exitRight')
		
		self.update = Stairs.updateExitRight
	end
end

class "Door" : extends(Entity){}
function Door:load()
	if not self.loaded then
		---------Load in Here--------
		self.doorOverlay = love.graphics.newImage('graphics/door.png')
		self.spriteSheet = SpriteSheet:new('graphics/doorEntry.png')
		self.spriteSheet:addAnim('',0,1,1,34,46)
		self.spriteSheet:addAnim('opened',0,1,1,34,46,8,0)
		self.spriteSheet:addAnim('open',12,9,1,34,46)
		self.spriteSheet:makeOneShot('open')
		self.spriteSheet:addAnim('close',12,9,1,34,46,0,1)
		self.spriteSheet:makeOneShot('close')
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Door:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.doorOverlay = nil
		self.spriteSheet:remove()
		self.spriteSheet = nil
		-------------------------------
		self.loaded = false
	end
end
function Door:init(x,y,scene,brother)
	self.x = x - 1
	self.y = y
	self.otherScene = scene
	self.doorOverlayY = 0
	
	self.radius = 0
	self.entryWay = PlayerBubble:new(self,'small')
	self.entryWay.interact = Door.interact
	self.entryWay.xOffset = 17
	self.entryWay.yOffset = 53
	self.entryWay:updateEndFrame()
	self.entryWay.updateEndFrame=tlz.NILFUNCTION
		
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite.draw = Door.drawSprite
	self.sprite.parent = self
	self.alpha = 1
	
	self.transitionTime = 0
	self.transportSpace = Wall:new(x-8,y+37,8,56,tlz.RADRIGHT)
	self.transportSpaceY = 37
	
	self.wall1 = Wall:new(x - 8,y + 32,8,40,tlz.RADUP)
	self.wall2 = Wall:new(x + 40,y + 32,8,40,tlz.RADUP)
	
	self.transferedMoveScale = 1
	self.moveScale = 1
	
	self.playerTransferX = 216
	self.playerTransferY = 88
	
	if brother ~= nil then
		self.brother = brother
		brother.brother = self
	end
end
function Door:reinit()
	self.sprite.spriteSheet = self.spriteSheet
	self.doorOverlayY = 0
	self.transportSpace.y = self.y + self.transportSpaceY
	self.alpha = 1
	self.transitionTime = 0
	self.entryWay.canInteract = true
	
	self.transportSpace.solid = true
	self.sprite:setState('')
	self.updateEndFrame = tlz.NILFUNCTION
	self.draw = Door.draw
	self.transfered = false
	self.transferedMoveScale = 1
	self.moveScale = 1
end
function Door:draw()
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha * self.alpha)
	love.graphics.draw(self.doorOverlay,math.ceil(self.x+1),math.ceil(self.y+self.doorOverlayY),0,1,1,0,0)
end
function Door:drawSprite()
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha)
	love.graphics.draw(self.spriteSheet.image,self:getFrame(),math.ceil(self.parent.x),math.ceil(self.parent.y),0,1,1,0,0)
end
function Door:init_collider()
	self.collider:add(self.entryWay,self.scene)
	self.collider:addNonCollidable(self.sprite,self.scene,self.layer-1)
	
	self.collider:add(self.wall1,self.scene)
	self.collider:add(self.wall2,self.scene)
	
	self.collider:add(self.transportSpace,self.scene)
end
function Door:updateEndFrameTransition(dt)	
	self.transitionTime = self.transitionTime + dt
	self.alpha = tlz.scale(0.8,self.transitionTime,1.5)

	self.doorOverlayY = -self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
	if self.transitionTime > 1.5 then self.transitionTime = 1.5 end
	
	local player = self.collider.uniqueID.Player
	local scale = math.min(tlz.scale(0,self.whiteOutTime,0.6),0.6)
	
	self.whiteOutTime = self.whiteOutTime + dt
	
	scale = tlz.scale(0,self.whiteOutTime,0.6)
	
	self.scene.fgAlpha = scale
	self.scene.bgAlpha = scale
	self.scene.alpha = scale
	scale = 1 - scale
	love.graphics.setBackgroundColor((tlz.WHITE.R-tlz.BLACK.R)*scale+tlz.BLACK.R,
									(tlz.WHITE.G-tlz.BLACK.G)*scale+tlz.BLACK.G,
									(tlz.WHITE.B-tlz.BLACK.B)*scale+tlz.BLACK.B)
	if self.whiteOutTime >= 1 then
		self.whiteOutTime = 1
		player:moveToScene(self.otherScene)

		player.scene.fgAlpha = 0
		player.scene.bgAlpha = 0
		player.scene.alpha = 0
		player.scene.drawable = true
		player.scene.timeScale = 1
		
		self.collider:moveCameraTo(self.otherScene.worldX-math.ceil(player.x - self.collider.camera.x)+ self.brother.playerTransferX,
									self.otherScene.worldY-math.ceil(player.y - self.collider.camera.y)+ self.brother.playerTransferY,0)
		player.x = self.otherScene.worldX + self.brother.playerTransferX
		player.y = self.otherScene.worldY + self.brother.playerTransferY
		
		self.brother:transfer(self.whiteOutTime)
		tlz.collider:closeScene(self.scene)
	end
end
function Door:updateEndFrameOpen(dt)
	if self.entryWay.alpha ~= 0 and not self.closingDoor then
		self.transitionTime = self.transitionTime + dt
		
		if self.transitionTime >= 1 / 12 * 9 then
			self.transportSpace.solid = false
		end
		
		self.alpha = tlz.scale(0.8,self.transitionTime,1.5)

		self.doorOverlayY = -self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
		self.transportSpace.y = self.doorOverlayY + self.y + self.transportSpaceY
		if self.transitionTime > 1.5 then self.transitionTime = 1.5 end
		
		local player = self.collider.uniqueID.Player
		local scale = tlz.scale(0,self.entryWay.y - 1 - player.y,3) * 0.7 + tlz.scale(3,self.entryWay.y - 1 - player.y,24) * 0.3
		self.moveScale = math.min(scale,0.6) + 0.4
		player.moveScale = math.min(self.moveScale,self.transferedMoveScale)
	
		if scale < 1 then
			self.hideSword = true
			player.sword:setState('hidden')
			if scale == 0 then
				self.updateEndFrame = Door.updateEndFrameTransition
				self.whiteOutTime = 0
				if self.otherScene.closed then
					tlz.collider:openScene(self.otherScene)
				else
					tlz.collider:addScene(self.otherScene,nil,'up',0,0,self.scene)
					self.otherScene:spawn()
				end
				self.otherScene.drawable = false
				self.otherScene.timeScale = 0
			end
		else
			if self.hideSword then
				player.sword:setState('sheath')
				self.hideSword = false
			end
		end
	else
		self.closingDoor = true
		self.entryWay.canInteract = true
		if self.transitionTime <= 1 / 12 * 9 then
			self.sprite:setState('close')
			self.transportSpace.solid = true
		end
		self.transitionTime = self.transitionTime - dt
		
		self.alpha = tlz.scale(0.8,self.transitionTime,1.5)

		self.doorOverlayY = -self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
		self.transportSpace.y = self.doorOverlayY + self.y + self.transportSpaceY
		if self.transitionTime < 0 then
			self.transitionTime = 0
			if not self.transfered then self.updateEndFrame = tlz.NILFUNCTION end
		end
	end
	
	if self.transfered then
		self.collider:moveCameraTo(self.scene.worldX,self.scene.worldY,1)
		local player = self.collider.uniqueID.Player
		local scale = tlz.scale(-2,self.whiteOutTime,0)
		self.transferedMoveScale = math.min(scale,0.6) + 0.4
		player.moveScale = math.min(self.moveScale,self.transferedMoveScale)
	
		self.whiteOutTime = self.whiteOutTime - dt
	
		scale = tlz.scale(0,self.whiteOutTime,0.6)
		player.scene.fgAlpha = scale
		player.scene.bgAlpha = scale
		player.scene.alpha = scale
	
		if self.whiteOutTime <= -2 then
			self.transfered = false
		elseif self.whiteOutTime <= -0.6 then
			if self.hideSword then
				player.sword:setState('sheath')
				self.hideSword = false
				love.graphics.setBackgroundColor(tlz.BLACK.R,tlz.BLACK.G,tlz.BLACK.B)
			end
		end
	end
end
function Door:interact()
	self.updateEndFrame = Door.updateEndFrameOpen
	self.sprite:setState('open')
	self.entryWay.canInteract = false
	self.closingDoor = false
end
function Door:transfer(time)
	self.hideSword = true
	self.transfered = true
	self.whiteOutTime = time
	self.closingDoor = true
	self.sprite:setState('opened')
	self.transitionTime = 1.5
	self.updateEndFrame = Door.updateEndFrameOpen
	self.collider:repositionWorld(self.scene)
end