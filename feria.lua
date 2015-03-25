-- create the location container
feria = {}

local couch =
{
	name = "Couch",
	actions =
	{
		sit = function() return 2 end
	}
}
function items.couch()
	return 2
end

function feria.getLocation()
	return 
	{
 		name = "Feria", -- name of this location
		city = "Tokyo, Japan", -- city of this location
		room = "main", -- starting room for this location, entrace should be true for this room
		color = { 12, 213, 42, 255 }, -- background color for this location
		open = 1900, -- open time
		close = 3100, -- close time
		messages = -- messages for location events
		{
			enter = "You enter Feria. Dance music plays as a swarm of people dance in rythm under the club's lights. Everyone seems to be having a good time. Most of the people in the club seem to be foreigners.",
			exit = "You're not sure when, but you feel as if you will return to Feria before long."
		},
		rooms = 
		{
			main = 
			{ 
				name = "Main Area", -- name of this room
				fresh = true, -- have you been in this room before?
				entrance = true, -- is this room an entrance?
				exit = true, -- is this room an exit?
				forward = "bar", -- where does hitting up take you?
				back = nil, -- where does hitting down take you?
				left = "restroom", -- where does hitting left take you?
				right = nil, -- where does hitting right take you?
				items = 
				{
					"couch"
				},
				people = 
				{ 
					Becky = { age = 28, sex = 'F', opinion = 1, intel = 1, looks = 2, personality = 1 },
					Zelda =	{ age = 43, sex = 'F', opinion = 1, intel = 0, looks = 1, personality = 1 }
				}, -- a list of people in this room
				messages = -- messages for room events
				{
					enter = "The dance floor calls your name as you enter the main area of Feria."
				}
			},
			restroom = 
			{ 
				name = "Restroom", 			
				fresh = true,	
				forward = nil, 		
				back = nil, 		
				left = nil, 		
				right = "main",
				people = 
				{ 
					Yuna =	{ age = 35, sex = 'F', opinion = 1, intel = 2, looks = 0, personality = 0 }
				},			
				messages =
				{
					enter = "You open the restroom door and the stench hits you in the face."
				}
			},
			bar = 
			{ 
				name = "Drink Bar",
				fresh = true,
				forward = nil,		
				back = "main",		
				left = nil,			
				right = nil,		
				people = 
				{ 
					Amber = { age = 22, sex = 'F', opinion = 1, intel = 0, looks = 1, personality = 2 },
					Lulu =	{ age = 26, sex = 'F', opinion = 1, intel = 2, looks = 2, personality = 2 }
				},			
				messages =
				{
					enter = "You walk up to the bar, ready to order a stiff one."
				}
			}
		} -- rooms
	}
end
