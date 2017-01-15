if !file.IsDir(TLG.Cfg.DataFolder,"DATA") then
	print("== CREATING DATA DIRECTORY FOR GLUEGRAM ==")
	file.CreateDir(TLG.Cfg.DataFolder)
end

local banfile = file.Read(TLG.Cfg.DataFolder .. "/bans.txt","DATA")
TLG.BANLIST = banfile and util.JSONToTable(banfile) or {}



function TLG.BanUser(user,admin,time,reason)

	if !user then
		return false, "Нужно ввести ник того, кого нужно забанить"
	end

	user = string.lower(user)

	if TLG.BANLIST[user] then
		return false, "Этот человек уже в бане от " .. (TLG.BANLIST[user].admin or "GOD") .. ". Для начала его нужно разбанить через /unban " .. user
	end

	TLG.BANLIST[user] = {
		admin = admin,
		unban = time and tonumber(time) and tonumber(time) ~= 0 and os.time() + tonumber(time) * 60 or nil,
		reason = reason
	}

	file.Write(TLG.Cfg.DataFolder .. "/bans.txt",util.TableToJSON(TLG.BANLIST,true))

	if admin == user then
		return true, "Ок. Вы забанили сами себя. Яснопонятно. Рукалицо -_-"
	else
		return true, user .. " успешно забанен до " .. (TLG.BANLIST[user].unban and os.date("%X - %d.%m.%Y",TLG.BANLIST[user].unban) or "конца века") .. ". Время на сервере: " .. os.date("%X - %d.%m.%Y",os.time())
	end

end




function TLG.UnBanUser(user)

	if !user then
		return false, "Нужно ввести ник того, кого нужно разбанить"
	end

	user = string.lower(user)

	if !TLG.BANLIST[user] then
		return false, "Этого чела нет в бане"
	end

	TLG.BANLIST[user] = nil
	file.Write(TLG.Cfg.DataFolder .. "/bans.txt",util.TableToJSON(TLG.BANLIST,true))

	return true, "@" .. user .. " разбанен"
end




function TLG.sendBanList()

	if table.Count(TLG.BANLIST) == 0 then
		return false, "Банлист пуст"
	end

	local result = ""
	local counter = 1
	for bnick,data in pairs(TLG.BANLIST) do
		result = result ..
			string.format("%s. [%s] Забанил %s до %s с причиной: %s\n",
				counter,
				bnick,
				(data.admin or "GOD"),
				(data.unban and os.date("%X - %d.%m.%Y",data.unban) or "конца века"),
				(data.reason or "PWNED")
			)
		counter = counter + 1
	end

	return true, result

end


hook.Add("onNewGluegramMessage","TLG.CheckBan",function(msg)

	local from_id = msg["message"]["from"]["id"]
	local from_nick = msg["message"]["from"]["username"]
	if !from_nick then return end
	from_nick = string.lower(from_nick)

	-- TODO СДЕЛАТЬ РАЗБАН ВМЕСТО ПРОСТОГО ЧЕКА НА ВРЕМЯ, ИБО 2 РАЗА ОДНОГО ЧЕЛА ЗАБАНИТЬ НЕ ВЫЙДЕТ
	if (TLG.BANLIST[from_nick] and TLG.BANLIST[from_nick]["unban"] and os.time() < TLG.BANLIST[from_nick]["unban"])
	or (TLG.BANLIST[from_nick] and !TLG.BANLIST[from_nick]["unban"]) then
		TG.SendMessage(
			from_id,
			string.format(
				TLG.Language.you_are_banned,
				TLG.BANLIST[from_nick]["admin"] or "GOD",
				TLG.BANLIST[from_nick]["reason"] or "PWNED",
				(TLG.BANLIST[from_nick]["unban"] and os.date("%X - %d.%m.%Y",TLG.BANLIST[from_nick]["unban"]) or "NEVER")
			)
		)

		return false
	elseif TLG.BANLIST[from_nick] then
		TLG.UnBanUser(from_nick)
		print("== " .. string.upper(from_nick) .. " UNBANNED ==")
	end

end)