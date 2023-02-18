module main

import vtelegram { InlineKeyboardButton, InlineKeyboardMarkup, Update }
import database { User }
import reader { read_categories, read_second_categories }
import time
// import x.json2 as json

[callback_query: 'back']
fn (mut app App) go_back(result Update) ! {
	mut user := app.db.user_from_result(result)!
	show_categories(mut app, mut user) or { println(err) }
}

// delete_last_message must be after new message sending, where message in params is new message
fn delete_last_message[T](mut app T, mut user User, message_id int) {
	if message_id != 0 && user.bot_message_id != 0 {
		app.deletemessage(chat_id: user.telegram_id, message_id: user.bot_message_id) or {
			println('${time.now()} Can\'t delete bot message ${user.telegram_id} - ${user.bot_message_id} ${err}')
		}
	}
	user.bot_message_id = message_id
}

['callback_query: starts_with: category_']
fn (mut app App) show_second_choose(result Update) ! {
	// println(result.callback_query.data)
	mut user := app.db.user_from_result(result)!
	user.category = result.callback_query.data
	// search for category name data for display in the end
	buts := result.callback_query.message.reply_markup.inline_keyboard
	for b in buts {
		if b[0].callback_data.contains(user.category) {
			user.category_name = b[0].text
			break
		}
	}
	//
	categories := read_second_categories(user.lang, result.callback_query.data)!
	mut text := ''
	mut i := 1
	for cat, _ in categories {
		text += '/${i}. ${cat}\n'
		i++
	}
	// Click to Open [URL](http://example.com) Ievadiet
	text += match user.lang {
		'lv' { '⬆️ Izvēlaties apakškategorijas numuru.' }
		'ru' { '⬆️ Выберите номер субкатегории.' }
		else { '⬆️ Choose a number of subcategory.' }
	}

	message := app.sendmessage(
		chat_id: user.telegram_id
		text: text
		parse_mode: 'Markdown'
		reply_markup: get_back_button(user.lang)
	)!
	delete_last_message(mut app, mut user, message.message_id)
	app.db.update_user(user)!
}

pub fn show_categories[T](mut bot T, mut user User) ! {
	result := read_categories(user.lang)!
	mut buttons := [][]InlineKeyboardButton{}
	for cat, val in result {
		buttons << [
			InlineKeyboardButton{
				text: cat
				callback_data: 'category_${val}'
			},
		]
	}
	reply_markup := InlineKeyboardMarkup{buttons}
	text := match user.lang {
		'lv' { '⬇️ Izvēlaties kategoriju:' }
		'ru' { '⬇️ Выберите категорию:' }
		else { '⬇️ Choose category:' }
	}
	message := bot.sendmessage(chat_id: user.telegram_id, text: text, reply_markup: reply_markup)!
	user = bot.db.user_get(user)!
	delete_last_message(mut bot, mut user, message.message_id)
	bot.db.update_user(user)!
}
