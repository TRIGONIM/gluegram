TLG.Cfg = TLG.Cfg or {}
TLG.CFG = TLG.Cfg -- alias


-- Code name of current server. Need for /login cmd. and some another
-- Do not use uppercase characters!!
TLG.Cfg.SVName = TL.SERV
TLG.CFG.SVNAME = TL.SERV


-- Те, кто может отправлять сообщения на сокет и не будет послан
TLG.CFG.SocksIPWhitelist = {
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

-- All script data will be written into this folder in /garrysmod/data
TLG.Cfg.DataFolder = DATADIR .. "/gluegram"