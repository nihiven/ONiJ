-- globlal items
-- these items are not tied to any specific location
-- items are named i[item name]
-- an items callbacks are named [itemName].[action]
-- such as: keys.use(_data) / keys.pickup(_data)
require "classItem"


-- define your oxy
iOxy = Item:new{
	id = "iOxy",
	name = "Oxy tabs",
	desc = "oxy tabs",
}
iOxy:setImg{state="base", file="iOxy.png"}


---- define your phone
iPhone = {
	id = "iPhone",
	imgState = "base",
	imgs = {
		base = "iPhone.png"
	},
	name = "Cell Phone",
	numbers = { },
	actions = {
		use = true,
		look = true
	}
}

function iPhone.use(_data)
	if (#iPhone.numbers == 0) then
		addMessage({text = "You don't have anyone's number."})
	end
end

function iPhone.look(_data)
	addMessage({text = "It's your phone."})
end

function iPhone.img(_data)
	return iPhone.imgs[iPhone.imgState]
end


-- define your debit card
iDebit = {
	id = "iDebit",
	imgState = "base",
	imgs = {
		base = "iDebit.png"
	},
	name = "Debit Card",
	money = 1000,
	actions = { look = true }
}

function iDebit.look(_data)
	addMessage({text = "It's your debit card."})
end

function iDebit.img(_data)
	return iDebit.imgs[iDebit.imgState]
end


-- define your dollar bill
iDollar = {
	id = "iDollar",
	imgState = "base",
	imgs = {
		base = "iDollar.png",
		rolled = "iDollarRolled.png"
	},
	name = "Dollar Bill",
	rolled = false,
	beenRolled = false,
	textDesc = "a crisp dollar bill",
	actions = {
		look = true,
		roll = true,
		unroll = false
	}
}

function iDollar.look(_data)
	if (iDollar.rolled == false) then
		if (iDollar.beenRolled == false) then
			addMessage({text = "It's a crisp dollar bill."})
		else
			addMessage({text = "It's just a dollar bill."})
		end
	else
		addMessage({text = "What are you going to use a rolled up dollar bill for?"})
	end
end

function iDollar.roll(_data)
	iDollar.beenRolled = true
	iDollar.actions.roll = false
	iDollar.actions.unroll = true
	iDollar.rolled = true
	iDollar.imgState = "rolled"
	iDollar.name = "Rolled up Dollar Bill"
	iDollar.textDesc = "rolled up dollar bill"
	addMessage({text = "You roll up the crisp dollar bill."})
end

function iDollar.unroll(_data)
	iDollar.actions.roll = true
	iDollar.actions.unroll = false
	iDollar.rolled = false
	iDollar.imgState = "base"
	iDollar.name = "Dollar Bill"
	iDollar.textDesc = "crisp dollar bill"
	addMessage({text = "You unroll the crisp dollar bill."})
end

function iDollar.img(_data)
	return iDollar.imgs[iDollar.imgState]
end

-- define your wallet
iWallet = {
	id = "iWallet",
	imgState = "base",
	imgs = {
		base = "iWallet.png"
	},
	name = "Leather Wallet",
	contents = { iDebit, iDollar },
	actions = {
		look = true,
		open = true
	}
}

function iWallet.open(_data)
	if (#iWallet.contents == 0) then
		addMessage({text = "Your wallet is empty."})
	else
		addMessage({text = "There's a debit card and a crisp dollar bill in here."})

		addToInventory(iWallet.contents[2])
		table.remove(iWallet.contents, 2)

		addToInventory(iWallet.contents[1])
		table.remove(iWallet.contents, 1)

	end
end

function iWallet.look(_data)
	addMessage({text = "It's your wallet. It's made of the finest leather."})
end

function iWallet.update(_data)
	if (#iWallet.contents == 0) then
		iWallet.actions.open = false
	else
		iWallet.actions.open = true
	end
end

function iWallet.img(_data)
		return iWallet.imgs[iWallet.imgState]
end

-- define your keys
iKeys = {
	id = "iKeys",
	imgState = "base",
	imgs = {
		base = "iKeys.png"
	},
	name = "Car Keys",
	actions = { look = true }
}

function iKeys.look(_data)
	addMessage({text = "These are your keys."})
end

function iKeys.img(_data)
		return iKeys.imgs[iKeys.imgState]
end


------- test items
iCigs = {
	id = "iCigs",
	imgState = "base",
	imgs = {
		base = "iCigs.png"
	},
	name = "Cigarettes",
	actions = { look = true }
}
function iCigs.look(_data)
	addMessage({text = "These are your cigarettes."})
end

function iCigs.img(_data)
		return iCigs.imgs[iCigs.imgState]
end


-- your drugs
iMolly = {
	id = "iMolly",
	imgState = "base",
	imgs = {
		base = "iMolly.png"
	},
	name = "Molly",
	actions = {
		look = true,
		crush = true
	}
}
function iMolly.look(_data)
	addMessage({text = "It's some good stuff."})
end

function iMolly.crush(_data)
	addMessage({text= "You don't have anything to hold the powder."})
end

function iMolly.img(_data)
		return iMolly.imgs[iMolly.imgState]
end


-- your cash roll
iCash = {
	id = "iCash",
	imgState = "base",
	imgs = {
		base = "iCash.png"
	},
	name = "Cash",
	money = 60,
	actions = { look = true }
}
function iCash.look(_data)
	addMessage({text = "Looks like $60."})
end

function iCash.img(_data)
		return iCash.imgs[iCash.imgState]
end


-- your valet ticket
iValetTicket = {
	id = "iValetTicket",
	imgState = "base",
	imgs = {
		base = "iValetTicket.png"
	},
	name = "Valet Ticket",
	actions = { look = true }
}
function iValetTicket.look(_data)
	addMessage({text = "It's your valet ticket."})
end

function iValetTicket.img(_data)
		return iValetTicket.imgs[iValetTicket.imgState]
end


-- master item list
item_list = {
-- iPhone,
--	iWallet,
--	iKeys,
--	iCigs,
--	iMolly,
--	iCash,
--	iValetTicket,
	iOxy,
}

-- add your phone to the item list, you posess it
