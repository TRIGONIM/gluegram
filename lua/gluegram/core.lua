--[[-------------------------------------------------------------------------
	TODO TODO TODO
	• CMD:AddPassword()
	• Замена TLG.notifyGroup везде
	• То же самое касается хэндлеров команд и нажатий кнопок, к примеру
---------------------------------------------------------------------------]]
TLG.BOTS      = TLG.BOTS      or {}
TLG.OBJECTS   = TLG.OBJECTS   or {}


setmetatable(TLG, {
	__call = function(self,...)
		return self.NewBot(...)
	end
})


--[[-------------------------------------------------------------------------
	MISCELLANEOUS
---------------------------------------------------------------------------]]
function TLG.LogError(err)
	local sErr = isstring(err) and err
	if !sErr then
		sErr = "==== " .. TL.getDatetime() .. " ===="
		for typ,val in pairs(err) do
			sErr = sErr .. "\n" .. typ .. ": " .. val
		end
		sErr = sErr .. "\n========= [TLG ERR] =========\n\n"
	else
		sErr = "[TLG ERR] " .. sErr
	end

	print("\n\n\n" .. sErr)
	file.Append("telegram_errors.txt",sErr)
end


local GREEN = Color(50,200,50)
local WHITE = Color(245,245,245)
local GRAY  = Color(200,200,200)
function TLG.Print(msg)
	MsgC(GREEN,"[",WHITE,"TLG",GREEN,"] ", GRAY,msg .. "\n")
end

-- Helper function to escape telegram markdown chars
local esc_chars = "_`*["
function TLG.EscapeMarkdown(text)
	return text:gsub("[" .. esc_chars .. "]",function(s)
		return "\\" .. s
	end)
end
-- print( TLG.EscapeMarkdown("[abc](https://google.com) _italic_ `monow` *bold*") )


--[[-------------------------------------------------------------------------
	BOTS
---------------------------------------------------------------------------]]
function TLG.NewBot(sToken,sName)
	-- if TLG.BOTS[sName] then return TLG.BOTS[sName] end -- закомментить, если надо изменить метафункцию

	local OBJ = setmetatable(TLG.BOTS[sName] or {
		sessions = {}, -- авторизированные пользователи

		token = sToken,
		name  = sName,
	}, TLG.GetMeta("BOT"))

	TLG.BOTS[sName] = OBJ

	return OBJ
end

function TLG.GetBot(sName)
	return TLG.BOTS[sName]
end




--[[-------------------------------------------------------------------------
	OBJECTS
---------------------------------------------------------------------------]]
function TLG.AddObject(uid, tInf)
	TLG.OBJECTS[uid] = tInf
end

-- uid это название объекта, как указано в документации
function TLG.GetObject(uid)
	return TLG.OBJECTS[uid]
end

function TLG.SetMeta(tab, uid)
	return setmetatable(tab, TLG.GetObject(uid))
end

function TLG.GetMeta(uid)
	return FindMetaTable("TLG." .. uid)
end

function TLG.NewObjectBase(uid)
	if TLG.GetObject(uid) then
		return TLG.GetObject(uid)
	end

	local OBJ = {}
	OBJ.__index = OBJ

	debug.getregistry()["TLG." .. uid] = OBJ

	TLG.AddObject(uid,OBJ)

	return OBJ
end
