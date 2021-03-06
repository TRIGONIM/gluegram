--[[-------------------------------------------------------------------------
local IKB = TLG.InlineKeyboard()
IKB:Line(
	IKB:Button("Text 1"):SetURL("https://vk.com"), -- first button in the line
	IKB:Button("Text 2"):SetURL("https://vk.com") -- second ..
)
MESSAGE:SetReplyMarkup(IKB)
---------------------------------------------------------------------------]]

local IKB  = {} -- InlineKeyBoard
IKB.__index  = IKB

function IKB:GetLines()
	return self.inline_keyboard
end

function IKB:Line(...) -- объекты кнопок через запятые
	table.insert(self.inline_keyboard,{...})
end

function TLG.InlineKeyboard()
	return setmetatable({
		inline_keyboard = {}
	},IKB)
end

-------------------------------------------------

local IKBB = {} -- InlineKeyBoardButton
IKBB.__index = IKBB

function IKBB:SetURL(sUrl)
	self.url = sUrl
	return self
end

-- https://tlgrm.ru/docs/bots/api#callbackquery
function IKBB:SetData(tData)
	self.callback_data = pon.encode(tData)
	return self
end

function IKB:Button(sText)
	return setmetatable({
		text = sText
	},IKBB)
end
