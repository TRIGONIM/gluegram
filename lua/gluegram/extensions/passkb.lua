local BOT = BOTMOD
if !BOT then return end -- refresh

BOT.PK = BOT.PK or { -- password keyboard
	MAP = {}
}

local function buildKeyboard()
	local IKB = TLG.InlineKeyboard()
	IKB:Line(
		IKB:Button("1"):SetData({1,pkb = 1}),
		IKB:Button("2"):SetData({2,pkb = 1}),
		IKB:Button("3"):SetData({3,pkb = 1})
	)
	IKB:Line(
		IKB:Button("4"):SetData({4,pkb = 1}),
		IKB:Button("5"):SetData({5,pkb = 1}),
		IKB:Button("6"):SetData({6,pkb = 1})
	)
	IKB:Line(
		IKB:Button("7"):SetData({7,pkb = 1}),
		IKB:Button("8"):SetData({8,pkb = 1}),
		IKB:Button("9"):SetData({9,pkb = 1})
	)
	IKB:Line(
		IKB:Button("❌"):SetData({cmd = 1,pkb = 1}),
		IKB:Button("0") :SetData({0,pkb = 1}),
		IKB:Button("✅"):SetData({cmd = 2,pkb = 1})
	)

	return IKB
end

function BOT:SendPasswordKeyboard(cb, chat_id, password)
	-- if self.PK.MAP[chat_id] then
	-- 	self:Message(chat_id, "В этом чате уже есть клавиатура")
	-- 	return
	-- end

	self.PK.MAP[chat_id] = {password, 0, cb} -- [2] = current_typed_pass

	local IKB = buildKeyboard()

	self:Message(chat_id, "Enter password")
		:SetReplyMarkup(IKB)
		:Send()
end

local function count_digits(i)
	return math.Truncate( math.log10(i) ) + 1
end

BOT:HandleCBQ(function(CBQ)
	local dat = CBQ:Data() -- [1] = 0-9, cmd = 1/2
	if !dat.pkb then return end

	local MSG = CBQ:Message()
	local chat_id = MSG:Chat():ID()


	local KB = BOT.PK.MAP[chat_id]
	if !KB then
		-- сервер перезагрузился и кто-то трогает старую клаву
		BOT:Message(chat_id, "This keyboard was removed"):ReplyTo(MSG:ID()):Send()
		return
	end

	local digit,cmd = dat[1],dat.cmd

	-- number
	if digit then
		KB[2] = KB[2] * 10 + digit -- current

	-- reset
	elseif cmd == 1 then
		KB[2] = 0 -- current

	-- check
	elseif cmd == 2 then
		local ok = KB[1] == KB[2]
		KB[3](ok) -- cb
		BOT.PK.MAP[chat_id] = nil
		BOT:EditMessage(MSG, ok and "Success!" or "Access denied!"):Send()

		return
	end

	local IKB = buildKeyboard()
	BOT:EditMessage(MSG, KB[2] == 0 and "Enter password" or string.rep("⏺", count_digits(KB[2])))
		:SetReplyMarkup(IKB)
		:Send()
end, "password_keyboard_" .. BOT:Name())


-- BOT:SendPasswordKeyboard(function(ok)
-- 	print(ok and "success!!11" or "error!1")
-- end, TLG_AMD, 1337)
