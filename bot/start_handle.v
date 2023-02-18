module main

import time
import vtelegram as vt
import database { User, result_to_user }

['callback_query: en'; 'callback_query: lv'; 'callback_query: ru']
fn (mut app App) select_language(result vt.Update) {
	mut user := result_to_user(result)
	user.lang = result.callback_query.data
	app.db.save_language(user) or { println(err) }
	show_categories(mut app, mut user) or { println(err) }
}

[message:'/start']
fn (mut app App) on_start(result vt.Update) ! {
	reply_markup := get_language_buttons()
	message := app.sendmessage(
		chat_id: result.message.from.id
		text: '👀 *SS.COM TRACKER* 👀'
		parse_mode: 'Markdown'
		reply_markup: reply_markup
	)!
	mut user := User{
		telegram_id: result.message.from.id
		bot_message_id: message.message_id
	}
	if !app.db.user_exist(user) {
		user = User{
			telegram_id: result.message.from.id
			created_at: time.now()
			bot_message_id: message.message_id
		}
		app.db.add_user(user)
	} else {
		app.db.update_user(user)!
	}
}
