require "tlz"
--different objects can share the same SpriteSheet

class "SpriteSheet"{}

function SpriteSheet:init(filepath)
	self.image = love.graphics.newImage(filepath)
	self.animDict = {}
	self:addAnim('',0,0,0,0,0,0,0)
end

function SpriteSheet:addAnim(name, fps, xFrames, yFrames, w, h, xOff, yOff)
	if self.animDict[name] then
		for i, _ in pairs(self.animDict[name]) do
			self.animDict[name].frames[i] = nil
		end
	end
	self.animDict[name] = {frames = {}}
	self.animDict[name].fps = fps
	self:appendAnim(name, fps, xFrames, yFrames, w, h, xOff, yOff)
end

function SpriteSheet:appendAnim(name, fps, xFrames, yFrames, w, h, xOff, yOff)
	assert(type(name) == 'string','SpriteSheet:appendAnim, name is not a string')
	assert(type(fps) == 'number','SpriteSheet:appendAnim, fps is not a number')
	assert(type(xFrames) == 'number','SpriteSheet:appendAnim, xFrames is not a number')
	assert(type(yFrames) == 'number','SpriteSheet:appendAnim, yFrames is not a number')
	assert(type(w) == 'number','SpriteSheet:appendAnim, w is not a number')
	assert(type(h) == 'number','SpriteSheet:appendAnim, h is not a number')
	local xOff = xOff or 0
	local yOff = yOff or 0
	assert(type(xOff) == 'number','SpriteSheet:appendAnim, xOff is not a number')
	assert(type(yOff) == 'number','SpriteSheet:appendAnim, yOff is not a number')
	yFrames = math.max(1,yFrames)
	xFrames = math.max(1,xFrames)
	for y = 1,yFrames do
		for x = 1,xFrames do
			table.insert(self.animDict[name].frames,love.graphics.newQuad((x-1+xOff)*w,(y-1+yOff)*h,w,h,self.image:getWidth(),self.image:getHeight()))
		end
	end
end
function SpriteSheet:makeOneShot(name,oneShot)
	self.animDict[name].oneShot = oneShot == nil and true or oneShot
end
function SpriteSheet:remove()
	for _,v in pairs(self.animDict) do
		for _,vv in pairs(v.frames) do
			vv = nil
		end
		v = nil
	end
	self.animDict = nil
	self.image = nil
end

class "Sprite" : extends(Entity) {
	timer = 0,
	delay = 0,
	frame = 0,
	justFinFrame = false,
	justFinAnim = false,
	oldState = '',
	state = ''
}
function Sprite:init(spriteSheet,state)
	self.spriteSheet = spriteSheet
	self.state = state or self.state
end
function Sprite:update(dt)
	self.justFinFrame = false
	self.justFinAnim = false

	self.timer = self.timer + dt
	local spf = 1 / self.spriteSheet.animDict[self.state].fps
	while self.timer >= spf do
		self.frame = self.frame + 1
		self.timer = self.timer - spf
		self.justFinFrame = true
		if self.frame == #self.spriteSheet.animDict[self.state].frames then
			if self.spriteSheet.animDict[self.state].oneShot then
				self.frame = self.frame - 1
			else
				self.frame = 0
			end
			self.justFinAnim = true
		end
	end
end
function Sprite:setState(state)
	self.oldState = self.state
	self.state = state
	if self.oldState ~= self.state then
		self.timer = 0
		self.frame = 0
		self.justFinAnim = false
		self.justNextFrame = false
	end
end
function Sprite:getFrame()
	return self.spriteSheet.animDict[self.state].frames[self.frame+1]
end
function Sprite:remove()
	if self.collider ~= nil then self.collider:remove(self) end
end