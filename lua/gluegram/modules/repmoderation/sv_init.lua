local BOT = TLG.GetBot(TLG.SERV)

local function nickSid(sid)
	local pl = player.GetBySteamID(sid)
	return !pl and sid or ("(%s)%s"):format(sid,pl:Nick())
end

local msg = [[
	🎨 Изменение репутации
	Он: %s
	Ему: %s

	🏷 %s
	✉ %s
]]

local ban = "rep;%s;ban;%s;%i"
local rem = "rep;%s;rem;%s"


hook.Add("OnRepAdd","TLG",function(sFrom,pTo,iCategory,message,id)
	local IKB = TLG.InlineKeyboard()
	IKB:Line(
		IKB:Button("Удалить"):SetCallBackData(rem:format(id,sFrom))
	)
	IKB:Line(
		IKB:Button("Бан час + удал")  :SetCallBackData(ban:format(id,sFrom,60)),
		IKB:Button("Бан сутки + удал"):SetCallBackData(ban:format(id,sFrom,1440))
	)

	BOT:Message(TLG_CONF_MOD, msg:format(
		nickSid(sFrom),
		nickSid(pTo:SteamID()),
		REP.getCatNameByID(iCategory),
		message
	))
		:SetReplyMarkup(IKB)
		:Send()
end)


local om_msg = "Администратор @%s отреагировал на событие изменения репутации и удалил ее.\n\nСообщение события:\n%s"

local function repRem(CBQ,id,author_sid)
	REP.RemAction(id,author_sid,true,function(ok)
		local login = CBQ:From():Login()

		local IKB = TLG.InlineKeyboard()
		IKB:Line(
			IKB:Button("Бан час + удал")  :SetCallBackData( ban:format(id,author_sid,60) ),
			IKB:Button("Бан сутки + удал"):SetCallBackData( ban:format(id,author_sid,1440) )
		)

		BOT:EditMessage(CBQ:Message(),"\n• Репа под ID " .. id .. " " .. (ok and "удалена" or "УЖЕ удалена") .. ". Мод: @" .. login,true)
			:SetReplyMarkup(IKB)
			:Send()

		if !ok then return end

		OM(author_sid,om_msg:format(login, string.stripEmoji( CBQ:Message()["text"] )))
			:SetTitle("Удаление репутации")
			:SetName("Telegram @" .. login)
			:SetGroup(OM_REP)
			:SetLinks({
				["Написать ему"] = "https://t.me/" .. login,
			})
		:Send(true)
	end)
end


BOT:CBQHook(function(CBQ)
	-- rep:ban:h:STEAM_
	if CBQ:Data():sub(1,3) ~= "rep" then return end

	local args = string.Explode(";",CBQ:Data():sub(5))

	local rep_id,action,author_sid,ban_time = tonumber(args[1]),args[2],args[3],args[4]

	-- 1440, STEAM_
	if action == "ban" then
		RunConsoleCommand("ulx","banid",author_sid,ban_time,"Ост. репутации с некорректной причиной")

		-- Таймер, чтобы оверрайднуть только что измененное сообщение через repRem
		timer.Simple(2,function()
			BOT:EditMessage(CBQ:Message(),"\n• Автора репы под ID " .. rep_id .. " заблокировал @" .. CBQ:From():Login(),true)
				:Send()
		end)
	end

	-- if action == "rem" then
	-- /\Сначала было задумано так, но потом передумал и сделал удаление в любом случае
	repRem(CBQ,rep_id,author_sid)
end,"repmod")