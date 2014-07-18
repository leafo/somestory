scenes.testWorld = {name = 'testWorld',width=432,height=240}
function scenes.testWorld:load() end
function scenes.testWorld:unload() end
function scenes.testWorld:spawn() end
function scenes.testWorld:draw()
	love.graphics.setColor(255,255,255,255 * self.bgAlpha)
	love.graphics.draw(tlz.plainYellowBG,math.ceil(self.x),math.ceil(self.y))
end