-- То, что должно быть у ЛЮБОГО бота
-- К этому и применяются методы типа sendMessage
local BOT_MT = TLG.NewObjectBase("BOT")

-------------------------------------------

function BOT_MT:GetClass()
	return self.class
end

function BOT_MT:GetID()
	return self.id
end

function BOT_MT:GetToken()
	return self.token
end

-- #todo а место ли этому в MT?
-- function BOT_MT:_OnError(err) end

-- https://img.qweqwe.ovh/1528146795923.png
function BOT_MT:_OnEntity(MSG, ent)
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

function BOT_MT:PushUpdate(tData)
	local UPD = TLG.SetMeta(tData,"Update")
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



--[[-------------------------------------------------------------------------
	Polling
---------------------------------------------------------------------------]]
file.CreateDir("gluegram/updates")
local function writeOffset(name, i) file.Write("gluegram/updates/" .. name .. ".dat",i) end
local function readOffset(name) return tonumber( file.Read("gluegram/updates/" .. name .. ".dat") or nil ) end
-- writeOffset("name foo bar", 3)
-- print( readOffset("name foo bar") )

function BOT_MT:Poll(cb)
	local polling_offset = readOffset(self:GetID()) -- may be nil
	-- print("polling_offset", polling_offset)

	self:GetUpdates():SetOffset( polling_offset ):Send(function(updList)
		if cb then
			cb(updList)
		end

		-- Апдейтов нет
		if #updList == 0 then return end

		for _,UPD in ipairs(updList) do
			self:PushUpdate( TLG.SetMeta(UPD, "Update") )
		end

		local lastUPDid = updList[#updList].update_id
		writeOffset(self:GetID(), lastUPDid + 1)
	end)
end

function BOT_MT:StartPolling(delay)
	timer.Create("TLG.Polling." .. self:GetID(), delay or 5, 0, function()
		if self.busy then -- не завершился предыдущий запрос
			ErrorNoHalt("[" .. self:GetID() .. "] Some query already in process. Try to reduse polling delay\n")
			return
		end

		self.busy = true
		self:Poll(function()
			self.busy = false
		end)
	end)
end

function BOT_MT:StopPolling()
	timer.Remove("TLG.Polling." .. self:GetID())
end


--[[-------------------------------------------------------------------------
	Утилки
---------------------------------------------------------------------------]]
function BOT_MT:Request(METH, cb_typ)
	return TLG.Request(METH):SetToken( self:GetToken() ):SetCallbackType(cb_typ)
end

local GREEN = Color(50,200,50)
local WHITE = Color(245,245,245)
local GRAY  = Color(200,200,200)

function BOT_MT:Log(msg)
	MsgC(GREEN,"[",WHITE,"TLG " .. self:GetClass(),GREEN,"] ", GRAY,msg .. "\n")
end
