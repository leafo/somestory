-- Add the scene meta-information, yo
-- Don't forget to require the scene in scenes.lua, yo
scenes.dreamWorld = {name='dreamWorld',width=480,height=480}

-- The scene initializing stuff, quack, I mean yo, yo
function scenes.dreamWorld:load()
end
function scenes.dreamWorld:unload()
end
function scenes.dreamWorld:spawn()
	self.collider.uniqueID.Player.update = tutorialMovement
end
function scenes.dreamWorld:draw()
end
------------Scene Specific Objects, yo-----------
function tutorialMovement(self,dt)
	local oldX = self.x
	self:updateMovement(dt,true)
	self.x = oldX
end