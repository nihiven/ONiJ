-- globlal items
-- these items are not tied to any specific location
-- items are named i[item name]
-- an items callbacks are named [itemName].[action]
-- such as: keys_use(_data) / keys_pickup(_data)

---- define your phone
iPhone = 
{
	id = "iPhone",
	img = "iPhone.png",
	name = "Cell Phone",
	numbers = { },
	actions = { use = true, look = true }
}

function iPhone.use(_data)
	if (#iPhone.numbers == 0) then
		addMessage({text = "You don't have anyone's number."})
	end
end

function iPhone.look(_data)
	addMessage({text = "It's your phone."})
end

-- define your debit card
iDebit = 
{
	id = "iDebit",
	img = "iDebit.png",
	name = "Debit Card",
	money = 1000,
	actions = { look = true }
}

function iDebit.look(_data)
	addMessage({text = "It's your debit card."})
end


-- define your wallet
iWallet = 
{	
	id = "iWallet",
	img = "iWallet.png",
	name = "Leather Wallet",
	contents = { iDebit },
	actions = { look = true, open = true }
}

function iWallet.open(_data)
	if (#iWallet.contents == 0) then
		addMessage({text = "Your wallet is empty."})
	else
		addMessage({text = "There's a debit card in here."})
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


-- define your keys
iKeys = 
{
	id = "iKeys",
	img = "iKeys.png",
	name = "Car Keys",
	actions = { look = true }
}

function iKeys.look(_data)
	addMessage({text = "These are your keys."})
end


-- master item list
item_list = 
{ 
	iPhone,
	iWallet,
	iKeys
}

-- add your phone to the item list, you posess it
