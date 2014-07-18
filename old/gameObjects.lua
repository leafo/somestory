require "sprites"

class "CircleWall" : extends(Circle) {
	solid = true
}
function CircleWall:init(x,y,r)
	Circle.init(self,x,y,r)
end

class "Wall" : extends(CircleLine) {
	solid = true
}
function Wall:init(x,y,r,l,a)
	self:super('init',x,y,r,l,a)
	--self.center = CircleWall:new(x,y,r)
end
function Wall:init_collider()
	--self.collider:add(self.center,self.scene)
end

class "SwordCircleWall" : extends(Circle) {
	solid = true
}
function SwordCircleWall:init(x,y,r)
	self:super('init',x,y,r)
end

class "SwordWall" : extends(CircleLine) {
	solid = true
}
function SwordWall:init(x,y,r,l,a)
	self:super('init',x,y,r,l,a)
	self.center = CircleWall:new(x,y,r)
end
function SwordWall:init_collider()
	self.collider:add(self.center,self.scene)
end

class "Stars" : extends (Circle) {
	radius = 2,
	length = 8,
	rotation = 0,
	velocity = math.rad(360) / 3,
	stars = 5,
}
function Stars:init(parent)
	self:super('init',parent.x,parent.y)
	self.parent = parent
end
function Stars:alt_update(dt)
	self.rotation = self.rotation + self.velocity * dt
	self.x = self.parent.x
	self.y = self.parent.y
end
function Stars:draw()
	love.graphics.setColor(255,255,255)
	local offSet = math.rad(360) / self.stars
	for i = 0,self.stars-1 do
		local vX = math.cos(self.rotation+i*offSet)
		local vY = math.sin(self.rotation+i*offSet)
		love.graphics.circle('fill',self.x + vX * (self.length - self.radius),self.y + vY*(self.length-self.radius), self.radius)
	end
	love.graphics.setColor(255,255,255)
end
function Stars:remove()
	self.collider:remove(self)
end

class "SimpleGobber" : extends(Circle) {
	radius = 3.5,
	moveSpeed = 0,
	moveVX = 0,
	moveVY = 0,
	biteMove = 30,
	shoveVX = 0,
	shoveVY = 0,
	shoveSpeed = 0,
	movable = true,
	isHittable = true,
	hits = 5,
	dir = 0,
	solid = true
}
function SimpleGobber:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new("graphics/bug.png")
		self.spriteSheet:addAnim('chomp',12,3,0,10,10)
		self.spriteSheet:addAnim('hit',0,1,0,10,10,2)
		self.spriteSheet:addAnim('crippleChomp',2,3,0,10,10)
		self.spriteSheet:addAnim('splat',12,3,0,10,10,0,1)
		self.spriteSheet:makeOneShot('splat')
		self.spriteSheet:addAnim('spinCC',12,4,0,10,10,0,2)
		self.spriteSheet:addAnim('spinC',12,4,0,10,10,0,3)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function SimpleGobber:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet:remove()
		-------------------------------
		self.loaded = false
	end
end
function SimpleGobber:init(x,y,player)
	self:super('init',x,y)
	self.player = player
	
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite:setState('chomp')
	self.sprite.frame = math.random(0,2)
	
	self.mode = 'normal'
end
function SimpleGobber:reinit()
	self.sprite.spriteSheet = self.spriteSheet
end
function SimpleGobber:init_collider()
	self.collider:makeCollidable(self,SimpleGobber)
	self.collider:makeCollidable(self,Player)
	self.collider:makeCollidable(self,Sword)
	
	self.collider:makeThisMovableByThat(self,SimpleGobber)
	self.collider:makeThisMovableByThat(self,Player)
	self.collider:makeThisMovableByThat(self,Sword)
	
	self.collider:addNonCollidable(self.sprite,self.scene,1)
	
	self.collider:makeCollidable(self,Wall)
	self.collider:makeCollidable(self,CircleWall)
			
	self.collider:makeThisMovableByThat(self,Wall)
	self.collider:makeThisMovableByThat(self,CircleWall)
end
function SimpleGobber:update(dt)
	if dt ~= 0 then
		if self.mode == 'koed' then
			self.x = self.x + self.shoveVX * self.shoveSpeed * dt
			self.y = self.y + self.shoveVY * self.shoveSpeed * dt
			if (self.x + self.radius < -10 or self.x - self.radius > tlz.SCREEN_WIDTH + 10) and
			(self.y + self.radius < -10 or self.y - self.radius > tlz.SCREEN_HEIGHT + 10) then
				self:remove()
			end
			self.bounceDT = self.bounceDT + dt
		elseif self.mode == 'splat' then
			self.shoveSpeed = self.shoveSpeed - self.shoveSpeed / 0.6 * dt
			self.x = self.x + self.shoveVX * self.shoveSpeed * dt
			self.y = self.y + self.shoveVY * self.shoveSpeed * dt
			if self.sprite.justFinAnim then
				self:remove()
			end
		else
			local xDiff = self.player.x - self.x
			local yDiff = self.player.y - self.y
			
			xDiff = xDiff + math.random(0,100) - 50
			yDiff = yDiff + math.random(0,100) - 50
			
			if self.mode == 'normal' then
				if self.shoveSpeed < self.biteMove then
					self.sprite:setState('chomp')
					self.dir = math.atan2(yDiff,xDiff)
				end
				
				if self.sprite.justFinAnim then					
					local d = math.sqrt(xDiff * xDiff + yDiff * yDiff)
					self.moveVX = xDiff / d
					self.moveVY = yDiff / d
					self.moveSpeed = self.biteMove
				end				
				--self.dir = math.atan2(yDiff,xDiff)
			else -- mode is 'knockedOut'
				self.stars:alt_update(dt)
				if self.shoveSpeed < self.biteMove then
					self.sprite:setState('crippleChomp')
				end
				if self.sprite.justFinAnim then
					self.dir = math.atan2(yDiff,xDiff)
					
					local d = math.sqrt(xDiff * xDiff + yDiff * yDiff)
					self.moveVX = xDiff / d
					self.moveVY = yDiff / d
					self.moveSpeed = self.biteMove
				end
			end
			
			
			self.x = self.x + (self.shoveVX * self.shoveSpeed + self.moveVX * self.moveSpeed) * dt
			self.y = self.y + (self.shoveVY * self.shoveSpeed + self.moveVY * self.moveSpeed) * dt
		
			self.shoveSpeed = self.shoveSpeed - self.shoveSpeed / 0.6 * dt
			
			self.moveSpeed = math.max(0,self.moveSpeed - self.biteMove / 0.3 * dt)
		end
	else
		local xDiff = self.player.x - self.x
		local yDiff = self.player.y - self.y
			
		xDiff = xDiff + math.random(0,100) - 50
		yDiff = yDiff + math.random(0,100) - 50
		self.dir = math.atan2(yDiff,xDiff) * .8 + math.random()*tlz.RAD360 *.2
	end
end
function SimpleGobber:hit(vX,vY,v,aL,hitMode)
	if self.mode ~= 'koed' then
		self.sprite:setState('hit')
		local f = 100
		self.hits = self.hits - hitMode
		if self.mode == 'knockedOut' then
			if hitMode == 2 then
				self.mode = 'koed' 
				self.bounces = 0
				self.bounceDT = 0
				f = 200
				self.stars:remove()
				self.stars = nil
				if self.collider.uniqueID.Player.sword.velocity > 0 then
					self.sprite:setState('spinC')
				else
					self.sprite:setState('spinCC')
				end
			end
		elseif self.hits <= 0 then
			self.koable = true
			self.mode = 'knockedOut'
			self.stars = Stars:new(self)	
			self.stars.x = self.x
			self.stars.y = self.y
			self.collider:add(self.stars,self.scene)
		end
		self.dir = self.collider.uniqueID.Player.sword.rotation.a
		self.shoveSpeed = f
		self.shoveVX = vX
		self.shoveVY = vY
	end
end
function SimpleGobber:onCollision(other,data)
	if other:instanceOf(SimpleGobber) and self.shoveSpeed > other.shoveSpeed then
		other.shoveVX = self.shoveVX
		other.shoveVY = self.shoveVY
		other.shoveSpeed = math.min(math.max(5,self.shoveSpeed-20),80)
	end
	if self.mode == 'koed' then
		if data.vY == 0 then
			self.shoveVX = -self.shoveVX
		elseif data.vX == 0 then
			self.shoveVY = -self.shoveVY
		else
			self.shoveVX = data.vX
			self.shoveVY = data.vY
		end
		if self.bounceDT > 0.05 then
			self.bounces = self.bounces + 1
			self.bounceDT = 0
		end
		if self.bounces == 3 then
			self.mode = 'splat'
			--self.shoveSpeed = 0
			self.collider:makeUncollidable(self,SimpleGobber)
			self.collider:makeUncollidable(self,Player)
			self.collider:makeUncollidable(self,Sword)
			self.sprite:setState('splat')
		end
	elseif self.mode ~= 'splat' then
		if other:instanceOf(Player) then
			other:hit(data,1,100+self.shoveSpeed)
		end
	end
end
function SimpleGobber:draw()
	local image = self.spriteSheet.image
	local quad = self.sprite:getFrame()
	love.graphics.setColor(255,255,255,255 * self.scene.alpha)
	love.graphics.drawq(image,quad,math.ceil(self.x),math.ceil(self.y),math.floor(self.dir / tlz.RAD90)*tlz.RAD90,1,1,4,4)
end
function SimpleGobber:remove()
	self.sprite:remove()
	if self.stars then self.stars:remove() end
	self.collider:remove(self)
end