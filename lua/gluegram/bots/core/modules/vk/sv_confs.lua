local BOT = TLG_CORE_BOT


local function getConfs(sSearchTerm, fCallback)
	VK_ACCOUNT:SearchDialogs(sSearchTerm, fCallback)
end

local function showConfUsers(conf_id, fCallback)
	VK_ACCOUNT:GetChatUsers(conf_id, fCallback)
end

local function kickConfUser(conf_id, user_id, fCallback)
	VK_ACCOUNT:RemoveChatUser(conf_id, user_id, fCallback)
end




-- tlg_msg - сообщение, которое нужно отредактировать и отобразитьь результат выполнения запроса
local function processKick(conf_id, user_id, tlg_msg)
	kickConfUser(conf_id, user_id, function(res)
		BOT:EditMessage(tlg_msg, res == 1 and
			"Ну все, вы от него избавились" or
			"Там ошибка произошла. Короче нельзя так кикнуть"
		):Send()
	end)
end

local function printConfUsers(conf_id, tlg_msg)
	showConfUsers(conf_id,function(d)
		local IKB_USERS = TLG.InlineKeyboard()

		for i,user in ipairs(d) do
			if user["uid"] == user["invited_by"] then continue end -- creator aka ME

			IKB_USERS:Line( IKB_USERS:Button(user["first_name"] .. " " .. user["last_name"]):SetCallBackData({
				kick = true,

				conf_id = conf_id,
				user_id = user["uid"],
			}) )
		end

		BOT:EditMessage(tlg_msg,"Теперь выберите кого вы хотите кикнуть")
			:SetReplyMarkup(IKB_USERS)
			:Send()
	end)
end


-- vkconf
BOT:AddCommand("vkconf",function(MSG)

	-- Выводим список диалогов для управления
	getConfs("[TG]",function(res)
		local IKB = TLG.InlineKeyboard()

		for i,conf in ipairs(res) do
			if conf["type"] ~= "chat" then continue end -- profile etc

			IKB:Line( IKB:Button(string.sub(conf["title"],#"[TG]" + 1)):SetCallBackData({
				show_users = true,
				conf_id    = conf["chat_id"]
			}) )
		end

		local msg = BOT:Message(MSG:Chat(), "Выберите конференцию из которой хотите кикнуть чела")
			:SetReplyMarkup(IKB)

		TLG.SendAndHandleCBQ(BOT,msg,function(CBQ)
			local dat = CBQ:Data()

			-- Вывод списка участников конфы
			if dat.show_users then
				printConfUsers(dat.conf_id, CBQ:Message())

			-- Кик чела из конфы
			elseif dat.kick then
				processKick(dat.conf_id, dat.user_id, CBQ:Message())

			end
		end)

	end)

end)
	:SetForMaster(true)
	:SetDescription("Позволяет кикать участников конференций тригона в ВК")

