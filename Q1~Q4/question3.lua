
function remove_member_of_membername_from_PlayerParty(playerId, membername)
-- makingplayer loca to void memory leak
	local player = Player(playerId)
-- assigning Player that we need to find to a variable to avoid redundant constructor invocations
	local playerToRemove = Player(membername)
-- chacking if player and playerToRemove not equal to nil to avoid crashes
	if player and playerToRemove then
		local party = player:getParty()
-- checking if party present and not equals nil
		if party then
			for k,v in pairs(party:getMembers()) do
				if v == playerToRemove then
					party:removeMember(playerToRemove)
-- adding break to optimize speed assuming there can not be several players that equal one and the same object
					break
				end
			end
		end
	end
end
