-- Yo, yo, this is 32log by ishkabible, modified by Borg, modified again for this project, yo
-- It has some stuff added in it because, yo
-- You can call it 32logPlusABitMoreThanABakersDozenAndCommentary, yo
-- ..or not, yo, i'm not the name police, mann...yo
-- REMEMBER, to call a super method with N arguments use "<variable>:super('<method name>',<arg1>,<arg2>,...,<argN>)", yo
-- thanks, yo.
function class(name)
  local newclass={}
  _G[name]=newclass
  newclass.name = name
  newclass.__members={}
  function newclass.define(class,members)
	for k,v in pairs(members) do
      class.__members[k]=v
    end
  end
  function newclass.extends(class,base)
    class._super=base
	for k,v in pairs(base.__members) do
      class.__members[k]=v
    end
    return setmetatable(class,{__index=base,__call=class.define})
  end
  function newclass.new(class,...)
    local object={}
    for k,v in pairs(class.__members) do
      object[k]=v
    end
    setmetatable(object,{__index=class})
    if object.init then
      object:init(...)
    end
    return object
  end
  function newclass:instanceOf(class)
  	local super = _G[self.name]
	while super ~= nil do
		if super == class then
			return true
		end
		super = super._super
	end
	return false
  end
  function newclass:super(func,...)
	local super = self._super
	self._super = self._super._super
	super[func](self,...)
	self._super = super
  end
  return setmetatable(newclass,{__call=newclass.define})
end