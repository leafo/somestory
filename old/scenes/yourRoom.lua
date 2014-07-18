scenes.yourRoom = {name = 'yourRoom',width=432,height=240}

function scenes.yourRoom:load()
	self.imageBG = love.graphics.newImage("graphics/yourRoomBG.png")
	self.imageFG = love.graphics.newImage("graphics/yourRoomFG.png")
	
	self.spriteSheet = SpriteSheet:new("graphics/yourRoomBGOverlay.png")
	self.spriteSheet:addAnim('',0,1,1,tlz.SCREEN_WIDTH,tlz.SCREEN_HEIGHT)
	
	SimpleGobber:load()
end
function scenes.yourRoom:unload()
	SimpleGobber:unload()
end
function scenes.yourRoom:spawn()
	--additional scene images
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite.draw = function(self)
		love.graphics.setColor(255,255,255,255 * self.scene.alpha)
		love.graphics.draw(self.spriteSheet.image,self:getFrame(),math.ceil(self.x),math.ceil(self.y))
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(self.scene.imageFG,math.ceil(self.x),math.ceil(self.y))
	end
	self.sprite.reinit = function(self)
		self.spriteSheet = self.scene.spriteSheet
	end
	self.collider:addNonCollidable(self.sprite,self,-5)

	-- test yo --
	--[[local playa = Player:new(160,120)
	self.collider:add(playa,self)
	self.collider:addUniqueID(playa,'Player')]]--
	
	--Borders
	self.collider:add(Wall:new(96,24,8,168,tlz.RADDOWN),self)
	self.collider:add(Wall:new(96,200,8,232,tlz.RADRIGHT),self)
	self.collider:add(Wall:new(336,200,8,168,tlz.RADUP),self)
	self.collider:add(Wall:new(336,24,8,232,tlz.RADLEFT),self)
	
	--walls
	self.collider:add(Wall:new(99,156,4,37,tlz.RADRIGHT),self)
	
	self.collider:addNonCollidable(self.sprite,self,-5)
	for i=1,1 do
		self.collider:add(SimpleGobber:new(225,112,self.collider.uniqueID.Player),self)
	end
end
function scenes.yourRoom:draw()
	love.graphics.setColor(255,255,255,255 * self.bgAlpha)
	love.graphics.draw(self.imageBG,math.ceil(self.x),math.ceil(self.y))
end