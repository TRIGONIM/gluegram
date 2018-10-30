TLG.BOTS = TLG.BOTS or {}

setmetatable(TLG, {
	__call = function(self, ...)
		return self.CreateBot(...)
	end
})


--[[-------------------------------------------------------------------------
	MISCELLANEOUS
---------------------------------------------------------------------------]]
function TLG.LogError(err)
	local sErr = isstring(err) and err
	if not sErr then
		sErr = "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
		for typ,val in pairs(err) do
			sErr = sErr .. "\n" .. typ .. ": " .. val
		end
		sErr = sErr .. "\n========= [TLG ERR] =========\n\n"
	else
		sErr = "[TLG ERR] " .. sErr
	end

	print("\n\n\n" .. sErr)
	file.Append("gluegram/telegram_errors.txt",sErr)
	-- debug.Trace()
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
-- Регает полноценного бота, которого можно
-- использовать как базу или как отдельную единицу
function TLG.NewBot(class, base_class)
	assert(!base_class or TLG.BOTS[base_class], "Attempt to inherit non existent bot class: " .. tostring(base_class))

	TLG.BOTS[class] = TLG.BOTS[class] or {class = class}
	local BOT = TLG.BOTS[class]

	if base_class then
		table.Inherit(BOT, TLG.BOTS[base_class]) -- цепляем к BOT .BaseClass
		setmetatable(BOT, {__index = BOT.BaseClass})
	else
		setmetatable(BOT, {__index = TLG.GetMeta("BOT")})
	end

	return BOT
end

-- как newbot, только обертка, чтобы самому не надо было некоторые действия делать
function TLG.CreateBot(class, base_class, token)
	local BOT = TLG.NewBot(class, base_class)
	BOT.token = token
	BOT.id    = tonumber(token:match("^(%d+)")) -- :(.+)$

	return BOT
end

function TLG.GetBot(sName)
	return TLG.BOTS[sName]
end




--[[-------------------------------------------------------------------------
	OBJECTS
---------------------------------------------------------------------------]]
function TLG.SetMeta(tab, uid)
	return tab and setmetatable(tab, TLG.GetMeta(uid))
end

function TLG.GetMeta(uid)
	return FindMetaTable("TLG." .. uid)
end

function TLG.NewObjectBase(uid)
	if TLG.GetMeta(uid) then
		return TLG.GetMeta(uid)
	end

	local OBJ = {}
	OBJ.__index = OBJ

	debug.getregistry()["TLG." .. uid] = OBJ

	return OBJ
end
