local B = TLG.NewBot("167720993:AAEzqbwu8Jpq9-L3tblzrPXR1t_ywYcx5Fw","main")
	:SetListenPort(29000 + ServerID())


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

	B:Message(TLG_CONF_MOD, msg:format(
		nickSid(sFrom),
		nickSid(pTo:SteamID()),
		REP.getCatNameByID(iCategory),
		message
	))
		:SetReplyMarkup(IKB)
		:Send()
end)


local function repRem(CBQ,id,author)
	REP.RemAction(id,author,true,function(ok)
		local IKB = TLG.InlineKeyboard()
		IKB:Line(
			IKB:Button("Бан час + удал")  :SetCallBackData( ban:format(id,author,60) ),
			IKB:Button("Бан сутки + удал"):SetCallBackData( ban:format(id,author,1440) )
		)

		B:EditMessage(CBQ:Message(),"\n• Репа под ID " .. id .. " " .. (ok and "удалена" or "УЖЕ удалена") .. ". Мод: @" .. CBQ:From():Login(),true)
			:SetReplyMarkup(IKB)
			:EditText()
	end)
end


B:CBQHook(function(CBQ)
	-- rep:ban:h:STEAM_
	if CBQ:Data():sub(1,3) ~= "rep" then return end

	local args = string.Explode(";",CBQ:Data():sub(5))

	local rep_id,action,author_sid,ban_time = tonumber(args[1]),args[2],args[3],args[4]

	-- 1440, STEAM_
	if action == "ban" then
		RunConsoleCommand("ulx","banid",author_sid,ban_time,"Ост. репутации с некорректной причиной")

		-- Таймер, чтобы оверрайднуть только что измененное сообщение через repRem
		timer.Simple(2,function()
			B:EditMessage(CBQ:Message(),"\n• Автора репы под ID " .. rep_id .. " заблокировал @" .. CBQ:From():Login(),true)
				:EditText()
		end)
	end

	-- if action == "rem" then
	-- /\Сначала было задумано так, но потом передумал и сделал удаление в лююбом случае
	repRem(CBQ,rep_id,author_sid)
end)