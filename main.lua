--[[
	It's ONiJ

	-- verbs: look, use, give
]]--

--[[ ------------------------- Collection Variables ------------------------- ]]--
-- constants
messages = {} -- the message queue
chats = {} -- the chat queue
actions = {} -- actions available to you
items = {} -- items you are carrying
locations = {} -- all of the places you can go
location = nil -- you current location


--[[ ------------------------- Libraries ------------------------- ]]--
-- support libraries
require "colors"

-- load global items
require "items"
items = item_list

-- load the different locations
require "feria"
locations["feria"] = feria.getLocation()


--[[ ------------------------- UI Variables ------------------------- ]]--
-- inventory
inventoryShow = false
items_selected = 1
inventoryX = 600
inventoryY = 10
inventoryNormal = colorsRGB["white"]
inventorySelected = colorsRGB["red"]

-- messages
messageSysColor = colorsRGB["red"]
messagesRoomColor = colorsRGB["white"]
messagesPeopleColor = colorsRGB["lime"]


--[[ ------------------------- Love Callbacks ------------------------- ]]--
function love.draw()

	printRoomInfo() -- room info
    printPeople() -- print people around you
	printMessages() -- message queue
	printInventory() -- show inventory

end

-- called on startup
function love.load()
	loadConfig()

	-- set reference variables
	screenX = love.graphics.getWidth()
	screenMidX = screenX / 2
	screenY = love.graphics.getHeight()
	screenMidY = screenY / 2

	-- load intial messages
	-- defined in reverse because earlier messages reference later ones
	local intro3 = { text = "Let's dance...",				age = 12, callback = { func = "setLocation",	data = "feria" } }
	local intro2 = { text = "You can do anything.",			age = 12, callback = { func = "addMessage",		data = intro3 } }
	local intro1 = { text = "You have one night in Japan.",	age = 12, callback = { func = "addMessage",		data = intro2 } }
	
	addMessage(intro1)
end

-- called continusously
function love.update(dt)  -- dt is delta time
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "up" or key == "down" or key == "left" or key == "right" then
		processMovement(key)
	elseif key == "backspace" then
		inventoryShow = not inventoryShow
	elseif key == "w" or key == "s" then
		navigateInventory(key)
	elseif key == "l" or key == "u" or key == "o" then
		actionItem(key)
	end
end


--[[ 
	------------------------- My Functions
]]--
function loadConfig()
	love.graphics.setNewFont("Neon.ttf", 18)
end


------------------------- message related functions
-- print and age the first message in the queue
-- once age is 0, the message is removed
function printMessages()
	if (#messages == 0) then return end

	local m = messages[1]
	love.graphics.setColor(messageSysColor)
	--love.graphics.printf(m["text"] .. " (" .. m["age"] .. ")", 25, 540, 580, "left")
	love.graphics.printf(m["text"], 20, (love.graphics.getHeight()-120), 600, "left")

	if (m["age"] <= 0) then

		-- if the message has a callback, execute it
		if (m["callback"] ~= nil) then
			runCallback(m["callback"]["func"], m["callback"]["data"])
		end

		table.remove(messages, 1)
	else
	    messages[1]["age"] = m["age"] - 1
	end

end

-- add the passed message to the message queue
function addMessage(_data)
	if (_data["age"] == nil) then
		_data["age"] = 120
	end

	table.insert(messages, _data)
end


-------------------------  room related functions
-- print info about the current room
function printRoomInfo()
	if (location == nil) then return end

	local r = getRoom()
	local rs = getRooms()

	love.graphics.setColor(messagesRoomColor)
	love.graphics.print("Room: " .. r["name"], 10, 10)

	love.graphics.setColor(messagesRoomColor)
	-- print movement options
	local m = {}
	if (r["forward"] ~= nil) then table.insert(m,"Up: " .. rs[r["forward"]]["name"]) end 
	if (r["back"] ~= nil) then table.insert(m,"Down: " .. rs[r["back"]]["name"]) end 
	if (r["left"] ~= nil) then table.insert(m,"Left: " .. rs[r["left"]]["name"]) end 
	if (r["right"] ~= nil) then table.insert(m,"Right: " .. rs[r["right"]]["name"]) end 
	
	for i = #m,1,-1 do
		love.graphics.print(m[i],10,i*20+30)
	end
end

-- list the people in the current room
function printPeople()
	if (location == nil) then return end
	
	local p = getPeople()
	if (p == nil) then return end

	love.graphics.setColor(messagesPeopleColor)
	love.graphics.print("People", 10, 110)

	local i = 1
	for key,value in pairs(p) do
		love.graphics.print(": " .. key .. " (" .. value["age"] .. ")", 10, (110 + (i * 20)))
		i = i + 1
	end
end

-- this moves us from room to room
function processMovement(_key)
	local r = getRoom()
	local n = nil
	if _key == "up" then
		if (r["forward"] ~= nil) then n = r["forward"] end 
	elseif _key == "down" then 
		if (r["back"] ~= nil) then n = r["back"] end 
	elseif _key == "left" then 
		if (r["left"] ~= nil) then n = r["left"] end
	elseif _key == "right" then
		if (r["right"] ~= nil) then n = r["right"] end
	else
		return
	end

	if (n ~= nil) then enterRoom(n) end
end

-- called when the player enters a room
function enterRoom(_room)
	locations[location]["room"] = _room --set global variable
	local r = getRoom()

	-- if this is the players first time in the room, show the intro text
	if (r["fresh"] == true) then
		addMessage({ text = r["messages"]["enter"] })
		locations[location]["rooms"][_room]["fresh"] = false
	end
end

function setLocation(_location)
	location = _location
	addMessage({ text = locations[location]["messages"]["enter"] })
	enterRoom(locations[location]["room"])
end

-------------------------  item related functions
function printInventory()
	love.graphics.setColor(inventoryNormal)

	if (inventoryShow == true) then
		love.graphics.print("Inventory", inventoryX - 10, inventoryY)

		-- submenu y axis offset
		local i = 0

		-- loop through all items in your inventory
		for key,value in pairs(items) do
			if (key == items_selected) then

				-- if this is the selected item use a special color
				love.graphics.setColor(inventorySelected)
				love.graphics.print(": " .. value["name"], inventoryX, inventoryY + (key * 20))

				-- intit y axis offset
				i = 0
				-- list actions for this item
				for action,available in pairs(value['actions']) do
					if (available == true) then
						love.graphics.print(" : " .. action, inventoryX, inventoryY + (key * 20) + (i * 20) + 20)
						i = i+1
					end
				end
			else
				-- this item isn't select, use the normal color
				love.graphics.setColor(inventoryNormal)
				love.graphics.print(": " .. value["name"], inventoryX, inventoryY + (key * 20) + (i * 20))
			end
			
		end
	else
		love.graphics.print("Inventory" .. " (" .. #items .. ")", inventoryX - 10, inventoryY)
	end
end

-- change selected item in your inventory
function navigateInventory(_key)
	if (inventoryShow == true) then
		if (_key == "w") then
			items_selected = items_selected - 1
			if (items_selected == 0) then items_selected = #items end
		end
		if (_key == "s") then
			items_selected = items_selected + 1
			if (items_selected > #items) then items_selected = 1 end
		end
	end
end

function addToInventory(_item)
	addMessage({text = "Added " .. _item["name"] .. " to your inventory."})
	table.insert(items, _item)
end

-- perform given action on currently selected item in your inventory
function actionItem(_key)
	local item = items[items_selected] -- reference to the selected item instance
	local action = actionMapping(_key) -- action to be used for the item callback

	if (action ~= nil) then
		item[action]()	-- execute the [item].[action] function
	end
end

-- future key mapping?
function actionMapping(_key)
	local r
	if (_key == "u") then
		r = "use"
	elseif (_key == "l") then
		r = "look"
	elseif (_key == "o") then
		r = "open"
	else
		r = nil
	end

	return r
end


------------- HELPERS

--- please get rid of the need for all of these
--- if we need all of these then the data structure is junko
function getLocation()
	return locations[location]
end

function getRooms()
	return locations[location]["rooms"]
end

function getRoom()
	return locations[location]["rooms"][locations[location]["room"]]
end

function getPeople()
	return locations[location]["rooms"][locations[location]["room"]]["people"]
end

-- executes text as a function
function runCallback(_func, _data)
	_G[_func](_data)
end
