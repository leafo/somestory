scenes.outsideHome = {name='outsideHome',width=480,height=480}
function scenes.outsideHome:load()
	self.imageBG = love.graphics.newImage("graphics/outsideHome.png")
	Doormat:load()
	SimpleGobber:load()
	--- sub scenes
	--[[if scenes.testWorld.closed then
		self.collider:openScene(scenes.testWorld)
	else
		tlz.collider:addScene(scenes.testWorld,nil,'up',0,128,self)
	end
	scenes.testWorld.timeScale = 1]]--
	
	for i=1,2 do
		self.collider:add(SimpleGobber:new(240+self.x,self.y+i*3,self.collider.uniqueID.Player),self)
	end
end
function scenes.outsideHome:unload()
	self.imageBG = nil
	--self.collider:closeScene(scenes.testWorld)
end
function scenes.outsideHome:spawn()
	--Circle Wall
	self.collider:add(CircleWall:new(240+self.x,304+self.y,64.5),self)
	
	--objects
	self.entryToHome = Doormat:new(232+self.x,224+self.y,scenes.home,scenes.home.entryToOutsideHome)
	self.collider:addNonCollidable(self.entryToHome,self,-7)
	
	--sub scenes
	--scenes.testWorld:spawn()
end
function scenes.outsideHome:draw()
	love.graphics.setColor(255,255,255,255 * self.bgAlpha)
	love.graphics.draw(self.imageBG,math.ceil(self.x),math.ceil(self.y))
end
------------Room Specific Objects-----------
class "Doormat" : extends(Entity){}
function Doormat:load()
	if not self.loaded then
		---------Load in Here--------
		self.overlay = love.graphics.newImage('graphics/doormat.png')
		self.spriteSheets = {
			square = SpriteSheet:new('graphics/doormatEntry.png'),
			cap = SpriteSheet:new('graphics/doormatEntryCap.png')
		}
		self.spriteSheets.square:addAnim('',0,1,1,16,16)
		self.spriteSheets.square:addAnim('opened',0,1,1,16,16,1,1)
		self.spriteSheets.square:addAnim('open',6,2,2,16,16)
		self.spriteSheets.square:makeOneShot('open')
		self.spriteSheets.square:addAnim('close',6,2,2,16,16,2,0)
		self.spriteSheets.square:makeOneShot('close')
		self.spriteSheets.cap:addAnim('',0,1,1,16,6)
		self.spriteSheets.cap:addAnim('wave',12,1,10,16,6)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Doormat:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.overlay = nil
		for i,v in pairs(self.spriteSheets) do
			v:remove()
			self.spriteSheets[i] = nil
		end
		self.spriteSheets = nil
		-------------------------------
		self.loaded = false
	end
end
function Doormat:init(x,y,scene,brother)
	self.x = x
	self.y = y
	self.otherScene = scene
	self.overlayY = 0
	self.overlayAlpha = 1
	
	self.radius = 0
	self.entryWay = PlayerBubble:new(self,'small')
	self.entryWay.interact = Doormat.interact
	self.entryWay.xOffset = 8
	self.entryWay.yOffset = -8
	self.entryWay:updateEndFrame()
	self.entryWay.updateEndFrame=tlz.NILFUNCTION
		
	self.square = Sprite:new(self.spriteSheets.square)
	self.square.draw = Doormat.drawSprite
	self.square.parent = self
	self.cap = Sprite:new(self.spriteSheets.cap)
	self.cap.draw = Doormat.drawCapSprite
	self.cap.parent = self.square
	
	self.transitionTime = 0
	self.transportSpace = Wall:new(x-2,y+2,2,22,tlz.RADRIGHT)
	self.transportSpaceY = 2
	
	self.wall1 = Wall:new(x - 2,y + 18,2,18,tlz.RADUP)
	self.wall2 = Wall:new(x + 18,y + 18,2,18,tlz.RADUP)
	
	self.transferedMoveScale = 1
	self.moveScale = 1
	
	self.playerTransferX = 240
	self.playerTransferY = 192
	
	if brother ~= nil then
		self.brother = brother
		brother.brother = self
	end
end
function Doormat:reinit()
	self.updateEndFrame = tlz.NILFUNCTION
	self.square.spriteSheet = self.spriteSheets.square
	self.cap.spriteSheet = self.spriteSheets.cap
	self.overlayY = 0
	self.transportSpace.y = self.y + self.transportSpaceY
	self.overlayAlpha = 1
	self.transitionTime = 0
	self.entryWay.canInteract = true
	
	self.transportSpace.solid = true
	self.square:setState('')
	self.cap:setState('')
	self.transfered = false
	self.transferedMoveScale = 1
	self.moveScale = 1
end
function Doormat:draw()
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha * self.overlayAlpha)
	love.graphics.draw(self.overlay,math.ceil(self.x),math.ceil(self.y+self.overlayY))
	--print(self.scene == scenes.outsideHome)
end
function Doormat:drawSprite()
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha)
	love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.parent.x),math.ceil(self.parent.y+1),0,1,1,0,0)
end
function Doormat:drawCapSprite()
	local y = -self.parent.frame
	if self.parent.state == 'close' then y = -(3 - self.parent.frame) end
	love.graphics.setColor(255,255,255,255 * self.scene.fgAlpha)
	love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.parent.parent.x),math.ceil(self.parent.parent.y+y),0,1,1,0,0)
end
function Doormat:init_collider()
	self.collider:add(self.entryWay,self.scene)
	self.collider:addNonCollidable(self.square,self.scene,self.layer-1)
	self.collider:addNonCollidable(self.cap,self.scene,self.layer-1)
	
	self.collider:add(self.wall1,self.scene)
	self.collider:add(self.wall2,self.scene)
	
	self.collider:add(self.transportSpace,self.scene)
end
function Doormat:updateEndFrameTransition(dt)	
	self.transitionTime = self.transitionTime + dt
	self.overlayAlpha = tlz.scale(0.8,self.transitionTime,1.5)

	self.overlayY = self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
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
		print('outsideHome',self.scene.worldX,self.scene.worldY)
		
		player.x = self.otherScene.worldX + self.brother.playerTransferX
		player.y = self.otherScene.worldY + self.brother.playerTransferY
		
		self.brother:transfer(self.whiteOutTime)
	
		tlz.collider:closeScene(self.scene)
	end
end
function Doormat:updateEndFrameOpen(dt)
	if self.entryWay.alpha ~= 0 and not self.closingDoor then
		self.transitionTime = self.transitionTime + dt
		
		if self.transitionTime >= 1 / 12 * 9 then
			self.transportSpace.solid = false
		end
		
		self.overlayAlpha = tlz.scale(0.8,self.transitionTime,1.5)

		self.overlayY = self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
		self.transportSpace.y = self.overlayY + self.y + self.transportSpaceY
		if self.transitionTime > 1.5 then self.transitionTime = 1.5 end
		
		local player = self.collider.uniqueID.Player
		
		if player.x - player.radius > self.wall1.x and player.x + player.radius < self.wall2.x then
			local scale = tlz.scale(0,player.y - self.entryWay.y,3) * 0.7 + tlz.scale(3,player.y - self.entryWay.y,16) * 0.3
			self.moveScale = math.min(scale,0.6) + 0.4
			player.moveScale = math.min(self.moveScale,self.transferedMoveScale)
			
			if scale < 1 then
				self.hideSword = true
				player.sword:setState('hidden')
				if scale == 0 then
					self.updateEndFrame = Doormat.updateEndFrameTransition
					self.whiteOutTime = 0
					tlz.collider:openScene(self.otherScene)
					self.otherScene.drawable = false
					self.otherScene.timeScale = 0
				end
			else
				if self.hideSword then
					player.sword:setState('sheath')
					self.hideSword = false
				end
			end
		end
	else
		self.closingDoor = true
		self.entryWay.canInteract = true
		if self.transitionTime <= 1 / 12 * 9 then
			self.square:setState('close')
			self.transportSpace.solid = true
		end
		self.transitionTime = self.transitionTime - dt
		
		self.overlayAlpha = tlz.scale(0.8,self.transitionTime,1.5)

		self.overlayY = self.transitionTime * (1 - tlz.scale(0,self.transitionTime,3)) * 30
		self.transportSpace.y = self.overlayY + self.y + self.transportSpaceY
		if self.transitionTime < 0 then
			self.cap:setState('')
			self.transitionTime = 0
			if not self.transfered then self.updateEndFrame = tlz.NILFUNCTION end
		end
	end
	
	if self.transfered then		
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
function Doormat:interact()
	self.updateEndFrame = Doormat.updateEndFrameOpen
	self.square:setState('open')
	self.cap:setState('wave')
	self.entryWay.canInteract = false
	self.closingDoor = false
end
function Doormat:transfer(time)
	self.hideSword = true
	self.transfered = true
	self.whiteOutTime = time
	self.closingDoor = true
	self.square:setState('opened')
	self.cap:setState('wave')
	self.transitionTime = 1.5
	self.updateEndFrame = Doormat.updateEndFrameOpen
	self.collider:repositionWorld(self.scene)
	self.collider:lockCamera(self.collider.uniqueID.Player,tlz.BOUNDD,tlz.BOUNDDSOFT)
end