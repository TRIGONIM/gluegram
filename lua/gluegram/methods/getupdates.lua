-- https://core.telegram.org/bots/api#getupdates
local BOT_MT = TLG.GetObject("BOT")
local METHOD = TLG.NewMethod("getUpdates")

-- allowed_updates
-- timeout (def 0)
-- limit (max 100. def 100)

function METHOD:SetOffset(i)
	return self:SetParam("offset", i)
end

function BOT_MT:GetUpdates()
	return self:Request(METHOD) -- list of Update objects
end
