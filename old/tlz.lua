require "32log"

tlz = {}
-----------------
-- Misc. TOOLZ --
tlz.SCREEN_WIDTH = love.graphics.getWidth()
tlz.SCREEN_HEIGHT = love.graphics.getHeight()

tlz.BOUNDD = 64
tlz.BOUNDDSOFT = 64

tlz.BLACK = {R = 9, G = 9, B = 17}
tlz.WHITE = {R = 255, G = 255, B = 229}

tlz.NILFUNCTION = function() end
function tlz.wipeTable(t)
	for i in pairs(t) do
		t[i] = nil
	end	
end

tlz.SQRT2 = math.sqrt(2)
tlz.NANSTRING = tostring(math.sqrt(-1))
tlz.RAD360 = math.rad(360)
tlz.RAD180 = math.rad(180)
tlz.RAD90 = math.rad(90)
tlz.RAD45 = math.rad(45)
tlz.RADRIGHT = 0
tlz.RADDOWN = math.rad(90)
tlz.RADLEFT = math.rad(180)
tlz.RADUP = math.rad(270)

function tlz.scale(min,pos,max)
	return tlz.round((max - math.min(math.max(min,pos),max)) / (max-min),7)
end

function tlz.isNaN(num)
	return num ~= num
end

function tlz.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function tlz.angleWithin(x, a, b)
	x = x % tlz.RAD360
	a = a % tlz.RAD360
	b = b % tlz.RAD360
	if a <= b then
		return x >= a and x <= b
	else
		return x < b or x > a
	end
end
-- Misc. TOOLZ --
-----------------
-- Input TOOLZ --
love.keyboard.keysPressed = {}

function love.keyboard.wasPressed(key)
	return love.keyboard.keysPressed[key]
end

function love.keyboard.resetKeys()
	love.keyboard.keysPressed = {}
end

tlz.UP = 'up'
tlz.DOWN = 'down'
tlz.LEFT = 'left'
tlz.RIGHT = 'right'
tlz.A = 'a'
tlz.B = 's'

tlz.k = love.keyboard.isDown
tlz.kP = love.keyboard.wasPressed
-- Input TOOLZ --
----------------------------------------
-- Collision Toolz --

class "Collider" {}
function Collider:init()
	self.timeScale = 1
	self.objects = {}
	self.objectsNoCollisionPositive = {{},{},{},{},{},{},{},{},{},{}}
	self.objectsNoCollisionNegative = {{},{},{},{},{},{},{},{},{},{}}
	self.toAddObjects = {}
	self.toAddObjectsNoCollision = {}
	self.uniqueID = {}
	self.objectsSize = 0
	self.collidables = {}
	self.movables = {}
	self.toRemove = {}
	self.objectsIndex = {}
	self.scenes = {}
	self.camera = {x = 0, y = 0, xTime = 0, yTime = 0, xMovPos = 0, yMovPos = 0, movCamX = false, movCamY = false, scenes = {}, scene = nil, locked = false, holder = nil, boundD = 0, boundDSoft = 0}
end
-- returns scene closest to coords
function Collider:getClosestScene(x,y)
	local closestScene = nil
	local closestD = 0
	for _,v in pairs(self.scenes) do
		if not v.closed then
			local d = math.max(math.max(v.x - x,x - (v.x + v.width)),math.max(v.y - y,y - (v.y + v.height)))
			--[[if not v.closed then
				print(tlz.round(math.max(v.x - x,x - (v.x + v.width))),
				tlz.round(math.max(v.y - y,y - (v.y + v.height))),
				v.name)
			end]]--
			if d < closestD or closestScene == nil then
				closestD = d
				closestScene = v
			end
		end
	end
	return closestScene
end
function Collider:repositionWorld(scene)
	self.reposWorld = true
	if scene then
		self.reposWorldScene = scene
	end
end
function Collider:lockCamera(holder,boundD,boundDSoft,time)
	self.camera.holder = holder
	--self.camera.scenes = scenes
	self.camera.locked = true
	self.camera.transitioning = true
	self.camera.boundD = boundD or 0
	self.camera.boundDSoft = boundDSoft or self.camera.boundD
	local time = time or 1
	self.camera.lockXTime = time
	self.camera.lockYTime = time
	self.camera.xTime = time
	self.camera.yTime = time
	self.camera.movCamX = true
	self.camera.movCamY = true
end
function Collider:moveCameraTo(x,y,time,keepLocked)
	local time = time or 0
	if time == 0 then
		if x ~= nil then
			self.camera.x = x
		end
		if y ~= nil then
			self.camera.y = y
		end
	else
		if x ~= nil and x ~= self.camera.xMovPos then
			self.camera.xMovPos = x
			self.camera.xTime = time
			self.camera.movCamX = true
		end
		if y ~= nil and y ~= self.camera.yMovPos then
			self.camera.yMovPos = y
			self.camera.yTime = time
			self.camera.movCamY = true
		end
	end
	if not keepLocked then
		self.camera.locked = false
		self.camera.transitioning = false
	end
end
function Collider:moveSceneTo(scene,x,y,time)
	local time = time or 0
	if x ~= nil and x ~= scene.xMovPos then
		scene.xMovPos = x
		scene.xTime = time
		scene.movX = true
	end
	if y ~= nil and y ~= scene.yMovPos then
		scene.yMovPos = y
		scene.yTime = time
		scene.movY = true
	end
end
function Collider:moveToScene(entity,scene)
	if entity.nonCollidable then
		entity.scene.objectsNoCollision[entity] = nil
		scene.objectsNoCollision[entity] = entity
	else
		entity.scene.objects[entity] = nil
		scene.objects[entity] = entity
	end

	entity.scene = scene
end
function Collider:addScene(scene,xRel,yRel,xOffset,yOffset,sceneBase)
	local x = (xOffset or 0) + (scene.worldX or 0) + (sceneBase and sceneBase.x or 0)
	local y = (yOffset or 0) + (scene.worldY or 0) + (sceneBase and sceneBase.y or 0)
	
	scene.movX = false
	scene.movY = false
	scene.xTime = 0
	scene.yTime = 0
	scene.xMovPos = 0
	scene.yMovPos = 0
	scene.drawable = true
	scene.collider = self
	scene.timeScale = 1
	scene.alpha = 1
	scene.bgAlpha = 1
	scene.fgAlpha = 1
	scene.drawable = true
	scene.objects = {}
	scene.objectsNoCollision = {}
	
	if sceneBase ~= nil then
		if xRel == 'left' then
			x = - scene.width + x
		elseif xRel == 'right' then
			x = sceneBase.width + x
		end
		if yRel == 'up' then
			y = - scene.height + y
		elseif yRel == 'down' then
			y = sceneBase.height + y
		end
	end
	scene.x = x
	scene.y = y
	scene.worldX = x
	scene.worldY = y
	
	scene:load()
	table.insert(self.scenes,scene)
end
function Collider:closeScene(scene,keepDraw)
	scene.closed = true
	if not keepDraw then scene.drawable = false end
	scene:unload()
	for i,v in pairs(scene.objects) do
		table.insert(self.toRemove,v)
	end
	for i,v in pairs(scene.objectsNoCollision) do
		table.insert(self.toRemove,v)
	end
end
function Collider:openScene(scene,keepDraw)
	scene.closed = false
	scene.drawable = keepDraw ~= true and true or scene.drawable
	scene:load()
	for _,v in pairs(scene.objects) do
		v.init_collider = tlz.NILFUNCTION
		if v.reinit then v:reinit() end
		table.insert(self.toAddObjects,v)
	end
	for _,v in pairs(scene.objectsNoCollision) do
		v.init_collider = tlz.NILFUNCTION
		if v.reinit then v:reinit() end
		table.insert(self.toAddObjectsNoCollision,v)
	end
	tlz.frame = 0
end
function Collider:add(object,scene)
	assert(object ~= nil,'Attempted to add nil to a Collider.')
	object.collider = self
	object.scene = scene
	object:init_collider()
	
	self.objectsSize = self.objectsSize+1
	self.objects[self.objectsSize] = object
	self.objectsIndex[object] = self.objectsSize
	--print('added objects['..self.objectsSize..'] = '..object.name)
	
	scene.objects[object] = object
end
function Collider:addNonCollidable(object,scene,layer)
	local layer = type(layer) == 'number' and layer or 1
	object.collider = self
	object.scene = scene
	object.nonCollidable = true
	
	layer = layer == 0 and 1 or layer
	
	object.layer = layer
	
	if object.init_collider then object:init_collider() end
	
	if layer > 0 then
		self.objectsNoCollisionPositive[layer][object] = object
		--print('added objectsNoCollisionPositive['..layer..'] '..object.name)
	else
		layer = (11+layer)
		self.objectsNoCollisionNegative[layer][object] = object
		--print('added objectsNoCollisionNegative['..layer..'] '..object.name)
	end
	scene.objectsNoCollision[object] = object
end
function Collider:addUniqueID(object,id)
	object.uniqueID = id
	self.uniqueID[id] = object
end
function Collider:remove(object)
	table.insert(self.toRemove,object)
	object.removeFromScene = true
end
function Collider:makeCollidable(e1,e2)
	self.collidables[e1] = self.collidables[e1] or {}
	self.collidables[e2] = self.collidables[e2] or {}
	self.collidables[e1][e2] = true
	self.collidables[e2][e1] = true
end
function Collider:makeUncollidable(e1,e2)
	self.collidables[e1] = self.collidables[e1] or {}
	self.collidables[e2] = self.collidables[e2] or {}
	self.collidables[e1][e2] = false
	self.collidables[e2][e1] = false
end
function Collider:areCollidable(e1,e2)
	local t = self.collidables[e1]
	local tC = self.collidables[_G[e1.name]]
	return (t ~= nil and (t[e2] or (t[_G[e2.name]] and t[e2] == nil)))
			or (tC ~= nil and (tC[e2] or (tC[_G[e2.name]] and tC[e2] == nil)))
end
function Collider:makeThisMovableByThat(e1,e2)
	self.movables[e1] = self.movables[e1] or {}
	self.movables[e1][e2] = true
end
function Collider:makeThisUnmovableByThat(e1,e2)
	self.movables[e1] = self.movables[e1] or {}
	self.movables[e1][e2] = false
end
function Collider:thisMovableByThat(e1,e2)
	local t = self.movables[e1]
	local tC = self.movables[_G[e1.name]]
	return (t ~= nil and (t[e2] or (t[_G[e2.name]] and t[e2] == nil)))
			or (tC ~= nil and (tC[e2] or (tC[_G[e2.name]] and tC[e2] == nil)))
end
function Collider:collide()
	local collisions = {}

	local i = 1
	while i <= self.objectsSize do
		local ii = i + 1
		while ii <= self.objectsSize do
			local obj1 = self.objects[i]
			local obj2 = self.objects[ii]
	
			if self:areCollidable(obj1,obj2) and not obj1.noCollisions and not obj2.noCollisions and
				(obj1.scene.timeScale + obj2.scene.timeScale > 0) then
				
				local isColliding, data = obj1:collide(obj2)
				if isColliding then
					table.insert(collisions,{obj1,obj2,data})
				end
			end
			
			ii = ii + 1
		end
		i = i + 1
	end
				
	for _,v in pairs(collisions) do
		v[1]:onCollision(v[2],v[3])
		v[3].vX = -v[3].vX
		v[3].vY = -v[3].vY
		v[2]:onCollision(v[1],v[3])
	end
end
function Collider:modCoords()
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			vv.x = vv.x + math.ceil(vv.scene.x)
			vv.y = vv.y + math.ceil(vv.scene.y)
		end
	end
	for _,v in pairs(self.objects) do
		v.x = v.x + math.ceil(v.scene.x)
		v.y = v.y + math.ceil(v.scene.y)
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			vv.x = vv.x + math.ceil(vv.scene.x)
			vv.y = vv.y + math.ceil(vv.scene.y)
		end
	end
end
function Collider:unmodCoords()
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			vv.x = vv.x - math.ceil(vv.scene.x)
			vv.y = vv.y - math.ceil(vv.scene.y)	
		end
	end
	for _,v in pairs(self.objects) do
		v.x = v.x - math.ceil(v.scene.x)
		v.y = v.y - math.ceil(v.scene.y)
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			vv.x = vv.x - math.ceil(vv.scene.x)
			vv.y = vv.y - math.ceil(vv.scene.y)
		end
	end
end
function Collider:cameraMovement(dt)
	if self.camera.locked then
		local x = math.min(self.camera.holder.x - (self.camera.x + self.camera.boundD),0)
		x = x + math.max(0,self.camera.holder.x - (self.camera.x + tlz.SCREEN_WIDTH - self.camera.boundD))
		x = self.camera.x + x
		
		local y = math.min(math.ceil(self.camera.holder.y) - (self.camera.y + self.camera.boundD),0)
		y = y + math.max(0,math.ceil(self.camera.holder.y) - (self.camera.y + tlz.SCREEN_HEIGHT - self.camera.boundD))
		y = self.camera.y + y
		
		if self.camera.transitioning then
			self:moveCameraTo(x,nil,self.camera.xTime,true)
			self:moveCameraTo(nil,y,self.camera.yTime,true)
			if self.camera.xTime == 0 and self.camera.yTime == 0 then self.camera.transitioning = false end
		else
			if x < self.camera.holder.scene.x then
				self:moveCameraTo(self.camera.holder.scene.x,nil,self.camera.lockXTime,true)
			elseif x + tlz.SCREEN_WIDTH > self.camera.holder.scene.x + self.camera.holder.scene.width then
				self:moveCameraTo(self.camera.holder.scene.x + self.camera.holder.scene.width - tlz.SCREEN_WIDTH,
																						nil,self.camera.lockXTime,true)
			else
				self:moveCameraTo(x,nil,0,true)
			end
			
			if y < self.camera.holder.scene.y then
				self:moveCameraTo(nil,self.camera.holder.scene.y,self.camera.lockYTime,true)
			elseif y + tlz.SCREEN_HEIGHT > self.camera.holder.scene.y + self.camera.holder.scene.height then
				self:moveCameraTo(nil,self.camera.holder.scene.y + self.camera.holder.scene.height - tlz.SCREEN_HEIGHT,
																								self.camera.lockYTime,true)
			else
				self:moveCameraTo(nil,y,0,true)
			end
		end
	end

	if self.camera.movCamX then
		local xDRemaining = self.camera.xMovPos - self.camera.x
		self.camera.x = self.camera.x + xDRemaining / self.camera.xTime * dt
		self.camera.xTime = self.camera.xTime - dt
		if self.camera.xTime <= 0 then
			self.camera.x = self.camera.xMovPos
			self.camera.movCamX = false
			self.camera.xTime = 0
			self.camera.xMovPos = nil
		end
	end
	if self.camera.movCamY then
		local yDRemaining = self.camera.yMovPos - self.camera.y
		self.camera.y = self.camera.y + yDRemaining / self.camera.yTime * dt
		self.camera.yTime = self.camera.yTime - dt
		if self.camera.yTime <= 0 then
			self.camera.y = self.camera.yMovPos
			self.camera.movCamY = false
			self.camera.yTime = 0
			self.camera.yMovPos = nil
		end
	end
end
function Collider:update(dt)
	for _,v in pairs(self.toAddObjects) do
		self:add(v,v.scene)
	end
	self.toAddObjects = {}
	for _,v in pairs(self.toAddObjectsNoCollision) do
		self:addNonCollidable(v,v.scene,v.layer)
	end
	self.toAddObjectsNoCollision = {}

	self:modCoords()
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			vv:updateStartFrame(dt * vv.scene.timeScale * self.timeScale)
		end
	end
	for _,v in ipairs(self.objects) do
		v:updateStartFrame(dt * v.scene.timeScale * self.timeScale)
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			vv:updateStartFrame(dt * vv.scene.timeScale * self.timeScale)
		end
	end
	
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			vv:update(dt * vv.scene.timeScale * self.timeScale)
		end
	end
	for _,v in ipairs(self.objects) do
		v:update(dt * v.scene.timeScale * self.timeScale)
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			vv:update(dt * vv.scene.timeScale * self.timeScale)
		end
	end

	self:collide()
	
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			vv:updateEndFrame(dt * vv.scene.timeScale * self.timeScale)
		end
	end
	for _,v in ipairs(self.objects) do
		v:updateEndFrame(dt * v.scene.timeScale * self.timeScale)
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			vv:updateEndFrame(dt * vv.scene.timeScale * self.timeScale)
		end
	end
	
	self:cameraMovement(dt)
	
	self:unmodCoords()
	
	for _,v in pairs(self.scenes) do
		if v.movX then
			local xDRemaining = v.xMovPos - v.x
			v.x = v.x + xDRemaining / v.xTime * dt
			v.xTime = v.xTime - dt
			if v.xTime <= 0 then
				v.x = v.xMovPos
				v.movX = false
				v.xTime = 0
			end
		end
		if v.movY then
			local yDRemaining = v.yMovPos - v.y
			v.y = v.y + yDRemaining / v.yTime * dt
			v.yTime = v.yTime - dt
			if v.yTime <= 0 then
				v.y = v.yMovPos
				v.movY = false
				v.yTime = 0
			end
		end
	end
	
	if self.reposWorld then
		local xOff = 0
		local yOff = 0
		if self.reposWorldScene then
			xOff = xOff + self.reposWorldScene.worldX
			yOff = yOff + self.reposWorldScene.worldY
		end
		
		scenes.NILSCENE.x = scenes.NILSCENE.x + xOff
		scenes.NILSCENE.y = scenes.NILSCENE.y + yOff
		
		for _,v in pairs(self.scenes) do
			v.x = v.x - scenes.NILSCENE.x
			v.y = v.y - scenes.NILSCENE.y
			v.xMovPos = v.xMovPos - scenes.NILSCENE.x
			v.yMovPos = v.yMovPos - scenes.NILSCENE.y
			v.worldX = v.worldX - scenes.NILSCENE.x
			v.worldY = v.worldY - scenes.NILSCENE.y
		end
		
		self.camera.x = self.camera.x - scenes.NILSCENE.x
		self.camera.y = self.camera.y - scenes.NILSCENE.y
		if self.camera.xMovPos ~= nil then
			self.camera.xMovPos = self.camera.xMovPos - scenes.NILSCENE.x
		end
		if self.camera.yMovPos ~= nil then
			self.camera.yMovPos = self.camera.yMovPos - scenes.NILSCENE.y
		end
		
		scenes.NILSCENE.x =  scenes.NILSCENE.x - xOff
		scenes.NILSCENE.y = scenes.NILSCENE.y - yOff
		
		self.reposWorldScene = nil
		self.reposWorld = false
		print('repositioned',xOff,yOff)
	end
	
	for _,v in pairs(self.toRemove) do
		local ii = self.objectsIndex[v]
		if ii ~= nil then
			self.objectsIndex[v] = nil
			
			local replaceObj = self.objects[self.objectsSize]
			self.objectsIndex[replaceObj] = ii
			self.objects[ii] = replaceObj
			
			self.objects[self.objectsSize] = nil
			self.objectsSize = self.objectsSize - 1
			print('removed objects['..ii..'] '..v.name)
			
			if v.removeFromScene then
				v.scene.objects[v] = nil
			end
		else
			if v.layer then
				if v.layer > 0 then
					self.objectsNoCollisionPositive[v.layer][v] = nil
					print('removed objectsNoCollisionPositive['..(v.layer)..']['..tostring(v)..'] '..v.name)
				else
					self.objectsNoCollisionNegative[11+v.layer][v] = nil
					print('removed objectsNoCollisionNegative['..(-v.layer)..']['..tostring(v)..'] '..v.name)
				end
				if v.removeFromScene then
					v.scene.objectsNoCollision[v] = nil
				end
			end
		end
		
		if v.uniqueID then self.uniqueID[v.uniqueID] = nil end
		if v.removeFromScene then tlz.wipeTable(v) end
	end
	self.toRemove = {}
end
function Collider:draw()
	scenes.NILSCENE.x = scenes.NILSCENE.x - math.ceil(self.camera.x)
	scenes.NILSCENE.y = scenes.NILSCENE.y - math.ceil(self.camera.y)
	for _,v in pairs(self.scenes) do
		v.x = v.x - math.ceil(self.camera.x)
		v.y = v.y - math.ceil(self.camera.y)
		if v.drawable and not v.closed then
			love.graphics.setColor(255,255,255)
			v:draw()
		end
	end
	self:modCoords()
	
	for _,v in pairs(self.objectsNoCollisionNegative) do
		for _, vv in pairs(v) do
			if vv.scene.drawable then
				love.graphics.setColor(255,255,255)
				vv:draw()
			end
		end
	end
	for _,v in pairs(self.objects) do
		if v.scene.drawable then
			love.graphics.setColor(255,255,255)
			v:draw()
		end
	end
	for _,v in pairs(self.objectsNoCollisionPositive) do
		for _, vv in pairs(v) do
			if vv.scene.drawable then
				love.graphics.setColor(255,255,255)
				vv:draw()
			end
		end
	end
	if debugMode and drawDebug then
		for _,v in pairs(self.objectsNoCollisionNegative) do
			for _, vv in pairs(v) do
				love.graphics.setColor(255,255,255)
				vv:draw_debug()
			end
		end
		for _,v in ipairs(self.objects) do
			love.graphics.setColor(255,255,255)
			v:draw_debug()
		end
		for _,v in pairs(self.objectsNoCollisionPositive) do
			for _, vv in pairs(v) do
				love.graphics.setColor(255,255,255)
				vv:draw_debug()
			end
		end
	end
	
	self:unmodCoords()
	
	for _,v in pairs(self.scenes) do
		v.x = v.x + math.ceil(self.camera.x)
		v.y = v.y + math.ceil(self.camera.y)
	end
	scenes.NILSCENE.x = scenes.NILSCENE.x + math.ceil(self.camera.x)
	scenes.NILSCENE.y = scenes.NILSCENE.y + math.ceil(self.camera.y)
end

class "Entity" {x = 0, y = 0}
function Entity:load() end
function Entity:unload() end
function Entity:init() end
function Entity:init_collider() end
function Entity:updateStartFrame(dt) end
function Entity:update(dt) end
function Entity:updateEndFrame(dt) end
function Entity:draw() end
function Entity:draw_debug()
	love.graphics.setColor(0,255,255,255 * 0.5)
	love.graphics.circle('fill', self.x, self.y, 3)
	love.graphics.setColor(255,255,255)
end
--[[function Entity:remove()
	if self.collider then self.collider:remove(self) end
end]]--

class "Circle" : extends(Entity){
	radius = 32,
}
function Circle:init(x,y,r)
	self.x = x
	self.y = y
	self.radius = r or self.radius
end
function Circle:draw_debug()
	love.graphics.setColor(255,255,255)
	love.graphics.circle('line', self.x, self.y, self.radius)
	love.graphics.setColor(0,255,0,255 * 0.6)
	love.graphics.circle('line', self.x, self.y, self.radius+3+0.1)
	love.graphics.setColor(255,255,255)
end
function Circle:collideCircle(x,y,radius,forceResults)
	local dX = self.x - x
	local dY = self.y - y
	local d = dX * dX + dY * dY
	radius = radius + self.radius
	if d <= radius * radius then
		d = math.sqrt(d)
		
		return true, dX / d, dY / d, (radius - d)
	end
	if forceResults then
		d = math.sqrt(d)
		return false, dX / d, dY / d, (radius - d)
	end
	return false, 0, 0, -1
end
function Circle:collideCirclePoints(x,y,radius)
	local dX = x - self.x
	local dY = y - self.y
	local d = math.sqrt(dX * dX + dY * dY)
	
	local dM = (d * d + self.radius * self.radius - radius * radius) / (2 * d)
	
	local xC = self.x + dX/d * dM
	local yC = self.y + dY/d * dM
	
	local dS = math.sqrt(self.radius * self.radius - dM * dM)

	data = {}
	
	data.x1 = xC + dY/d * dS
	data.y1 = yC - dX/d * dS
	
	data.x2 = xC - dY/d * dS
	data.y2 = yC + dX/d * dS
	
	data.xV = dX/d
	data.yV = dY/d
	data.d = d
	data.dM = dM
	data.xC = xC
	data.yC = yC
	data.dS = dS
	
	return data
end
function Circle:collide(other)
	if other:instanceOf(Circle) then
		local isColliding, vX, vY, vL = self:collideCircle(other.x,other.y,other.radius)
		data = {}
		data.vX = vX
		data.vY = vY
		data.vL = vL
		
		if self.solid and other.solid then
			if self.collider:thisMovableByThat(other,self) then
				if self.collider:thisMovableByThat(self,other) then
					vX = vX / 2
					vY = vY / 2
					self.x = self.x + vX * vL
					self.y = self.y + vY * vL
				end
				other.x = other.x - vX * vL
				other.y = other.y - vY * vL
			elseif self.collider:thisMovableByThat(self,other) then
				self.x = self.x + vX * vL
				self.y = self.y + vY * vL
			end
		end

		return isColliding, data
	elseif other:instanceOf(CircleLine) then
		local isColliding, data = other:collide(self)
		data.vX = -data.vX
		data.vY = -data.vY
		return isColliding, data
	end
end
function Circle:onCollision(other,data) end

class "CircleLine" : extends(Entity) {
	x = 0,
	y = 0,
	radius = 4,
	length = 32,
}
function CircleLine:init(x,y,r,l,a)
	self.x = x or self.x
	self.y = y or self.y
	self.length = l or self.length
	self.radius = r or self.radius
	local a = a or 0
	self.rotation = {velocity = 0,velocityFrameEnd = 0,aFrameEnd = a}
	self:setRotation(a)

	self.drawCollisions = {}
end
function CircleLine:setRotation(a)
	self.rotation.a = a % tlz.RAD360
	self.rotation.vX = math.cos(a)
	self.rotation.vY = math.sin(a)
end
function CircleLine:update(dt)
	self.rotation.aFrameEnd = self.rotation.a
	self.rotation.velocityFrameEnd = self.rotation.velocity
end
function CircleLine:draw_debug()
	love.graphics.setColor(255,0,0)
	love.graphics.circle('fill', self.x, self.y, 2)
	love.graphics.line(self.x,self.y,self.x + self.rotation.vX * self.length,self.y + self.rotation.vY*self.length)
	love.graphics.circle('line',self.x + self.rotation.vX * (self.length - self.radius),self.y + self.rotation.vY*(self.length-self.radius), self.radius)
	
	love.graphics.setColor(0,255,0,255 * .5)
	love.graphics.circle('line',self.x,self.y,self.length)
	love.graphics.circle('line', self.x, self.y,self.length - self.radius)
	for i,v in pairs(self.drawCollisions) do
		love.graphics.setColor(v[4],v[5],v[6],v[7])
		love.graphics.circle('fill',v[1],v[2],v[3])
	end
	love.graphics.setColor(255,255,255)
	self.drawCollisions = {}
end
function CircleLine:debug_addDraw(x,y,radius,red,green,blue,alpha)
	if debugMode and debugDraw then
		table.insert(self.drawCollisions,{x,y,radius or self.radius,red or 0,green or 255,blue or 0,alpha or 255 * .5})
	end
end
function CircleLine:collideCircle(x,y,radius,forceResults)
	local other = {}
	other.x = x
	other.y = y
	other.radius = radius
	
	local dX = other.x - self.x
	local dY = other.y - self.y
	local d = dX * dX + dY * dY

	local r = self.length + other.radius
	local isColliding = false
		
	if d < r*r or forceResults then
		
		local dP = self.rotation.vX * dX + self.rotation.vY * dY
			
		dP = math.max(0,dP)
		dP = math.min(dP,self.length-self.radius)
			
		local xP = self.x + dP * self.rotation.vX
		local yP = self.y + dP * self.rotation.vY
			
		local moreData = Circle.collideCirclePoints({x=other.x,y=other.y,radius=other.radius+self.radius},self.x,self.y,dP)

		local x = moreData.x1
		local y = moreData.y1
			
		local dirToOther = math.atan2(dY,dX)
			
		local otherIsClockwiseAfter = tlz.angleWithin(dirToOther,self.rotation.aFrameEnd,self.rotation.aFrameEnd+math.rad(180))
	
		if otherIsClockwiseAfter then
			x = moreData.x2
			y = moreData.y2
			self:debug_addDraw(moreData.x1,moreData.y1,3,255,0,0)
		else
			self:debug_addDraw(moreData.x2,moreData.y2,3,255,0,0)
		end
			
		self:debug_addDraw(x,y,3)
			
		local dXP = x - self.x
		local dYP = y - self.y
		local dir = math.atan2(dYP, dXP)
		local _, vX, vY, vL
		if (self.rotation.velocityFrameEnd > self.radius and tlz.angleWithin(dir,self.rotation.aFrameEnd,self.rotation.a) and otherIsClockwiseAfter)
		or (self.rotation.velocityFrameEnd < -self.radius and tlz.angleWithin(dir,self.rotation.a,self.rotation.aFrameEnd) and not otherIsClockwiseAfter) then
			isColliding = true
			dP = math.sqrt(dXP * dXP + dYP * dYP)
			local vXP = dXP / dP
			local vYP = dYP / dP
			xP = self.x + dP * vXP
			yP = self.y + dP * vYP
			self:debug_addDraw(xP,yP,3,0,150,255)
				
			_, vX, vY, vL = Circle.collideCircle({x=other.x,y=other.y,radius=other.radius},xP,yP,self.radius,true)
			vX = -vX
			vY = -vY
		else
			self:debug_addDraw(xP,yP,3,0,50,255)
			
			isColliding, vX, vY, vL = Circle.collideCircle({x=other.x,y=other.y,radius=other.radius},xP,yP,self.radius)
			vX = -vX
			vY = -vY
		end
		return isColliding, vX, vY, vL, dXP, dYP, dP, dir, otherIsClockwiseAfter
	end
	return false, 0, 0, -1
end
function CircleLine:collide(other)
	if other:instanceOf(Circle) then
		local isColliding, vX, vY, vL, dXP, dYP, dP, dir, otherIsClockwiseAfter = self:collideCircle(other.x,other.y,other.radius)
		local data = {}
		data.vX = vX
		data.vY = vY
		data.vL = vL
		data.dP = dP
		data.otherIsClockwiseAfter = otherIsClockwiseAfter
		
		if isColliding and other.solid and self.solid then
			if self.collider:thisMovableByThat(other,self) then
				other.x = other.x - data.vX * data.vL
				other.y = other.y - data.vY * data.vL
			elseif dP > self.radius and not tlz.isNaN(dir) then
				local vXP = dXP / dP
				local vYP = dYP / dP
				self.rotation.a = dir
				self.rotation.vX = vXP
				self.rotation.vY = vYP
			end
		end
		
		return isColliding, data
	elseif other:instanceOf(CircleLine) then
		if self.collider:thisMovableByThat(other,self) then
			local isColliding, data = other:collide(self)
			data.vX = -data.vX
			data.vY = -data.vY
			data.otherIsClockwiseAfter = not data.otherIsClockwiseAfter
			return isColliding, data
		elseif self.collider:thisMovableByThat(self,other) then
			local isColliding, vX, vY, vL = Circle.collideCircle({x=self.x,y=self.y,radius=self.radius},other.x,other.y,other.radius)
			local data = {}
			if isColliding then		
				return false, data
			end
			
			local dX = (self.x + self.rotation.vX * (self.length - self.radius)) - other.x
			local dY = (self.y + self.rotation.vY * (self.length - self.radius)) - other.y
		
			local dP = other.rotation.vX * dX + other.rotation.vY * dY
			dP = math.max(0,dP)
			dP = math.min(dP,other.length-other.radius)
			
			local xP = other.x + dP * other.rotation.vX
			local yP = other.y + dP * other.rotation.vY
			
			local dXP, dYP, dir, otherIsClockwiseAfter
			isColliding, vX, vY, vL, dXP, dYP, dP, dir, otherIsClockwiseAfter = self:collideCircle(xP,yP,other.radius)
			self:debug_addDraw(xP,yP,3,0,150,255)
			
			if isColliding then
				data.vX = vX
				data.vY = vY
				data.vL = vL
				data.dP = dP
				data.otherIsClockwiseAfter = otherIsClockwiseAfter
				
				if self.collider:thisMovableByThat(self,other) and not tlz.isNaN(dir) then
					local vXP = dXP / dP
					local vYP = dYP / dP
					self.rotation.a = dir
					self.rotation.vX = vXP
					self.rotation.vY = vYP
				end
				
				return isColliding, data 
			end
			return false, data
		end
	end
end
function CircleLine:onCollision(other,data) end