local UPD = TLG.NewObjectBase("Update")

-- int
function UPD:UpdateID()
	return self.update_id
end

function UPD:Message()
	return TLG.SetMeta(self.message,"Message")
end

function UPD:EditedMessage()
	return TLG.SetMeta(self.edited_message,"Message")
end

function UPD:ChannelPost()
	return TLG.SetMeta(self.channel_post,"Message")
end

function UPD:EditedChannelPost()
	return TLG.SetMeta(self.edited_channel_post,"Message")
end

function UPD:InlineQuery()
	return self.inline_query
end

function UPD:ChosenInlineResult()
	return self.chosen_inline_result
end

function UPD:CallbackQuery()
	return TLG.SetMeta(self.callback_query,"CallbackQuery")
end