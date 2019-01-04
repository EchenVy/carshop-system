---------------------------------------------
-- Carshop Sistēma---------------------------
-- Autors: Echen-----------------------------
-- Mājaslapa: http://ragemp.lv---------------
-- Skype: support_57606----------------------
-- Visas tiesības paturam © Ragemp.lv  2018--
---------------------------------------------
mysql = exports.mysql

local rc = 10
local bmx = 0
local bike = 10
local low = 20
local offroad = 30
local sport = 80
local van = 40
local bus = 75
local truck = 100
local boat = 250
local heli = 400
local plane = 550
local race = 50
vehicleTaxes = {
	offroad, low, sport, truck, low, low, 1000, truck, truck, 200, -- dumper, stretch
	low, sport, low, van, van, sport, truck, heli, van, low,
	low, low, low, van, low, 1000, low, truck, van, sport, -- hunter
	boat, bus, 1000, truck, offroad, van, low, bus, low, low, -- rhino
	van, rc, low, truck, 500, low, boat, heli, bike, 0, -- monster, tram
	van, sport, boat, boat, boat, truck, van, 10, low, van, -- caddie
	plane, bike, bike, bike, rc, rc, low, low, bike, heli,
	van, bike, boat, 20, low, low, plane, sport, low, low, -- dinghy
	sport, bmx, van, van, boat, 10, 75, heli, heli, offroad, -- baggage, dozer
	offroad, low, low, boat, low, offroad, low, heli, van, van,
	low, rc, low, low, low, offroad, sport, low, van, bmx,
	bmx, plane, plane, plane, truck, truck, low, low, low, plane,
	plane * 10, bike, bike, bike, truck, van, low, low, truck, low, -- hydra
	10, 20, offroad, low, low, low, low, 0, 0, offroad, -- forklift, tractor, 2x train
	low, sport, low, van, truck, low, low, low, rc, low,
	low, low, van, plane, van, low, 500, 500, race, race, -- 2x monster
	race, low, race, heli, rc, low, low, low, offroad, 0, -- train trailer
	0, 10, 10, offroad, 15, low, low, 3*plane, truck, low,-- train trailer, kart, mower, sweeper, at400
	low, bike, van, low, van, low, bike, race, van, low,
	0, van, 2*plane, plane, rc, boat, low, low, low, offroad, -- train trailer, andromeda
	low, truck, race, sport, low, low, low, low, low, van,
	low, low
}

function addVehicleForSale(thePlayer, cmd, price)
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		local vehID = tonumber(getElementData(theVehicle, "dbid"))
		local owner = tonumber(getElementData(theVehicle, "owner"))
		local playerID = tonumber(getElementData(thePlayer, "dbid"))
		if owner == playerID then
			if not (price) or not tonumber(price) then
				outputChatBox("SYNTAX: /"..cmd.." [Price]", thePlayer, 255, 255, 0)
			else
				local query = mysql:query_free("UPDATE vehicles SET forSale = '1', salePrice = '" .. price .. "' WHERE id = '" .. vehID .. "'")
				if query then
					setElementData(theVehicle, "forSale", 1)
					setElementData(theVehicle, "salePrice", price)
					local dim = getElementDimension(theVehicle)
					local int = getElementInterior(theVehicle)
					forSalePickup = createObject (1239, 0, 0, 0, 0, 0, 0 )
					setElementCollisionsEnabled(forSalePickup, false)
					setObjectScale(forSalePickup, 1.5)
					setElementInterior(forSalePickup, int)
					setElementDimension(forSalePickup, dim)
					attachElements ( forSalePickup, theVehicle, 0, 0, 2 )
					outputChatBox("Transports veiksmīgi pievienots pārdošanā $"..price.."!", thePlayer, 0, 255, 0)
				end
			end
		else
			outputChatBox("Tu neesi transporta īpašnieks!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("sellveh", addVehicleForSale)

function removeVehicleForSale(thePlayer)
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		local vehID = tonumber(getElementData(theVehicle, "dbid"))
		local owner = tonumber(getElementData(theVehicle, "owner"))
		local playerID = tonumber(getElementData(thePlayer, "dbid"))
		if owner == playerID then
			local query = mysql:query_free("UPDATE vehicles SET forSale = '0', salePrice = '0' WHERE id = '" .. vehID .. "'")
			if query then
				local attachedElements = getAttachedElements ( theVehicle )
				if ( attachedElements ) then
					for i, v in ipairs ( attachedElements ) do
						if ( getElementType ( v ) == "object" ) then
							destroyElement(v)
						end
					end
				end
				setElementData(theVehicle, "forSale", 0)
				setElementData(theVehicle, "salePrice", 0)
				outputChatBox("Šis transportlīdzeklis vairs nav pārdošanā", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("Tu neesi transporta īpašnieks!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("unsellveh", removeVehicleForSale)

function buyVehicleForSale(thePlayer)
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		local vehID = tonumber(getElementData(theVehicle, "dbid"))
		local owner = tonumber(getElementData(theVehicle, "owner"))
		local playerID = tonumber(getElementData(thePlayer, "dbid"))
		local price = tonumber(getElementData(theVehicle, "salePrice"))
		local sale = tonumber(getElementData(theVehicle, "forSale"))
		local brand = tonumber(getElementData(theVehicle, "brand"))
		local model = tonumber(getElementData(theVehicle, "maximemodel"))
		local year = tonumber(getElementData(theVehicle, "year"))
		local creatorAccountQuery = mysql:query_fetch_assoc("SELECT account FROM characters WHERE id = '" .. mysql:escape_string(owner) .. "'" )
		local creatorAccountID = tonumber(creatorAccountQuery["account"])
		local pickupPlayer = getPlayerName(source)
		local pickupAccountQuery = mysql:query_fetch_assoc("SELECT account FROM characters WHERE id = '" .. mysql:escape_string(playerID) .. "'" )
		local pickupAccountID = tonumber(pickupAccountQuery["account"])
		local name = tostring(exports['cache']:getCharacterName(owner))
		local newName = tostring(name):gsub(" ", "_")
		local BuyerName = getPlayerName(thePlayer)
		local newBuyerName = tostring(BuyerName):gsub(" ", "_")
		if owner == playerID then
			outputChatBox("Tu nevari iegādāties savu transportu. ((/unsellveh))!", thePlayer, 255, 0, 0)
		elseif sale == 0 then
			outputChatBox("Transportlīdzeklis nav pārdošanā.", thePlayer, 255, 0, 0)
		elseif tonumber(creatorAccountID) == tonumber(pickupAccountID) then
			outputChatBox("Tu nevari iegādāties šo transportu!", thePlayer, 255, 0, 0)
			exports.global:sendMessageToAdmins("AdmWrn: " .. newBuyerName .. " tried to alt-alt a vehicle from " .. newName .. ".")
		else
			if exports.global:hasMoney(thePlayer, price) then
				if exports.global:hasSpaceForItem(thePlayer, 3, vehicleID) then
					if exports.global:canPlayerBuyVehicle(thePlayer) then
						local query = mysql:query_free("UPDATE vehicles SET owner = '" .. mysql:escape_string(playerID) .. "' WHERE id='" .. mysql:escape_string(vehID) .. "'")
						if query then
							
							exports['anticheat-system']:changeProtectedElementDataEx(theVehicle, "owner", playerID)
							mysql:query_free("UPDATE vehicles SET forSale = '0', salePrice = '0' WHERE id = '" .. vehID .. "'")
							setElementData(theVehicle, "forSale", 0)
							setElementData(theVehicle, "salePrice", 0)
							exports.global:takeMoney(thePlayer, price)
							local attachedElements = getAttachedElements ( theVehicle )
							if ( attachedElements ) then
								for i, v in ipairs ( attachedElements ) do
									if ( getElementType ( v ) == "object" ) then
										destroyElement(v)
									end
								end
							end
							
					
							mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (".. mysql:escape_string(playerID) ..", " .. mysql:escape_string(owner) .. ", " .. price .. ", 'VEHICLE-SALES #" .. mysql:escape_string(vehID) .. " (".. mysql:escape_string(model) ..")', 6)" )
							mysql:query_free("UPDATE characters SET bankmoney=bankmoney+" ..  price .. " WHERE id=" .. mysql:escape_string(owner))
								
							outputChatBox("Tu tikko iegādājies "..getVehicleName(theVehicle).." par $"..price.."!", thePlayer, 0, 255, 0)
							outputChatBox("((Neaizmirsti uzlikt /park, savādāk transports var tikt izdzēsts!))", thePlayer, 0, 255, 0)
							call( getResourceFromName( "item-system" ), "deleteAll", 3, vehID )
							exports.global:giveItem( thePlayer, 3, vehID )
						end
					else
						outputChatBox("Tu nevari iegādāties šo transportu! Tev tie ir pārāk daudz.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("Tu nevari iegādāties šo transportu! Tev pietrūkst vieta atslēgai.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Piedod, bet tev nepietiek līdzekļu transporta iegādei!", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("buyveh", buyVehicleForSale)

function attachForSalePickup()
	for i, v in ipairs(getElementsByType("vehicle")) do
		if (getElementData(v, "forSale") == 1) then
			forSalePickup = createObject (1239, 0, 0, 0, 0, 0, 0 )
			local dim = getElementDimension(v)
			local int = getElementInterior(v)
			setElementCollisionsEnabled(forSalePickup, false)
			setObjectScale(forSalePickup, 1.5)
			setElementInterior(forSalePickup, int)
			setElementDimension(forSalePickup, dim)
			attachElements ( forSalePickup, v, 0, 0, 2 )
		end
	end
end
addEventHandler ( "onResourceStart", getRootElement(), attachForSalePickup)

function showVehForSaleInfo(theVehicle, thePlayer, carPrice, taxPrice)
	outputChatBox("", thePlayer)
	outputChatBox("Šis transportlīdzeklis ir pārdošanā!", thePlayer)
	outputChatBox(" --------------------------------------", thePlayer)
	outputChatBox("| Marka: "..getElementData(source, "brand"),  thePlayer)
	outputChatBox("| Modelis: "..getElementData(source, "maximemodel"), thePlayer)
	outputChatBox("| Gads: "..getElementData(source, "year"), thePlayer)
	outputChatBox("| Tagad pieejams par $"..exports.global:formatMoney(carPrice).."!", thePlayer )
	outputChatBox("| Nodoklis: $"..tostring(taxPrice), thePlayer )
	outputChatBox(" --------------------------------------", thePlayer)
	outputChatBox("Lieto '/buyveh' lai iegādātos šo transportu", thePlayer)
end

function showVehForSaleInfoOnEnter( thePlayer, seat, jacked )
	if (getElementData(source, "forSale") == 1) then
		local owner = tonumber(getElementData(source, "owner"))
		local playerID = tonumber(getElementData(thePlayer, "dbid"))
		local carPrice = getElementData(source, "salePrice")
		if owner == playerID then 
			return outputChatBox("Tu ievietoji pārdošanā šo transportu par $"..carPrice, thePlayer)
		else
			local taxPrice = 2*(tonumber(vehicleTaxes[getElementModel(source)-399]) or 25)
			showVehForSaleInfo(source, thePlayer, carPrice, taxPrice)
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), showVehForSaleInfoOnEnter)