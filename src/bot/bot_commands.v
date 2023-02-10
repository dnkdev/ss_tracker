module bot

import vtelegram { BotCommand,BotCommandScopeAllPrivateChats }

fn set_bot_commands(app App) !{
	start_c := BotCommand{
		command: '/start'
		description: 'language choose'
	}
	menu_c := BotCommand{
		command: '/menu'
		description: 'user menu'
	}
	stop_c := BotCommand{
		command: '/stop'
		description: 'turn off all trackers'
	}
	all_commands := [start_c,menu_c,stop_c]
	scope := BotCommandScopeAllPrivateChats{
		@type: 'all_private_chats'
	}
	app.setmycommands(
		commands: all_commands,
		scope: scope
	)!
}
