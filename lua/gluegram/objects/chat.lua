local CHAT = TLG.NewObjectBase("Chat")

-- !! int
function CHAT:ID()
	return self.id
end

-- !! string “private”, “group”, “supergroup” or “channel”
function CHAT:Type()
	return self.type
end

-- string
function CHAT:Title()
	return self.title
end

-- string
function CHAT:Name()
	return self.username
end

-- string
function CHAT:FName()
	return self.first_name
end

-- string
function CHAT:LName()
	return self.last_name
end

-- bool
function CHAT:IsAllAdmins()
	return self.all_members_are_administrators
end