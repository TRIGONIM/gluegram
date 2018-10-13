-- https://core.telegram.org/bots/api#getme
local BOT_MT = TLG.GetObject("BOT")
local METHOD = TLG.NewMethod("getMe")

function BOT_MT:GetMe(cb)
	self:Request(METHOD, "User"):Send(cb)
end

-- TLG_CORE_BOT:GetMe(prt)
