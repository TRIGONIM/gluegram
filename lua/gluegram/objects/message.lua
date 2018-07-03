local MSG = TLG.NewObjectBase("Message")

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

function MSG:ReplyToMessage()
	return TLG.SetMeta(self.reply_to_message,"Message")
end

-- string
function MSG:Text()
	return self.text
end

-- string
function MSG:Caption()
	return self.caption
end
