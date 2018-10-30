local USER = TLG.NewObjectBase("User")
USER.__tostring = function(self)
	return self.username and ("@" .. self.username) or self.first_name
end
USER.__concat = function(a,b)
	return tostring(a) .. tostring(b) -- :|
end

-- !! int
function USER:ID()
	return self.id
end

function USER:IsBot()
	return self.is_bot
end

function USER:Name()
	return tostring(self)
end

-- !! string
function USER:FName()
	return self.first_name
end

-- string
function USER:LName()
	return self.last_name
end

-- string
function USER:Login()
	return self.username
end
