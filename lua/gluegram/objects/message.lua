local MSG = TLG.NewObjectBase("Message")

--------------------------------------------------------------------

function TLG.NewMessage(bot_token,receiver,text)
	return setmetatable({
		chat_id   = receiver,
		text      = text,
		bot_token = bot_token
	}, MSG)
end

--------------------------------------------------------------------

-- !! int
function MSG:ID()
	return self.message_id
end

-- !! int
function MSG:Date()
	return self.date
end

-- !!
function MSG:Chat()
	return TLG.SetMeta(self.chat,"Chat")
end

function MSG:From()
	return TLG.SetMeta(self.from,"User")
end

function MSG:ForwardFrom()
	return TLG.SetMeta(self.forward_from,"User")
end

function MSG:ForwardFromChat()
	return TLG.SetMeta(self.forward_from_chat,"Chat")
end

-- int
function MSG:ForwardFromMessageID()
	return TLG.SetMeta(self.forward_from_message_id,"Chat")
end

-- int
function MSG:ForwardDate()
	return self.forward_date
end

function MSG:ReplyToMessage()
	return TLG.SetMeta(self.reply_to_message,"Message")
end

-- int
function MSG:EditDate()
	return self.edit_date
end

-- string
function MSG:Text()
	return self.text
end

-- Array of MessageEntity
function MSG:Ents()
	return self.entities
end

function MSG:Audio()
	return self.audio
end

function MSG:Document()
	return self.document
end

function MSG:Photo()
	return self.photo
end

function MSG:Sticker()
	return self.sticker
end

function MSG:Video()
	return self.video
end

function MSG:Voice()
	return self.voice
end

-- string
function MSG:Caption()
	return self.caption
end

function MSG:Contact()
	return self.contact
end

function MSG:Location()
	return self.location
end

function MSG:Venue() -- инфа о местоположении
	return self.venue
end

function MSG:NewMember()
	return TLG.SetMeta(self.new_chat_member,"User")
end

function MSG:MemberLeft()
	return TLG.SetMeta(self.left_chat_member,"User")
end

-- string
function MSG:NewChatTitle()
	return self.new_chat_title
end

function MSG:NewChatPhoto()
	return self.new_chat_photo
end

-- true
function MSG:DeleteChatPhoto()
	return self.delete_chat_photo
end

-- true
function MSG:GroupChatCreated()
	return self.group_chat_created
end

-- true
function MSG:SuperGroupChatCreated()
	return self.supergroup_chat_created
end

-- true
function MSG:ChannelCreated()
	return self.channel_chat_created
end

-- int
function MSG:MigrateToChatID()
	return self.migrate_to_chat_id
end

-- int
function MSG:MigrateFromChatID()
	return self.migrate_from_chat_id
end

function MSG:PinnedMessage()
	return TLG.SetMeta(self.pinned_message,"Message")
end

--------------------------------------------------------------------

function MSG:Send(fCallback)
	TLG.ProcessRequest(self.bot_token,"sendMessage",{
			["chat_id"]                  = tostring(self.chat_id),
			["text"]                     = self.text,
			["parse_mode"]               = self.parse_mode,
			["disable_web_page_preview"] = self.disable_web_page_preview,
			["reply_to_message_id"]      = self.reply_to_message_id,
			["reply_markup"]             = self.reply_markup
	},fCallback)
end

function MSG:EditText(fCallback)
	TLG.ProcessRequest(self.bot_token,"editMessageText",{
			["chat_id"]                  = tostring(self.chat_id),
			["text"]                     = self.text,
			["parse_mode"]               = self.parse_mode,
			["disable_web_page_preview"] = self.disable_web_page_preview,
			["reply_markup"]             = self.reply_markup,

			["message_id"]               = self.message_id,
			["inline_message_id"]        = self.inline_message_id,
	},fCallback)
end

--------------------------------------------------------------------

-- Markdown or HTML
-- https://tlgrm.ru/docs/bots/api#formatting-options
function MSG:SetParseMode(sMode)
	self.parse_mode = sMode
	return self
end

function MSG:DisableWebPagePreview(bDisable)
	self.disable_web_page_preview = bDisable
	return self
end

function MSG:DisableNotification(bDisable)
	self.disable_notification = bDisable
	return self
end

function MSG:ReplyTo(iReplyToMessageId)
	self.reply_to_message_id = iReplyToMessageId
	return self
end

-- InlineKeyboardMarkup or ReplyKeyboardMarkup or ReplyKeyboardHide or ForceReply
-- https://tlgrm.ru/docs/bots/api#sendmessage
function MSG:SetReplyMarkup(objMarkup)
	self.reply_markup = util.TableToJSON(objMarkup)
	return self
end

-- EDITING
--------------------------------------------------------------------
function MSG:SetEditMessageID(sID)
	self.message_id = tostring(sID)
	return self
end

function MSG:SetEditInlineMessageID(sID)
	self.inline_message_id = sID
	return self
end

-- function MSG:SetText(sText)
-- 	self.text = sText
-- 	return self
-- end

-- TODO. Fix shit. 
-- Используется после получения каллбэк квери, чтобы компенсировать недостающий эллемент
-- По умолчаниюю это значение применяется при BOT:Message(to,text)
-- function MSG:SetToken(sToken)
-- 	self.bot_token = sToken
-- 	return self
-- end