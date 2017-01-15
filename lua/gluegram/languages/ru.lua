TLG.Language = {}
local l = TLG.Language


l.not_logged = "Вы не авторизированы"

l.on_connect = "Вы присоединились к (%s). %s"
l.on_connect_err = "Сервер (%s) уже активен"

l.on_disconnect = "Вы отключились от %s"
l.on_disconnect_err = "Соединение с (%s) не активно"

l.forb_execution = "Выполнение команды запрещено. Причина: %s"
l.not_func = "Команда не имеет назначеной функции. Параметр \".func\" в конфиге"
l.cmd_not_exists = "Команды /%s не существует"

l.missing_old_message = "Старое сообщение отсутствует"
l.received_by_server = "Сообщение получено сервером"

l.no_nickname_auth = "Потеряйся, ноунейм!" -- Когда чел не имеет ника
l.you_are_banned = "Вас забанили! \nЛогин: @%s \nПричина: %s\nРазбан: %s"
l.not_permitted = "Пошел нахуй, @%s" -- Когда юзер забанен или не имеет прав на запуск команды

l.no_desc = "Описание отсутствует"
l.too_many_commands = "Жопа не лопнет от кол-ва команд?"
l.not_allowed = "[%s] У вас нет прав для этого" -- %s = имя сервера капсом