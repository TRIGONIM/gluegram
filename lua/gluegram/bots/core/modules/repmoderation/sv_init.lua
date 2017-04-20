local BOT = TLG.GetBot(TLG.SERV)


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

BOT:CBQHook(function(CBQ)
	if BOT.CBQHandlers[ CBQ.message.message_id ] then
		BOT.CBQHandlers[ CBQ.message.message_id ](CBQ)
	end
end,"SendAndHandleCBQ")





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

local om_msg = "Администратор @%s отреагировал на событие изменения репутации и удалил ее.\n\nСообщение события:\n%s"

local function repRem(CBQ,id,author_sid)
	REP.RemAction(id,author_sid,true,function(ok)
		local login = CBQ:From():Login()

		local IKB = TLG.InlineKeyboard()
		IKB:Line(
			IKB:Button("Бан час"):SetCallBackData({
				ban = true,
				rep_id = id,
				sid  = author_sid,
				term = 60
			}),
			IKB:Button("Бан сутки"):SetCallBackData({
				ban = true,
				rep_id = id,
				sid  = author_sid,
				term = 1440
			})
		)

		BOT:EditMessage(CBQ:Message(),"\n\n• Репа " .. (ok and "удалена" or "УЖЕ удалена") .. ". Мод: @" .. login,true)
			:SetReplyMarkup(IKB)
			:Send()

		if !ok then return end

		OM.SendMessage(util.SteamIDTo64(author_sid),
			om_msg:format(login, string.Safe( CBQ:Message()["text"] )),

			"Удаление репутации"
		)
	end)
end


hook.Add("OnRepAdd","TLG",function(sFrom,pTo,iCategory,message,id)
	local IKB = TLG.InlineKeyboard()
	IKB:Line(
		IKB:Button("Удалить"):SetCallBackData({
			rem = true,
			rep_id = id,
			sid    = sFrom
		})
	)


	local MSG = BOT:Message(TLG_CONF_MOD, msg:format(
		id,
		nickSid(sFrom),
		nickSid(pTo:SteamID()),
		REP.getCatNameByID(iCategory),
		message
	)):SetReplyMarkup(IKB,BOT)

	TLG.SendAndHandleCBQ(BOT,MSG,function(CBQ)
		local dat = CBQ:Data()

		if dat.ban then
			RunConsoleCommand("ulx","banid",dat.sid,dat.term,"Ост. репутации с некорректной причиной")

			-- Таймер, чтобы оверрайднуть только что измененное сообщение через repRem
			timer.Simple(3,function()
				BOT:EditMessage(CBQ:Message(),"\n• Автора заблокировал @" .. CBQ:From():Login(),true)
					:Send()
			end)

		elseif dat.rem then
			repRem(
				CBQ,
				dat.rep_id,
				dat.sid
			)

		end
	end)
end)

