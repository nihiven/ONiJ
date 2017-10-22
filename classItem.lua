-- Item Class
Item = {
	id = false,
	imgs = {
		base = "iItem.png",
	},
	name = false,
	state = "base",
	desc = false,
	actions = {
		{
			func = look,
			key = "l",
			text = "Look",
			display = true,
		}
	},
}

function Item:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Item:img()
	return self.imgs[self.state]
end

function Item:setImg(_args)
	self.imgs[_args.state] = _args.file
	return true
end

function Item:look()
	addMessage({text = string.format("It's %s.", self.desc)})
	return true
end

function Item:setState(_args)
	if (self.imgs[_args.state] ~= nil) then
		self.state = _args.state
		return true
	end

	return false
end


function Item:setAction(_action, _key, _text)
	action = {
		func = _action,
		key = _key,
		text = _text,
	}

	self.actions[_action] = action
	return true
end

function Item:action(_action)
	if (self.actions[_action] ~= nil) then
		return self.actions[_action]
	end

	return false
end

function Item:imgList()
	files = { }
	for key,file in pairs(self.imgs) do
		table.insert(files, file)
	end

	return files
end
