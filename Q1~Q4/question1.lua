
local STORAGEINDEX = 1000

local function releaseStorage(player)
-- adding some checking logic before invoking method on player object to secure it is not null
	if player then
        player:setStorageValue(STORAGEINDEX, -1)
    end
end

function onLogout(player)
-- same checking logic
	if player then
		if player:getStorageValue(STORAGEINDEX) == 1 then
-- function releaseStorage() must have argument input - in this case player - unless wrapper function created, which is not case here
			addEvent(releaseStorage(player), STORAGEINDEX, player)
		end
	end
	return true
end
