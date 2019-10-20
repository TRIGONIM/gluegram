TLG.BOTS = TLG.BOTS or {}

--[[-------------------------------------------------------------------------
	MISCELLANEOUS
---------------------------------------------------------------------------]]
function TLG.LogError(sErr)
	local msg = ""
	msg = msg .. "==== " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===="
	msg = msg .. "\n" .. sErr
	msg = msg .. "\n========= [TLG ERR] =========\n\n"

	MsgN(msg)
	file.Append("gluegram/telegram_errors.txt", msg)
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

local function esc(name)
	return name:gsub("]","}"):gsub("%[","{")
end

function TLG.MarkdownURL(name, url)
	return "[" .. esc(name) .. "](" .. url .. ")"
end

function TLG.Mention(nick, tlg_id)
	return TLG.MarkdownURL(nick, "tg://user?id=" .. tlg_id)
end


--[[-------------------------------------------------------------------------
	BOTS
---------------------------------------------------------------------------]]
function TLG.Bot(class)
	TLG.BOTS[class] = {class = class}
	return TLG.BOTS[class]
end

function TLG.BotFrom(base_class, class)
	assert(TLG.BOTS[base_class], "Attempt to inherit non existent bot class: " .. tostring(base_class))

	local BOT = TLG.Bot(class)
	table.Inherit(BOT, TLG.BOTS[base_class]) -- цепляем к BOT .BaseClass
	setmetatable(BOT, {__index = BOT.BaseClass}) -- ищем у родителя отсутствующие методы

	return BOT
end

function TLG.CreateBot(class, base_class, token)
	local BOT = TLG.BotFrom(base_class, class)
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
	local MT = assert(FindMetaTable("TLG." .. uid), "No meta: " .. (uid or "falsy"))
	return tab and setmetatable(tab, MT)
end

function TLG.NewObjectBase(uid)
	local MT = FindMetaTable("TLG." .. uid)
	if MT then return MT end

	local OBJ = {}
	OBJ.__index = OBJ

	debug.getregistry()["TLG." .. uid] = OBJ

	return OBJ
end
