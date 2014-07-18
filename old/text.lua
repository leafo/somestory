class "Char" : extends(Entity){
	alpha = 1,
	fadeTime = .3,
}
function Char:load()
	if not self.loaded then
		---------Load in Here--------
		self.spriteSheet = SpriteSheet:new('graphics/chars.png')
		self.spriteSheet:addAnim('a',0,1,1,8,8,0,0)
		self.spriteSheet:addAnim('b',0,1,1,8,8,1,0)
		self.spriteSheet:addAnim('c',0,1,1,8,8,2,0)
		self.spriteSheet:addAnim('d',0,1,1,8,8,3,0)
		self.spriteSheet:addAnim('e',0,1,1,8,8,4,0)
		self.spriteSheet:addAnim('f',0,1,1,8,8,5,0)
		self.spriteSheet:addAnim('g',0,1,1,8,8,6,0)
		self.spriteSheet:addAnim('h',0,1,1,8,8,7,0)
		self.spriteSheet:addAnim('i',0,1,1,8,8,0,1)
		self.spriteSheet:addAnim('j',0,1,1,8,8,1,1)
		self.spriteSheet:addAnim('k',0,1,1,8,8,2,1)
		self.spriteSheet:addAnim('l',0,1,1,8,8,3,1)
		self.spriteSheet:addAnim('m',0,1,1,8,8,4,1)
		self.spriteSheet:addAnim('n',0,1,1,8,8,5,1)
		self.spriteSheet:addAnim('o',0,1,1,8,8,6,1)
		self.spriteSheet:addAnim('p',0,1,1,8,8,7,1)
		self.spriteSheet:addAnim('q',0,1,1,8,8,0,2)
		self.spriteSheet:addAnim('r',0,1,1,8,8,1,2)
		self.spriteSheet:addAnim('s',0,1,1,8,8,2,2)
		self.spriteSheet:addAnim('t',0,1,1,8,8,3,2)
		self.spriteSheet:addAnim('u',0,1,1,8,8,4,2)
		self.spriteSheet:addAnim('v',0,1,1,8,8,5,2)
		self.spriteSheet:addAnim('w',0,1,1,8,8,6,2)
		self.spriteSheet:addAnim('x',0,1,1,8,8,7,2)
		self.spriteSheet:addAnim('y',0,1,1,8,8,0,3)
		self.spriteSheet:addAnim('z',0,1,1,8,8,1,3)
		
		self.spriteSheet:addAnim('0',0,1,1,8,8,2,3)
		self.spriteSheet:addAnim('1',0,1,1,8,8,3,3)
		self.spriteSheet:addAnim('2',0,1,1,8,8,4,3)
		self.spriteSheet:addAnim('3',0,1,1,8,8,5,3)
		self.spriteSheet:addAnim('4',0,1,1,8,8,6,3)
		self.spriteSheet:addAnim('5',0,1,1,8,8,7,3)
		self.spriteSheet:addAnim('6',0,1,1,8,8,0,4)
		self.spriteSheet:addAnim('7',0,1,1,8,8,1,4)
		self.spriteSheet:addAnim('8',0,1,1,8,8,2,4)
		
		self.spriteSheet:addAnim('9',0,1,1,8,8,3,4)
		self.spriteSheet:addAnim(' ',0,1,1,8,8,4,4)
		
		self.spriteSheet:addAnim('?',0,1,1,8,8,5,4)
		self.spriteSheet:addAnim('!',0,1,1,8,8,6,4)
		-----------------------------
		self.loaded = true
		self.usedInScenes = 1
	else
		self.usedInScenes = self.usedInScenes + 1
	end
end
function Char:unload()
	self.usedInScenes = self.usedInScenes - 1
	if self.usedInScenes < 1 then
		---------Unload in Here--------
		self.spriteSheet:remove()
		-------------------------------
		self.loaded = false
	end
end
function Char:init(char,x,y)
	self.x = x or self.x
	self.y = y or self.y
	self.sprite = Sprite:new(self.spriteSheet)
	self.sprite:setState(char)
end
function Char:draw_active()
	local image = self.spriteSheet.image
	local quad = self.sprite:getFrame()
	love.graphics.setColor(255,255,255,255*self.alpha*self.scene.alpha)
	love.graphics.drawq(image,quad,math.ceil(self.x),math.ceil(self.y),0,1,1,0,0)
end

function Char:update_fade(dt)
	self.alpha = self.alpha - self.alpha / self.fadeTime * dt
	if self.alpha <= 0.05 then
		self.alpha = 0
		self:remove()
	end
end
function Char:fade()
	self.update = Char.update_fade
end
function Char:setActive(active)
	local active = active == nil and true or active
	if active then
		self.draw = Char.draw_active
	else
		self.draw = tlz.NILFUNCTION
	end
end
function Char:remove()
	if self.collider ~= nil then self.collider:remove(self) end
end

class "Text" : extends(Entity){
	x = 0,
	y = 0,
	defaultDelay = .1,
	position = 1,
	finDisplay = false
}
function Text:init(x,y,waitFor)
	self.x = x or self.x
	self.y = y or self.y
	self.waitFor = waitFor or nil
	
	self.charSeq = {}
end
function Text:addChar(char,xOffset,yOffset,delay)
	local xOffset = xOffset or 0
	local yOffset = yOffset or 0
	if #self.charSeq ~= 0 then
		posX = self.charSeq[#self.charSeq].x + 8
		posY = self.charSeq[#self.charSeq].y
	else
		posX = self.x
		posY = self.y
	end
	if char == '' then
		posX = posX - 8
		char = ' '
	end
	local char = Char:new(char,posX + xOffset,posY + yOffset)
	char.delay = delay or self.defaultDelay
	char.fadeTime = char.delay
	table.insert(self.charSeq,char)
	if not self.currentDelay then self.currentDelay = char.delay end
end
function Text:addString(str,xOffset,yOffset,delay)
	local xOffset = xOffset or 0
	local yOffset = yOffset or 0
	self:addChar(str:sub(1,1),xOffset,yOffset,delay)
	local str = str:sub(2)
	for c in str:gmatch(".") do
		self:addChar(c)
	end
end
function Text:update(dt)
	if self.waitFor then
		if self.waitFor.finDisplay then
			self.waitFor = nil
		end
	else
		self.currentDelay = self.currentDelay - dt
		while self.currentDelay <= 0 do
			self.charSeq[self.position]:setActive()
			self.collider:addNonCollidable(self.charSeq[self.position],self.scene,self.layer)
			self.position = self.position + 1
			if self.position ~= #self.charSeq + 1 then
				self.currentDelay = self.currentDelay + self.charSeq[self.position].delay
			else
				self.update = tlz.NILFUNCTION
				self.finDisplay = true
				break
			end
		end
	end
end
function Text:update_fade(dt)
	self.currentDelay = self.currentDelay - dt
	while self.currentDelay <= 0 do
		self.charSeq[self.position]:fade()
		self.position = self.position + 1
		if self.position ~= #self.charSeq + 1 then
			self.currentDelay = self.currentDelay + self.charSeq[self.position].delay
		else
			self.update = Text.update_remove
			break
		end
	end
end
function Text:update_remove()
	if self.charSeq[#self.charSeq].alpha == 0 then
		self:remove()
	end
end
function Text:fade()
	self.update = Text.update_fade
	self.position = 1
end
function Text:remove()
	for i,_ in ipairs(self.charSeq) do
		if self.charSeq[i].update ~= Char.update_fade then
			self.charSeq[i]:remove()
		end
		self.charSeq[i] = nil
	end
	self.collider:remove(self)
end