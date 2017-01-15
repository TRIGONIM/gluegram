TLG.Cfg = TLG.Cfg or {}
TLG.CFG = TLG.Cfg -- alias

-- Токен, необходимый для работы бота. При указании некорректного токена бот не будет реагировать на сообщения
-- Инструкция по получению: https://core.telegram.org/bots#create-a-new-bot
TLG.Cfg.Token = "167720993:AAEzqbwu8Jpq9-***"

-- Некоторые команды не обязательно выполнять залогинившись,
-- но и выполнять их сразу на нескольких серверах нет смысла.
-- Например /sefmsg или /action или даже /help
-- Поэтому нужно определить сервер, который будет выполнять их сам
-- If you have one server, then set this var to true otherwise some commands
-- like /help will not be processed
TLG.Cfg.isMasterServer = TL.SERV == "kosson"

-- Само число пока что не важно
-- В данный момент играют роль только цифры 1 и 2
-- Если 1 сервер, то некоторые функции, из-за которых был бы спам в телеграм чат, будут активированы 
TLG.Cfg.totalServers = 3

-- Code name of current server. Need for /login cmd. and some another
-- Do not use uppercase characters!!
TLG.Cfg.SVName = TL.SERV

-- Language code name by ISO 639-1 classifycation
-- https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
TLG.Cfg.LangCode = "ru" -- ru, en, etc

-- The text that shown up to player when his loggen into the server
TLG.Cfg.MOTD = ( "\nServer uptime: " .. string.NiceTime(CurTime()) )

-- autodisconnect time in seconds
-- After this time user will be disconnected automatically
-- and... after any action this timer resets
TLG.Cfg.DiscTime = 1800 -- 30 minutes


-- Sometimes reports about disconnection from server bother
-- If you set this to "true", then you will not get messages like "You are disconnected from darkrp3" 
-- In any case, you will receive this message at manual disconnect
TLG.Cfg.noEchoOnDisconnect = true

-- Порт, на котором будут прослушиваться входящие сообщения
TLG.Cfg.SocksListenPort = 29000 + ServerID()

-- Те, кто может отправлять сообщения на сокет и не будет послан
TLG.Cfg.SocksIPWhitelist = {
	["localhost"]       = true,
	["127.0.0.1"]       = true,
	["89.108.104.58"]   = true, -- renter dedic
	["193.124.185.164"] = true, -- ihor dedic
	["194.67.215.50"]   = true, -- ihor vds
}


-- ИД пользовательских чатов с правами.
-- Чтобы получить ИД своего чата, нужно написать боту /getme

-- Константы
TLG_AMD = 87263523
TLG_DOS = 135283221
TLG_CONF_MOD = -150284611 -- конфа модеров
TLG_CONF_FD  = -105635897 -- конфа проекта

TLG.Cfg.Users = {
	[TLG_AMD] = { -- amd_nick
		group = "root",
	},
	[TLG_DOS] = { -- dmitry os
		group = "root",
		maxcmds = 5,
	},
	[188870154] = { -- IVogel
		group = "root",
		maxcmds = 10,
	}
}

-- Default game chat interceptors (Without previout authenfication and enabling)
-- If not selected, then needs to /login <server> and /logchat manually
TLG.Cfg.Interceptors = {
	--["TLG_AMD"] = true,
}

-- Режимы перехвата сообщений.
-- $ в начале не обязателен, но желателен, чтобы не конфликтовать с /say функцией
-- и не отправлять сообщение с включением режимов в чат
TLG.Cfg.InterModes = {
	["$global"] = function(parts,txt,ply,teamchat)
		local prefs = {
			["/ooc"]       = true,
			["/advert"]    = true,
			["/pm"]        = true,
			["/лс"]        = true,
			["/broadcast"] = true,
			["/a"]         = true,
			["//"]         = true,
			["/р"]         = true, -- русская р. Радио
			["/radio"]     = true,
		}

		return prefs[string.lower(parts[1])],
		"(" .. parts[1] .. ") " .. ply:Nick() .. ": " .. string.sub(txt,#parts[1] + 1,#txt)
	end,

	["$local"] = function(parts,txt,ply,teamchat)
		local prefs = {
			["/me"]        = true,
			["/yell"]      = true,
			["/whist"]     = true,
			["/*"]         = true,
			["/ш"]         = true, -- шепот
		}

		-- Не DarkRP команда, не FAdmin и не ULX или же имеет префикс, как выше
		local cmd = string.sub(parts[1],2,#parts[1])
		return (
			!DarkRP.getChatCommands()[cmd]
			and !ULib.sayCmds[parts[1] .. " "]
			and !FAdmin.Commands.List[cmd]
		) or prefs[parts[1]]
	end,

	["$allsay"] = function(parts,txt,ply,teamchat)
		return true
	end,

	-- ["$specific"] = function(parts,txt,ply,teamchat)
	-- 	return false -- TODO. Ввод конкретных слов дял перехвата
	-- end,

	["$teamchat"] = function(parts,txt,ply,teamchat)
		return teamchat,
		"(" .. ply:Nick() .. ") в груповой чат: " .. txt
	end,

	["$toadmins"] = function(parts,txt,ply,teamchat)
		return string.sub(parts[1],1,1) == "@",
		"(" .. ply:Nick() .. ") админам: " .. string.sub(txt,2,#txt)
	end,

	["$ulxcmds"] = function(parts,txt,ply,teamchat)
		return ULib.sayCmds[parts[1] .. " "],
		"(" .. ply:Nick() .. ") ввел ULX команду: " .. txt
	end,

	["$fadmincmds"] = function(parts,txt,ply,teamchat)
		return FAdmin.Commands.List[string.sub(parts[1],2,#parts[1])],
		"(" .. ply:Nick() .. ") ввел FADMIN команду: " .. txt
	end,

	["$darkrpcmd"] = function(parts,txt,ply,teamchat)
		local excluded = {
			["/me"]        = true,
			["/yell"]      = true,
			["/whist"]     = true,
			["/*"]         = true,
			["/ш"]         = true, -- шепот
			["/ooc"]       = true,
			["/advert"]    = true,
			["/pm"]        = true,
			["/лс"]        = true,
			["/broadcast"] = true,
			["/a"]         = true,
			["//"]         = true,
			["/р"]         = true, -- русская р. Радио
			["/radio"]     = true,
		}

		return DarkRP.getChatCommands()[string.sub(parts[1],2,#parts[1])] and !excluded[parts[1]],
		"(" .. ply:Nick() .. ") ввел DARKRP команду: " .. txt
	end,
}

-- Special permissions:

-- Example with all available parameters:
-- ["groupname"] = {
-- 		["allow"] = {
-- 			["*"] = ""
-- 		},
--		["deny"] = {
--			["command_or_permission"] = "argument or tag",
--		},

-- 		["inherit_from"] = "admin"
-- },
TLG.Cfg.MainGroup = "root"
TLG.Cfg.Groups = {

	[TLG.Cfg.MainGroup] = {
		["allow"] = {
			["cmd"] = true,
		},

		["inherit_from"] = "admin"
	},

	["admin"] = {
		["allow"] = {
			["sidinf"]  = true,
			["logchat"] = true,
			["say"]     = true,
			["ban"]     = true,
			["unban"]   = true,
		},

		["inherit_from"] = "premium"
	},

	["premium"] = {
		["allow"] = {
			["sasay"]   = true,
			["info"]    = true,
			["banlist"] = true,
		},

		["inherit_from"] = "vip"
	},

	["vip"] = {
		["allow"] = {
			["asay"] = true,
		},
		["deny"] = {
			--["selfmsg"] = true,
		},

		["inherit_from"] = "default"
	},

	["default"] = {
		["allow"] = {
			["help"]    = true,
			["selfmsg"] = true,
			["action"]  = true,
			["exit"]    = true,
		}
	},

}

-- All script data will be written into this folder in /garrysmod/data
TLG.Cfg.DataFolder = DATADIR .. "/gluegram"