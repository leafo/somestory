class "PlayerBubbleDisplay" : extends(Sprite){}
function PlayerBubbleDisplay:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheets = {
			large = SpriteSheet:new("graphics/personalBubbleLarge.png"),
			small = SpriteSheet:new("graphics/personalBubbleSmall.png")}
		self.spriteSheets.large:addAnim('',0,1,1,80,80)
		self.spriteSheets.small:addAnim('',0,1,1,16,16)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function PlayerBubbleDisplay:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		for i,v in pairs(self.spriteSheets) do
			v:remove()
			self.spriteSheets[i] = nil
		end
		self.spriteSheets = nil
		-------------------------------
		self.loaded = false
	end
end
function PlayerBubbleDisplay:init(size,parent)
	if size == 'large' then
		self.spriteSheet = self.spriteSheets.large
	else
		self.spriteSheet = self.spriteSheets.small
	end
	self.size = size
	self.parent = parent
end
function PlayerBubbleDisplay:reinit()
	if self.size == 'large' then
		self.spriteSheet = self.spriteSheets.large
	else
		self.spriteSheet = self.spriteSheets.small
	end
end
function PlayerBubbleDisplay:draw()
	if self.collider.uniqueID.Player.scene ~= scenes.NILSCENE then
		love.graphics.setColor(255,255,255,255 * self.parent.alpha * self.parent.scene.alpha)
		love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.x),math.ceil(self.y),0,1,1,
			self.spriteSheet.image:getWidth()/2,self.spriteSheet.image:getHeight()/2)
	end
end
function PlayerBubbleDisplay:close()
	self.collider:close(self)
end


class "PlayerBubble" : extends(Circle){
	radius = 90,
	innerRadius = 30.5,
	interactionRadius = 3,
	size = 'large',
	xOffset = 0,
	yOffset = 0,
	alpha = 0,
	canInteract = true
}
function PlayerBubble:init(parent,size,centers)
	self.parent = parent
	self.size = size or self.size
	self.centers = centers
	
	self.display = PlayerBubbleDisplay:new(size,self)
	
	if self.size == 'large' then
		self.innerRadius = 30.5
	elseif self.size == 'small' then
		self.innerRadius = 8
	end
	
	self.interact = self.parent.interact
	
	self.x = parent.x
	self.y = parent.y
end
function PlayerBubble:setDisplay(display)
	local display = display == nil and true or display
	if display then
		self.display.draw = PlayerBubbleDisplay.draw
	else
		self.display.draw = tlz.NILFUNCTION
	end
end
function PlayerBubble:init_collider()
	self.collider:addNonCollidable(self.display,self.scene,-6)
end
function PlayerBubble:updateStartFrame(dt)
	self.alpha = 0
end
function PlayerBubble:updateEndFrame(dt)
	self.x = self.parent.x + self.xOffset
	self.y = self.parent.y + self.yOffset
	self.display.x = self.x
	self.display.y = self.y
end
function PlayerBubble:onCollision(other, data)
	local xD = self.x - other.x
	local yD = self.y - other.y
	local distance = math.sqrt(xD * xD + yD * yD)
	local distance2 = math.max(self.innerRadius,distance - other.radius)
	self.alpha = 1 - (distance2-self.innerRadius)/(self.radius-self.innerRadius)
	if self.alpha == 1 then
		other.sheathSword = true
		if self.centers then
			if distance <= self.interactionRadius and (tlz.kP(tlz.A) or tlz.kP(tlz.B))
				and other.canInteract and self.canInteract then
				self.interact(self.parent)
			end
		else
			if distance - other.radius <= self.parent.radius + self.interactionRadius and (tlz.kP(tlz.A) or tlz.kP(tlz.B))
				and other.canInteract and self.canInteract then
				self.interact(self.parent)
			end
		end
	end
end
function PlayerBubble:draw_debug()
	love.graphics.setColor(255,0,0,255 * 0.5)
	love.graphics.circle('fill', self.x, self.y, 3)
	love.graphics.setColor(255,255,255)
end

class "Sword" : extends(CircleLine) {
	radius = 1.5,
	length = 16,
	velocity = 0,
	state = 'idle',
	oldState = 'idle',
	resetMovement = false,
	solid = true
}
function Sword:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheets = {
			spin = SpriteSheet:new("graphics/sword.png"),
			sheath = SpriteSheet:new("graphics/swordSheath.png")
		}
		self.spriteSheets.spin:addAnim('',0,6,6,47,47)
		self.spriteSheets.sheath:addAnim('sheath',24,7,1,47,47)
		self.spriteSheets.sheath:makeOneShot('sheath')
		self.spriteSheets.sheath:addAnim('unsheath',24,6,1,47,47,0,1)
		self.spriteSheets.sheath:makeOneShot('unsheath')
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Sword:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		for i,v in pairs(self.spriteSheets) do
			v:remove()
			self.spriteSheets[i] = nil
		end
		self.spriteSheets = nil
		-------------------------------
		self.loaded = false
	end
end
function Sword:init(player)
	self:super('init')
	self.player = player
	
	self.sprite = Sprite:new(self.spriteSheets.spin)
	self.sprite:setState('')
	
	self.swing = {tik = 0, tok = 0, d = 0, dir = 0}
	self.sheath = {d = 0, maxD = 0}
	self.timeInState = 0
end
function Sword:reinit()
	self.sprite.spriteSheet = self.spriteSheets.spin
end
function Sword:init_collider()
	self.collider:makeCollidable(self,Wall)
	self.collider:makeCollidable(self,CircleWall)
	self.collider:makeCollidable(self,SwordCircleWall)
	self.collider:makeCollidable(self,SwordWall)
	
	self.collider:makeThisMovableByThat(self,Wall)
	self.collider:makeThisMovableByThat(self,CircleWall)
	self.collider:makeThisMovableByThat(self,SwordCircleWall)
	self.collider:makeThisMovableByThat(self,SwordWall)
	
	self.collider:addNonCollidable(self.sprite,self.scene,9)
end
function Sword:setState(state, ...)
	if self.oldState == 'hidden' then
		self.draw = Sword.draw
	end
	self.oldState = self.state
	self.state = state
	if state == 'swing' then
		self.alreadyHit = false
		self.swing.d = 0
		self.swing.startRotation = self.rotation.a
		if self.timeInState < 2 then
			if arg[1] > 0 then -- clockwise
				self.swing.tik = self.swing.tik + 1
				if self.swing.dir > 0 then
					self.swing.tok = 0
				end
			else
				self.swing.tok = self.swing.tok + 1
				if self.swing.dir < 0 then
					self.swing.tik = 0
				end
			end
		else
			self.swing.tik = 0
			self.swing.tok = 0
		end
		self.swing.dir = arg[1]
		self.rotation.velocity = math.rad(360) / 0.5 * arg[1]
		--self.justSetState = true
	elseif state == 'idle' then
		self.resetMovement = false
	elseif state == 'sheath' then
		local closest90 = math.floor(((self.rotation.a+tlz.RAD45) % tlz.RAD360) / tlz.RAD90)*tlz.RAD90
		self:setRotation(closest90)
		self.noCollisions = true
		self.rotation.velocity = 0
		self.sprite.spriteSheet = Sword.spriteSheets.sheath
		self.sprite:setState('sheath')
	elseif state == 'unsheath' then
		self.noCollisions = true
		self.rotation.velocity = 0
		self.sprite.spriteSheet = Sword.spriteSheets.sheath
		self.sprite:setState('unsheath')
	elseif state == 'hidden' then
		self.noCollisions = true
		self.draw = tlz.NILFUNCTION
	end
	self.timeInState = 0
end
function Sword:sheathSword(sheath)
	local sheath = sheath == nil and true or sheath
	if sheath and self.state ~= 'sheath' and self.state ~= 'hidden' then
		self:setState('sheath')
	elseif not sheath and self.state == 'sheath' then
		self:setState('unsheath')
	end
end
function Sword:draw()
	local image = self.sprite.spriteSheet.image
	if self.sprite.spriteSheet == Sword.spriteSheets.spin then
		self.sprite.frame = math.floor(math.deg(self.rotation.a % tlz.RAD90)/90 * 36)
	end
	local quad = self.sprite:getFrame()
	local rotationDir = math.floor(self.rotation.a / tlz.RAD90)
	local rotationOffsetX = (rotationDir == 3 or rotationDir == 2) and -1 or 0
	local rotationOffsetY = (rotationDir == 0 or rotationDir == 3) and -1 or 0
	love.graphics.drawq(image,quad,math.ceil(self.player.x)+rotationOffsetX,math.ceil(self.player.y)+rotationOffsetY,
						rotationDir*tlz.RAD90,1,1,24,24)
end
function Sword:update(dt)
	self.timeInState = self.timeInState + dt
	local addAngle = (self.rotation.velocity * dt)
	if self.state == 'swing' then
		self.swing.d = self.swing.d + math.abs(addAngle)
		if self.swing.d >= math.rad(360) then
			addAngle = self.swing.d - math.rad(360)
			self.swing.d = math.rad(360)
			self.swing.tik = 0
			self.swing.tok = 0
			self:setState('idle')
		end
	elseif self.state == 'idle' then 
		local vel = self.rotation.velocity - self.rotation.velocity / 0.25 * dt
		vel = self.rotation.velocity < 0 and math.min(vel,0) or math.max(0,vel)
		self.rotation.velocity = vel
	elseif self.state == 'unsheath' and self.sprite.justFinAnim then
		self:setState('idle')
		self.sprite.spriteSheet = Sword.spriteSheets.spin
		self.sprite:setState('')
		self.noCollisions = false
	end
	self:super('update')
	self:setRotation(self.rotation.a + addAngle)
	
	self.x = self.player.x + self.rotation.vX * 4.5
	self.y = self.player.y + self.rotation.vY * 4.5
end
function Sword:updateEndFrame(dt)
	self.x = self.player.x + self.rotation.vX * 4.5
	self.y = self.player.y + self.rotation.vY * 4.5
end
function Sword:onCollision(other,data)
	if other:instanceOf(Circle) then
		if (self.rotation.velocity > 0 and data.otherIsClockwiseAfter)
		or (self.rotation.velocity < 0 and not data.otherIsClockwiseAfter) then
			self.rotation.velocity = - self.rotation.velocity/2
			if self.state == 'swing' or self.oldState == 'swing' and self.timeInState < 0.15 and not self.alreadyHit then
				if self.state ~= 'idle' then self:setState('idle') end
				self.alreadyHit = true
				if other.isHittable then
					if self.swing.d > math.rad(180) then -- heavy
						other:hit(-data.vX,-data.vY,self.rotation.velocity,self.swing.d,2)
					else --light
						other:hit(-data.vX,-data.vY,self.rotation.velocity,self.swing.d,1)
					end
				end
			end
		end
	elseif other:instanceOf(CircleLine) then
		if (self.rotation.velocity > 0 and data.otherIsClockwiseAfter)
		or (self.rotation.velocity < 0 and not data.otherIsClockwiseAfter) then
			self.rotation.velocity = - self.rotation.velocity/2
			if self.state == 'swing' or self.oldState == 'swing' and self.timeInState < 0.15 then
				if self.state ~= 'idle' then self:setState('idle') end
			end
		end
	end
end

class "PlayerHPBlips" : extends(Sprite) {}
function PlayerHPBlips:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new("graphics/healthblips.png")
		self.spriteSheet:addAnim('',0,4,3,22,22)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function PlayerHPBlips:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet = nil
		-------------------------------
		self.loaded = false
	end
end
function PlayerHPBlips:init(parent)
	self.parent = parent
end
function PlayerHPBlips:draw()
	if self.parent.hp > 0 then
		self.frame = self.parent.hp - 1
		love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.parent.parent.x-3),math.ceil(self.parent.parent.y-3),0,1,1,8,8)
	end
end

class "PlayerHP" : extends(Sprite){
	hp = 3,
	maxhp = 3
}
function PlayerHP:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new("graphics/healthblops.png")
		self.spriteSheet:addAnim('',0,4,3,22,22)
		PlayerHPBlips:load()
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function PlayerHP:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet = nil
		PlayerHPBlips:unload()
		-------------------------------
		self.loaded = false
	end
end
function PlayerHP:init(parent,hp)
	self.hp = hp or self.hp
	self.maxhp = self.hp
	
	self.parent = parent
	
	self.blips = PlayerHPBlips:new(self)
end
function PlayerHP:init_collider()
	self.collider:addNonCollidable(self.blips,self.scene,10)
end
function PlayerHP:draw()
	self.frame = self.maxhp - 1
	love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.parent.x - 3),math.ceil(self.parent.y - 3),0,1,1,8,8)
end

class "Player" : extends(Circle) {
	radius = 7.5,
	xVel = 0,
	yVel = 0,
	dir = 0,
	movSpd = 9,
	movAcl = 9 / 0.17,
	moveScale = 1,
	snareTime = 0,
	solid = true,
	canInteract = true,
	hitTime = 0
}
function Player:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheets = {
			base = SpriteSheet:new("graphics/playerNegative.png")
		}
		self.spriteSheets.base:addAnim('',0,1,1,16,16)
		self.spriteSheets.base:addAnim('enterRight',24,4,2,16,16)
		self.spriteSheets.base:makeOneShot('enterRight')
		self.spriteSheets.base:addAnim('exitRight',24,4,2,16,16,0,2)
		self.spriteSheets.base:makeOneShot('exitRight')
		
		self.spriteSheets.base:addAnim('enterLeft',24,4,2,16,16,4,0)
		self.spriteSheets.base:makeOneShot('enterLeft')
		self.spriteSheets.base:addAnim('exitLeft',24,4,2,16,16,4,2)
		self.spriteSheets.base:makeOneShot('exitLeft')
		PlayerHP:load()
		Sword:load()
		PlayerBubbleDisplay:load()
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Player:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheets.base:remove()
		self.spriteSheets.base = nil
		self.spriteSheets = nil
		PlayerHP:unload()
		Sword:unload()
		PlayerBubbleDisplay:unload()
		-------------------------------
		self.loaded = false
	end
end
function Player:init(x,y)
	self:super('init',x,y)
	self.inputVector = {0,0 ,0,0}
	
	self.sprite = Sprite:new(self.spriteSheets.base)
	self.sprite.draw = Player.drawSprite
	self.sprite.parent = self
	
	self.hp = PlayerHP:new(self,3)
	
	self.sword = Sword:new(self)
	self.sword:setState('hidden')
	self.shove = {vX = 0, vY = 0, vL = 0}
end
function Player:reinit()
	self.sprite.spriteSheet = self.spriteSheets.base
end
function Player:init_collider()
	self.collider:add(self.sword,self.scene)
	self.collider:addNonCollidable(self.hp,self.scene,-6)
	self.collider:addNonCollidable(self.sprite,self.scene,9)

	self.collider:makeCollidable(self,Wall)
	self.collider:makeCollidable(self,CircleWall)
	
	self.collider:makeCollidable(self,PlayerBubble)
	
	self.collider:makeThisMovableByThat(self,Wall)
	self.collider:makeThisMovableByThat(self,CircleWall)
end
function Player:updateMovement(dt,canMove)
	local canMove = canMove == nil and true or canMove
	self.inputVector[3] = 0
	self.inputVector[4] = 0

	if tlz.k(tlz.RIGHT) and not tlz.k(tlz.LEFT) and canMove then
		self.inputVector[3] = 1 * self.movAcl * dt
	elseif self.xVel > 0 then
		self.inputVector[1] = math.max(0,self.inputVector[1] - self.movAcl * dt)
	end
	if tlz.k(tlz.LEFT) and not tlz.k(tlz.RIGHT) and canMove then
		self.inputVector[3] = -1 * self.movAcl * dt
	elseif self.xVel < 0 then
		self.inputVector[1] = math.min(self.inputVector[1] + self.movAcl * dt,0)
	end
	
	if tlz.k(tlz.DOWN) and not tlz.k(tlz.UP) and canMove then
		self.inputVector[4] = 1 * self.movAcl * dt
	elseif self.yVel > 0 then
		self.inputVector[2] = math.max(0,self.inputVector[2] - self.movAcl * dt)
	end
	if tlz.k(tlz.UP) and not tlz.k(tlz.DOWN) and canMove then
		self.inputVector[4] = -1 * self.movAcl * dt
	elseif self.yVel < 0 then
		self.inputVector[2] = math.min(self.inputVector[2] + self.movAcl * dt,0)
	end
	
	local movMax = self.movSpd * self.moveScale
	if self.inputVector[3] ~= 0 and self.inputVector[4] ~= 0 then
		self.inputVector[3] = self.inputVector[3] / tlz.SQRT2
		self.inputVector[4] = self.inputVector[4] / tlz.SQRT2
		--movMax = movMax / tlz.SQRT2
		local movMaxDiag = movMax / tlz.SQRT2
		if math.abs(self.inputVector[1]) > movMaxDiag and math.abs(self.inputVector[1]) > math.abs(self.inputVector[2]) then
			self.inputVector[3] = -self.inputVector[3]
		elseif math.abs(self.inputVector[2]) > movMaxDiag and math.abs(self.inputVector[1]) < math.abs(self.inputVector[2]) then
			self.inputVector[4] = -self.inputVector[4]
		else
			movMax = movMaxDiag
		end
	end
	
	if self.sword.state == 'swing' and self.sword.timeInState < 0.3 and not self.sword.resetMovement and
		(self.inputVector[3] * self.xVel <= 0 and self.inputVector[4] * self.yVel <= 0) then
		self.xVel = 0
		self.yVel = 0
		self.inputVector[1] = 0
		self.inputVector[2] = 0
		self.sword.resetMovement = true
	end
	
	self.inputVector[1] = self.inputVector[1] + self.inputVector[3]
	self.inputVector[2] = self.inputVector[2] + self.inputVector[4]
	
	if self.xVel > 0 and self.inputVector[1] > movMax then
		self.inputVector[1] = movMax
	elseif self.xVel < 0 and self.inputVector[1] < -movMax then
		self.inputVector[1] = -movMax
	end
	if self.yVel > 0 and self.inputVector[2] > movMax then
		self.inputVector[2] = movMax
	elseif self.yVel < 0 and self.inputVector[2] < -movMax then
		self.inputVector[2] = -movMax
	end
	
	local xVelChange = self.inputVector[1] * self.movSpd * self.moveScale - self.xVel
	local yVelChange = self.inputVector[2] * self.movSpd * self.moveScale - self.yVel
	
	self.xVel = self.xVel + xVelChange
	self.yVel = self.yVel + yVelChange
	
	if self.inputVector[3] ~= 0 or self.inputVector[4] ~= 0 then
		self.dir = math.atan2(self.yVel,self.xVel)
	end
	
	self.x = self.x + self.xVel * dt
	self.y = self.y + self.yVel * dt
end
function Player:update(dt)
	self.sheathSword = false
	--print(self.scene.x)
	self:updateMovement(dt,self.snareTime == 0)
	self.x = self.x + self.shove.vX * self.shove.vL * dt
	self.y = self.y + self.shove.vY * self.shove.vL * dt
	local vL = self.shove.vL - self.shove.vL / 0.3 * dt
	vL = math.max(0,vL)
	self.shove.vL = vL
	
	if self.sword.timeInState > 0.05 and self.sword.state == 'idle' then
		if tlz.kP(tlz.A) then
			self.sword:setState('swing',-1)
		elseif tlz.kP(tlz.B) then
			self.sword:setState('swing',1)
		end
	end
	self.snareTime = math.max(0,self.snareTime - dt)
	
	if not self.collider.camera.inTransit then
		local scene = self.collider:getClosestScene(self.x+math.cos(self.dir),self.y+math.sin(self.dir))
		if scene ~= self.scene then
			self:moveToScene(scene)
		end
	end
	self.hitTime = math.max(0,self.hitTime - dt)
end
function Player:updateEndFrame(dt)
	self.sprite.x = self.x
	self.sprite.y = self.y
	if self.scene == scenes.NILSCENE then
		tlz.noBugsYet = false
	end
	if self.sheathSword or tlz.noBugsYet then
		self.sword:sheathSword()
	else
		self.sword:sheathSword(false)
	end
end
function Player:onCollision(other,data)end
function Player:drawSprite()
	local scale = tlz.scale(0,self.parent.hitTime,1)  * .3 + .7
	love.graphics.setColor(255,255,255,255*scale)
	love.graphics.drawq(self.spriteSheet.image,self:getFrame(),math.ceil(self.x),math.ceil(self.y),0,1,1,
		8,8)
end
function Player:resetVels()
	self.xVel = 0
	self.yVel = 0
	self.inputVector[1] = 0
	self.inputVector[2] = 0
	self.shove.vL = 0
	self.snareTime = 0 
end
function Player:hit(data,dmg,knockback)
	if self.hitTime == 0 then
		self.hitTime = 3
		self.hp.hp = math.max(0,self.hp.hp - dmg)
		self.snareTime = 0.3
		self.xVel = 0
		self.yVel = 0
		self.inputVector[1] = 0
		self.inputVector[2] = 0
		print('player health: '..self.hp.hp)
		if knockback then
			self.shove.vX = -data.vX
			self.shove.vY = -data.vY
			self.shove.vL = knockback
		end
	end
end
function Player:moveToScene(scene)
	self.collider:moveToScene(self,scene)
	self.collider:moveToScene(self.sprite,scene)
	self.collider:moveToScene(self.hp,scene)
	self.collider:moveToScene(self.hp.blips,scene)
	self.collider:moveToScene(self.sword,scene)
	self.collider:moveToScene(self.sword.sprite,scene)
end

--[[class "PlayerNegativeOverlay" : extends(Entity){}
function PlayerNegativeOverlay:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheets = {
			base = SpriteSheet:new("graphics/playerNegative.png")
		}
		self.spriteSheets.base:addAnim('',0,1,1,16,16,1)
		
		self.spriteSheets.base:addAnim('enterRight',24,4,2,16,16)
		self.spriteSheets.base:makeOneShot('enterRight')
		self.spriteSheets.base:addAnim('exitRight',24,4,2,16,16,0,2)
		self.spriteSheets.base:makeOneShot('exitRight')
		
		self.spriteSheets.base:addAnim('enterLeft',24,4,2,16,16,4,0)
		self.spriteSheets.base:makeOneShot('enterLeft')
		self.spriteSheets.base:addAnim('exitLeft',24,4,2,16,16,4,2)
		self.spriteSheets.base:makeOneShot('exitLeft')
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function PlayerNegativeOverlay:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		for i,v in pairs(self.spriteSheets) do
			v:remove()
			self.spriteSheets[i] = nil
		end
		self.spriteSheets = nil
		-------------------------------
		self.loaded = false
	end
end
function PlayerNegativeOverlay:init(parent)
	self.parent = parent
	self.parent.negativeOverlay = self
	self.sprite = Sprite:new(PlayerNegativeOverlay.spriteSheets.base)
end
function PlayerNegativeOverlay:init_collider()
	self.collider:addNonCollidable(self.sprite,self.scene)
end
function PlayerNegativeOverlay:updateEndFrame(dt)
	self.x = self.parent.x
	self.y = self.parent.y
end
function PlayerNegativeOverlay:draw()
	local image = self.sprite.spriteSheet.image
	local quad = self.sprite:getFrame()
	love.graphics.drawq(image,quad,math.ceil(self.x),math.ceil(self.y),0,1,1,
		math.ceil(self.parent.radius),math.ceil(self.parent.radius))
end
function PlayerNegativeOverlay:remove()
	self.sprite:remove()
	self.collider:remove(self)
end]]--