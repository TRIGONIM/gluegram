local BOT_T = TLG.GetBot("base") or TLG.Bot("base") -- не оверрайдим

function BOT_T:PushUpdate(tData)
	local UPD = TLG.SetMeta(tData,"Update")
	self:LogUpdate(UPD)
	self:OnUpdate(UPD)

	if UPD.message then
		local MSG = UPD:Message()
		self:OnMessage(MSG)

		for _,ent in ipairs(MSG.entities or {}) do
			self:_OnEntity(MSG, ent)
		end
	elseif UPD.callback_query then
		local CBQ = UPD:CallbackQuery()
		self:OnCBQ(CBQ, CBQ:Data())
	end
end

function BOT_T:Request(METH, cb_typ)
	return TLG.Request(METH):SetToken(self.token):SetCallbackType(cb_typ)
end



--[[-------------------------------------------------------------------------
	Polling
---------------------------------------------------------------------------]]
file.CreateDir("gluegram/updates")
local offsets = {} -- caching (io need timer between read/write)
local function writeOffset(id, i)
	offsets[id] = i
	if i % 10 == 0 then
		file.Write("gluegram/updates/" .. id .. ".dat",i)
	end
end

local function readOffset(id)
	offsets[id] = offsets[id] or tonumber( file.Read("gluegram/updates/" .. id .. ".dat") or nil )
	return offsets[id]
end
-- writeOffset("name", 3)
-- print( readOffset("name") )

function BOT_T:Poll(fS, fE)
	local polling_offset = readOffset(self.id) -- may be nil
	-- print("polling_offset", polling_offset)

	self:GetUpdates(polling_offset):OnSuccess(function(updList)
		if #updList ~= 0 then
			for _,UPD in ipairs(updList) do
				self:PushUpdate(UPD)
			end

			local lastUPDid = updList[#updList].update_id
			writeOffset(self.id, lastUPDid + 1)
		end

		fS(updList)
	end):OnError(function(_, descr)
		fE(descr)
	end):Send()
end

function BOT_T:StartPolling(in_loop)
	-- https://img.qweqwe.ovh/1556634444882.png
	if !in_loop and self.polling then return end
	self.polling = true

	self:Poll(function()
		if !self.polling then return end
		self:StartPolling(true) -- recursive loop
	end, function()
		if !self.polling then return end
		timer.Simple(5,function() self:StartPolling() end)
	end)
end

function BOT_T:StopPolling()
	self.polling = false
end



--[[-------------------------------------------------------------------------
	UTILS
---------------------------------------------------------------------------]]
file.CreateDir("gluegram/logs")

function BOT_T:LogUpdate(UPD)
	local dtime, json = os.date("%Y-%m-%d %H:%M:%S"), util.TableToJSON(UPD)
	file.Append("gluegram/logs/" .. self.class .. ".txt", ("[%s] %s\n"):format(dtime,json))
end


local GREEN = Color(50,200,50)
local WHITE = Color(245,245,245)
local GRAY  = Color(200,200,200)

function BOT_T:Log(msg)
	MsgC(GREEN,"[",WHITE,"TLG " .. self.class,GREEN,"] ", GRAY,msg .. "\n")
end


--[[-------------------------------------------------------------------------
	INTERNAL
---------------------------------------------------------------------------]]
-- https://img.qweqwe.ovh/1528146795923.png
function BOT_T:_OnEntity(MSG, ent)
	if ent.type == "bot_command" then
		local text = MSG.text

		local start = ent.offset + 2
		local endd = start + ent.length - 2
		local cmd = text:sub(start, endd):Split("@")[1]:lower() -- /CMD@botname > cmd

		local argss_ = text:sub(endd + 2)
		if argss_ == "" then
			argss_ = nil
		end

		-- не объект CMD и в argss_ могут быть другие команды
		self:OnCommand(MSG, cmd, argss_)
	end
end


--[[-------------------------------------------------------------------------
	OVERRIDE
---------------------------------------------------------------------------]]
-- function BOT_T:Initialize() end
function BOT_T:OnUpdate() end
function BOT_T:OnError() end
function BOT_T:OnMessage() end
function BOT_T:OnCommand() end
function BOT_T:OnCBQ() end
