--[[ It's ONiJ ]]--

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
locations.feria = feria.getLocation()


--[[ ------------------------- UI Variables ------------------------- ]]--
ui = { }

-- messages
ui.msg =
{
	sys = 
	{
		padX = 10,
		padY = 10,
		width = love.graphics.getWidth() - (10 * 2),
		color = colorsRGB.red
	},
	event = 
	{
		color = colorsRGB.white
	}
}

-- room
ui.room = 
{
	padTop = 30,
	padBottom = 240,
	movesX = 80,
	color = colorsRGB.slategrey
}

-- inventory
ui.inv = 
{
	show = false,
	selected = 1,
	x = 600,
	y = 10,
	color = colorsRGB.yellow,
	colorSelected = colorsRGB.red
}

-- people
peopleSelected = 1

messagesColorPeople = colorsRGB.pink

--[[ ------------------------- Verbs ------------------------- ]]--
--[[ 
	Push	Open	 Talk to
 	Pull	Close	 Pick Up
 	Give	Look at  Use        
	]]--
-- this controls how the verb grid is built
-- we'll build the grid in buildlVerbGrid() and store it in the ui table
ui.verb = 
{ 
	width = 100, -- width per block
	height = 60, -- height per block
	color = colorsRGB.white,
	selected = nil, -- selected verb
	selectedX = nil, -- x coord of selected verb
	selectedY = nil, -- y coord of selected verb
	selectedColor = colorsRGB.lime,
	grid = { } -- contains the grid built by buildVerbGrid()
}
verbs = 
{ 
	{
		{ verb = "push", text = "Push" }, 
		{ verb = "open", text = "Open"}, 
		{ verb = "talk", text = "Talk to"}
	},
		{
		{ verb = "pull", text = "Pull"},
		{ verb = "close", text = "Close"},
		{ verb = "pickup", text = "Pick Up"}
	},
	{
		{ verb = "give", text = "Give"},
		{ verb = "look", text = "Look at"},
		{ verb = "use", text = "Use"} -- 'use with' is contextual?
	}
}


--[[ ------------------------- Love Callbacks ------------------------- ]]--
function love.draw()
	drawVerbs()
	printRoomInfo() -- room info
  	printPeople() -- print people around you
	printMessages() -- message queue
	printInventory() -- show inventory

end

-- called on startup
function love.load()
	loadConfig()

	-- set ui variables for the screen
	ui.scr = 
	{
		width = love.graphics.getWidth(),
		midX = love.graphics.getWidth() / 2,
		height = love.graphics.getHeight(),
		midY = love.graphics.getHeight() / 2
	}

	-- build the data for the verb grid
	buildVerbGrid()

	-- load intial messages
	-- defined in reverse because earlier messages reference later ones
	local intro3 = { text = "One Night in Japan",			age = 36, callback = { func = "setLocation",	data = "feria" } }
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
		ui.inv.show = not ui.inv.show
	elseif key == "q" or key == "a" then
		navigatePeople(key)
	elseif key == "w" or key == "s" then
		navigateRoomItems(key)
	elseif key == "e" or key == "d" then
		navigateInventory(key)
	elseif key == "l" or key == "u" or key == "o" then
		actionItem(key)
	end
end


--[[ ------------------------- My Functions ------------------------- ]]--
function loadConfig()
	ui.font = love.graphics.setNewFont("Neon.ttf", 18)	
end


--[[ ------------------------- Message Related ------------------------- ]]--
-- print and age the first message in the queue
-- once age is 0, the message is removed
function printMessages()
	if (#messages == 0) then return end

	local m = messages[1]

	_pf(m.text, ui.msg.sys.padX, ui.msg.sys.padY - 5, ui.msg.sys.width, "left", ui.msg.sys.color, false)

	if (m.age <= 0) then
		if (m.callback ~= nil) then
			-- if the message has a callback, execute it
			runCallback(m.callback.func, m.callback.data)
		end

		table.remove(messages, 1) -- message has aged out, remove it
	else
	    messages[1].age = m.age - 1
	end

end

-- add the passed message to the message queue
function addMessage(_data)
	if (_data.age == nil) then
		_data.age = 120
	end

	table.insert(messages, _data)
end


--[[ ------------------------- Room Related ------------------------- ]]--
-- print info about the current room
function printRoomInfo()
	if (location == nil) then return end

	-- we'll put all of the room related printing/drawing stuff here for now
	-- draw the room background
	_sc(ui.room.color)
	 love.graphics.rectangle("fill", 0, ui.room.padTop, ui.scr.width, ui.scr.height - ui.room.padBottom)

	local r = getRoom()
	local rs = getRooms()

	_pf(r.name, 0, ui.room.padTop, ui.scr.width, "center", ui.msg.event.color, true)

	-- print movement options
	local m = {}
	if (r.forward ~= nil) then table.insert(m, "Up: " .. rs[r.forward].name) end 
	if (r.back ~= nil) then table.insert(m, "Down: " .. rs[r.back].name) end 
	if (r.left ~= nil) then table.insert(m, "Left: " .. rs[r.left].name) end 
	if (r.right ~= nil) then table.insert(m, "Right: " .. rs[r.right].name) end 
	
	for i = #m,1,-1 do
		_pf(m[i],0,ui.room.movesX+i*20, ui.scr.width, "center", ui.msg.event.color, true)
	end
end


-- this moves us from room to room
function processMovement(_key)
	local r = getRoom()
	local n = nil

	if _key == "up" then
		if (r.forward ~= nil) 	then n = r.forward end 
	elseif _key == "down" then 
		if (r.back ~= nil) 		then n = r.back end 
	elseif _key == "left" then 
		if (r.left ~= nil) 		then n = r.left end
	elseif _key == "right" then
		if (r.right ~= nil) 	then n = r.right end
	end

	if (n ~= nil) then enterRoom(n) end
end

-- called when the player enters a room
function enterRoom(_room)
	locations[location].room = _room --set global variable
	local r = getRoom()

	-- if this is the players first time in the room, show the intro text
	if (r["fresh"] == true) then
		addMessage({ text = r.messages.enter })
		locations[location].rooms[_room].fresh = false
	end
end

function setLocation(_location)
	location = _location
	addMessage({ text = locations[location].messages.enter })
	enterRoom(locations[location].room)
end


--[[ ------------------------- Item Related ------------------------- ]]--
function printInventory()

	if (ui.inv.show == true) then
		_p("Inventory", ui.inv.x - 10, ui.inv.y, ui.inv.color, true)

		-- submenu y axis offset
		local i = 0

		-- loop through all items in your inventory
		for key,value in pairs(items) do
			if (key == ui.inv.selected) then

				-- if this is the selected item use a special color
				_p(": " .. value.name, ui.inv.x, ui.inv.y + (key * 20), ui.inv.colorSelected, true)

				-- intit y axis offset
				i = 0
				-- list actions for this item
				for action,available in pairs(value.actions) do
					if (available == true) then
						_p(" : " .. action, ui.inv.x, ui.inv.y + (key * 20) + (i * 20) + 20, ui.inv.colorSelected, true)
						i = i+1
					end
				end
			else
				-- this item isn't select, use the normal color
				_p(": " .. value.name, ui.inv.x, ui.inv.y + (key * 20) + (i * 20), ui.inv.color, true)
			end
			
		end
	else
		_p("Inventory" .. " (" .. #items .. ")", ui.inv.x - 10, ui.inv.y, ui.inv.color, true)
	end
end

-- change selected item in your inventory
function navigateInventory(_key)
	if (ui.inv.show == true) then
		if (_key == "e") then
			ui.inv.selected = ui.inv.selected - 1
			if (ui.inv.selected == 0) then ui.inv.selected = #items end
			ui.verb.selected = ""
		end
		if (_key == "d") then
			ui.inv.selected = ui.inv.selected + 1
			if (ui.inv.selected > #items) then ui.inv.selected = 1 end
		end
	end
end

function addToInventory(_item)
	addMessage({text = "Added " .. _item.name .. " to your inventory."})
	table.insert(items, _item)
end

-- perform given action on currently selected item in your inventory
function actionItem(_key)
	local item = items[ui.inv.selected] -- reference to the selected item instance
	local action = actionMapping(_key) -- action to be used for the item callback

	if (action ~= nil) then
		item[action]()	-- execute the [item].[action] function
		-- the line above shows how to execute a variable that stores a function
		-- in this case item resolves to an item object like iPhone and
		-- action resolves to function of iPhone, like use
		-- this ends up being iPhone[use]() which is the same as calling iPhone.use()

		-- some functions require updates after processing an action
		if (item.update ~= nil) then
			item.update()
		end
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


--[[ ------------------------- People Related ------------------------- ]]--
-- list the people in the current room
function printPeople()
	if (location == nil) then return end
	
	local p = getPeople()
	if (p == nil) then return end

	_p("People", 10, ui.room.padTop, messagesColorPeople, true)

	for key,person in pairs(p) do
		_p(" : " .. person.name .. " (" .. person.age .. ")", 10, ui.room.padTop + (key * 20), messagesColorPeople, true)
	end
end


--[[ ------------------------- UI Related ------------------------- ]]--
function buildVerbGrid()
	-- build verb grid for use later and store some helper variables for click detection

	for i = 1,#verbs,1 do -- build one row at a time
		local r = { }

		for j = 1,#verbs[i],1 do -- column
			r[j] = 
			{
				verb = verbs[j][i].verb,
				text = verbs[j][i].text,
				x = (j-1) * ui.verb.width,
				y = (i-1) * ui.verb.height + (ui.room.padTop + ui.scr.height - ui.room.padBottom)
			}
		end

		-- add row to table
		ui.verb.grid[i] = r
	end

end

-- draw the stored grid, adjust colors for context
function drawVerbs(_item)
	for i,row in pairs(ui.verb.grid) do
		for j,col in pairs(row) do
 			
 			--- required to center verb vertically
			local cy = col.y - (ui.font:getHeight() / 2) + (ui.verb.height / 2)
			local color = ui.verb.color

			-- change color if the verb is highlighted
			if (j == ui.verb.selectedX and i == ui.verb.selectedY) then
				color = ui.verb.selectedColor
			end

			--love.graphics.rectangle('line', col.x, col.y, ui.verb.width, ui.verb.height)
			_pf(col.text, col.x, cy, ui.verb.width, "center", color, true) -- draw verb

			-- this could be draw verbs and related items
			-- draw verb sentence here..............
			-- Use flashlight
		end
	end
end

-- putting this here for now, will move out once UI is sorted
function love.mousepressed(x, y, button)
	local cy = y - (ui.room.padTop + ui.scr.height - ui.room.padBottom)
	local gridX = math.floor(x / ui.verb.width) + 1
	local gridY = math.floor(cy / ui.verb.height) + 1

	if (gridX >= 1 and gridX <= 3) and (gridY >= 1 and gridY <= 3) then
		ui.verb.selectedX = gridX
		ui.verb.selectedY = gridY
		ui.verb.selected = verbs[gridX][gridY].verb
	end
end

------------- HELPERS
function _p(_text, _x, _y, _color, _shadow)
	if (_shadow == true) then 
		_sc(colorsRGB.darkshadow)
		love.graphics.print(_text, _x+1, _y+1)
	end

	_sc(_color)
	love.graphics.print(_text, _x, _y)
end

function _pf(_text, _x, _y, _w, _align, _color, _shadow)
	if (_shadow == true) then 
		_sc(colorsRGB.darkshadow)
		love.graphics.printf(_text, _x+1, _y+1, _w, _align)
	end

	_sc(_color)
	love.graphics.printf(_text, _x, _y, _w, _align)
end

function _sc(_color)
	love.graphics.setColor(_color)
end


-------------------------------------------------------------------------------------
--- please get rid of the need for all of these
--- if we NEED all of these then the data structure is 'JENK'
function getLocation()
	return locations[location]
end

function getRooms()
	return locations[location].rooms
end

function getRoom()
	return locations[location].rooms[locations[location].room]
end

function getPeople()
	return locations[location].rooms[locations[location].room].people
end

-- executes text as a function
function runCallback(_func, _data)
	_G[_func](_data)
end
