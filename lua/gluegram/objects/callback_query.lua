/*
{
    ['update_id']      = 735924525,
    ['callback_query'] = {
        ['data']          = 'rep;3942;rem;STEAM_0:1:**',
        ['chat_instance'] = '2876631717852668994',
        ['from']          = {
            ['username']   = 'amd_nick',
            ['first_name'] = '_AMD_',
            ['id']         = 87263523,
        },
        ['message']       = {
            ['message_id'] = 51332,
            ['date']       = 1484405780,
            ['from']       = {
                ['username']   = 'my_info_bot',
                ['first_name'] = '[TRIGON.IM] INFO BOT',
                ['id']         = 167720993,
            },
            ['chat']       = {
                ['type']                           = 'group',
                ['all_members_are_administrators'] = true,
                ['title']                          = 'TG Moderation',
                ['id']                             = -150284611,
            },
            ['text']       = 'Текст',
        },
        ['id']            = '374793978519919109',
    },
}
 */


local CBQ = TLG.NewObjectBase("CallbackQuery")

-- !! string
function CBQ:ID()
	return self.id
end

-- !!
function CBQ:From()
	return TLG.SetMeta(self.from,"User")
end

-- !! string
function CBQ:ChatInstance()
	return self.chat_instance
end

function CBQ:Message()
	return TLG.SetMeta(self.message,"Message")
end

-- string
function CBQ:InlineMessageId()
	return self.inline_message_id
end

-- string
function CBQ:Data()
	return self.data
end

-- string
function CBQ:GameShortName()
	return self.game_short_name
end