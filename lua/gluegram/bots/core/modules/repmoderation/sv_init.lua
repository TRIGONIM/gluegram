-- if !KOSSON then return end

local BOT = TLG_CORE_BOT


--[[-------------------------------------------------------------------------
	TODO Вынести в отдельное место, а то я просто охуел

local IKB = TLG.InlineKeyboard()
IKB:Line( IKB:Button("Кнопка"):SetCallBackData({
	key = "value",
}) )

local msg = BOT:Message(MSG:Chat(), "Кнопочки"):SetReplyMarkup(IKB)

TLG.SendAndHandleCBQ(BOT,msg,function(CBQ)
	local dat = CBQ:Data()
end)
---------------------------------------------------------------------------]]
BOT.CBQHandlers = BOT.CBQHandlers or {}
function TLG.SendAndHandleCBQ(bot,msg,fCallback)
	msg:Send(function(res)
		BOT.CBQHandlers[res:ID()] = fCallback
	end)
end

BOT:HandleCBQ(function(CBQ)
	if BOT.CBQHandlers[ CBQ.message.message_id ] then
		BOT.CBQHandlers[ CBQ.message.message_id ](CBQ)
	end
end,"SendAndHandleCBQ")



local K,B = "0123456789ABCDEF",16
local function DEC_HEX(n)
	n = tonumber(n)
	local s,D = ""

	local i = 0
	while n > 0 do
		i   = i + 1
		n,D = math.floor(n / B), n % B + 1
		s   = K[D] .. s
	end

	return s
end

-- tonumber("num",16) с большими числами почему-то работает некорректно
local function HEX_DEC(hex)
	return tonumber("0x" .. hex)
end

local function CompressSID(sid) -- STEAM_0:1:55598730 > 0155598730 > 5155598730 > 25D52238A
	return DEC_HEX( "1" .. string.Implode("",{sid:match("^STEAM_(%d):(%d):(%d+)$")}) )
end --               /\ чтобы спереди не было 0. Можно и без приставки, но это не удлиняет HEX SteamID

local function NormalizeSID(sid) -- наоборот
	sid = tostring(HEX_DEC(sid)):sub(2) -- двойная конвертация строка-число-строка... и срез первой цифры
	return "STEAM_" .. sid[1] .. ":" .. sid[2] .. ":" .. sid:sub(3)
end




local function nickSid(sid)
	local pl = player.GetBySteamID(sid)
	return !pl and sid or ("(%s)%s"):format(sid,pl:Nick())
end

local msg = [[
	🎨 Изменение репутации (%s)
	Он: %s
	Ему: %s

	🏷 %s
	✉ %s
]]

local om_msg = "Администратор @%s отреагировал на событие изменения вашей репутации и удалил ее.\n\nСообщение события:\n%s"

local function repRem(CBQ, id, author_sid, target_sid)
	REP.RemAction(id,author_sid,true,function(ok)
		local login = CBQ:From():Login()

		local IKB = TLG.InlineKeyboard()
		IKB:Line(
			IKB:Button("Бан 15m"):SetCallBackData({
				ban = 15,
				sFr = CompressSID(author_sid),
				s   = SERVERS:ID()
			}),
			IKB:Button("Бан 60m"):SetCallBackData({
				ban = 60,
				sFr = CompressSID(author_sid),
				s   = SERVERS:ID()
			})
		)

		BOT:EditMessage(CBQ:Message(),"\n\n• Репа " .. (ok and "удалена" or "УЖЕ удалена") .. ". Мод: @" .. login,true)
			:SetReplyMarkup(IKB)
			:Send()

		if !ok then return end

		OM.SendMessage(util.SteamIDTo64(target_sid),
			om_msg:format(login, string.Safe( CBQ:Message()["text"] ..
				"\n\n======================" ..
				"\nМы получаем сообщение с репутацией в наш Telegram бот (https://img.qweqwe.ovh/1504522587957.png) и удаляем ее," ..
				" если в ней не описана ситуация, на основании которой выдана репутация," ..
				" чтобы репутация действительно имела большую ценность"
			)),

			"Удаление репутации"
		)
	end)
end


hook.Add("OnRepAdd","TLG",function(sFrom,for_sid,iCategory,message,id)
	local IKB = TLG.InlineKeyboard()
	IKB:Line(
		IKB:Button("Удалить"):SetCallBackData({ --------------- если потребуется сильнее сжать данные, то можно попробовать не передавать Sid автора репы, а получать его позже
			rem = id,
			sFr = CompressSID(sFrom), -- sidFrom
			sTo = CompressSID(for_sid), -- sidTo
			s   = SERVERS:ID()
		})
	)


	BOT:Message(TLG_CONF_MOD, msg:format(
		id,
		nickSid(sFrom),
		nickSid(for_sid),
		REP.getCatNameByID(iCategory),
		message
	)):SetReplyMarkup(IKB):Send()

end)


BOT:HandleCBQ(function(CBQ)
	local dat = CBQ:Data()

	-- Баны выдаем только на сервере, на котором выдана репа
	-- Запрещаем банить ну других серверах
	if dat.ban and dat.s == SERVERS:ID() then
		RunConsoleCommand("ulx","banid",dat.sFr,dat.ban,"Ост. репутации с некорректной причиной")

		-- Таймер, чтобы оверрайднуть только что измененное сообщение через repRem
		timer.Simple(3,function()
			BOT:EditMessage(CBQ:Message(),"\n• Автора заблокировал @" .. CBQ:From():Login(),true)
				:Send()
		end)
	end

	-- Удалять репутацию разрешаем только Коссону
	if !KOSSON then return end

	if dat.rem then
		repRem(
			CBQ,
			dat.rem, -- id
			NormalizeSID(dat.sFr), -- author steamid (его репу удалит и предложит бан)
			NormalizeSID(dat.sTo)  -- targ's sid (ему придет сообщение о том, что нарушителя забанили)
		)
	end

end,"REPMod")
