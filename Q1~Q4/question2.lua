
ffunction printSmallGuildNames(memberCount)
    -- This method is supposed to print names of all guilds that have less than memberCount max members
    local selectGuildQuery = "SELECT name FROM guilds WHERE max_members < %d;"
    local resultId = db.storeQuery(string.format(selectGuildQuery, memberCount))
	-- Since the result.getString(resultId, "name") execution will only return the first "name" from executed
	-- query response, in order to print all of them we need to do an Iteration through elements
    if resultId then
        while not result.next(resultId) do
	-- assuming that "result" is a global table of TFS and its .getString() function takes input parameters as follows
            local guildName = result.getString(resultId, "name")
            print(guildName)
        end
    end
end
