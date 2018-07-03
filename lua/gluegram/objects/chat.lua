local CHAT = TLG.NewObjectBase("Chat")

-- !! int
function CHAT:ID()
	return self.id
end

-- !! string “private”, “group”, “supergroup” or “channel”
function CHAT:Type()
	return self.type
end
