local USER = TLG.NewObjectBase("User")

-- !! int
function USER:ID()
	return self.id
end

-- !! -- string
function USER:Login()
	return self.username
end

-- string
function USER:FName()
	return self.first_name
end

-- string
function USER:LName()
	return self.last_name
end