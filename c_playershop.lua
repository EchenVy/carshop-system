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
--addEventHandler ( "onClientRender", getRootElement(), attachForSalePickup)