module bot

import vtelegram { Result, ReplyKeyboardMarkup, KeyboardButton }
import database { User }

['callback_query: starts_with: region_']
pub fn (app App) set_region_my_tracker(result Result)!{
	user := app.db.user_from_result(result)!
	data := result.query.data.split(':')
	if data.len == 0 {
		return
	}
	trackerid := data[0].int()
	region := data[1]
	app.db.update_tracker_filter_by_id(trackerid, region)
	text := match user.lang{
		'lv'{'Filters uzstādīts'}
		'ru'{'Фильтр установлен'}
		else{'Filter installed'}
	}
	app.sendmessage(
		chat_id: result.query.message.chat.id
		text: '❇️ *${text}*'
		parse_mode: 'Markdown'
	)!
	app.deletemessage(
		chat_id: result.query.message.chat.id
		message_id: result.query.message.message_id
	)!
}

fn category_without_filter(app App, user User, url string)!bool{
	if 	url.contains('/transport/cargo-cars/') ||
		url.contains('/transport/cars/'){
		text := match user.lang {
			'lv'{'Šai sadaļai nav filtru.'}
			'ru'{'В этом разделе нет фильтров.'}
			else{
				'This section doesn\'t have filters'
			}
		}
		app.sendmessage(
			chat_id: user.telegram_id
			text: '*${text}*'
			parse_mode:'Markdown'
		)!
		return false
	}
	return true
}

['callback_query: starts_with: filter_']
pub fn (app App) filter_my_tracker(result Result)!{
	number := result.query.data.int()
	if number != 0{
		user := app.db.user_from_result(result)!
		tracker := app.db.get_trackers_by_id(number)
		if category_without_filter(app, user, tracker.section_url)! == false{
			return
		}
		mut which_lang := 'ru'
		if tracker.section_url.contains('/lv/'){
			which_lang = 'lv'
		}
		else if tracker.section_url.contains('/en/'){
			which_lang = 'en'
		}
		reply_markup := get_filter_regions_buttons(tracker, which_lang)!
		text := match user.lang{
			'lv'{'Uzstādīt filtru:'}
			'ru'{'Установить фильтр:'}
			else{'Set filter:'}
		}
		app.sendmessage(
			chat_id: result.query.message.chat.id
			text: '${tracker.subcategory_name}\n${tracker.section_name}\n*${text}*'
			parse_mode:'Markdown'
			reply_markup:reply_markup
		)!
		app.deletemessage(
			chat_id: result.query.message.chat.id
			message_id: result.query.message.message_id
		)!
	}
}

['callback_query: starts_with: delete_']
pub fn (app App) delete_my_tracker(result Result)!{
	number := result.query.data.int()
	if number != 0{
		app.db.delete_tracker_with_id(number)
		app.sendmessage(
			chat_id: result.query.message.chat.id
			text: '✔️ Deleted'
		)!
		app.deletemessage(
			chat_id: result.query.message.chat.id
			message_id: result.query.message.message_id
		)!
	}
}


[starts_with: '/my']
pub fn (app App) hanlde_my_tracker(result Result)!{
	number := result.message.text.int()
	if number != 0{
		user := app.db.user_from_result(result)!
		tracker := app.db.get_trackers_by_id(number)
		if tracker.id != 0 && user.telegram_id == tracker.telegram_id{
			text := '*${tracker.section_name}*\n*${tracker.subcategory_name}*\n${tracker.filter}\n${tracker.created_at.format()}'
			reply_markup := get_tracker_handle_button(tracker, user.lang)
			app.sendmessage(
				chat_id: result.message.chat.id
				text: text
				reply_markup:reply_markup
				parse_mode:'Markdown'
			)!
		}
	}
}

['👁 Select']
pub fn (app App) my_select(result Result)!{
	mut user := app.db.user_from_result(result)!
	show_categories(app, mut user) or { println(err) }
}

['📕 My Trackers']
pub fn (app App) my_trackers(result Result)!{
	user := app.db.user_from_result(result)!
	trackers := app.db.get_trackers_by_user(user)
	mut text := match user.lang{
		'lv'{'Ja vēlies izdēst visus izsekotājus, ieraksti /stop\nTavi izsekotāji:\n\n'}
		'ru'{'Для удаления всех трекеров - введи /stop\nТвои трекеры:\n\n'}
		else{
			'/stop - For delete all trackers\nYour trackers:\n\n'
		}
	}
	for track in trackers{
		text += '/my${track.id} ${track.section_name} ${track.subcategory_name} ${track.filter}\n'
	}
	if trackers.len == 0{
		text += match user.lang{
			'lv'{'Tu neko neizseko.'}
			'ru'{'Ты ничего не отслеживаешь.'}
			else{
				'Your don\'t have trackers.'
			}
		}
	}
	else {
		text += match user.lang{
			'lv'{'\n⬆️ Izvēlies savu izsekotāja numuru.'}
			'ru'{'\n⬆️ Выбери номер своего трекера.'}
			else{
				'\n⬆️ Select number of your tracker.'
			}
		}
	}
	app.sendmessage(
		chat_id: result.message.chat.id
		text: text
	)!
}

['/menu']
pub fn (app App) on_menu(result Result)!{
	user := app.db.user_from_result(result)!
	text := match user.lang{
		'lv'{'Izvelne zem ievades līnijas...'}
		'ru'{'Меню под строкой ввода...'}
		else{
			'Menu is below input line...'
		}
	}

	mut buttons := [][]KeyboardButton{}
	buttons << [
		KeyboardButton{
			text: '📕 My Trackers'
		},
		KeyboardButton{
			text: '👁 Select'
		}
	]
	reply_markup := ReplyKeyboardMarkup{
		keyboard: buttons
		resize_keyboard: true
	}
	app.sendmessage(chat_id: result.message.chat.id, text:'📕 $text', reply_markup: reply_markup)!
}

['/stop']
pub fn (app App) on_stop(result Result)!{
	user := app.db.user_from_result(result)!
	trackers := app.db.get_trackers_by_user(user)
	for t in trackers{
		app.db.delete_tracker_with_id(t.id)
		text := '✔️ *${t.section_name}* Deleted'
		app.sendmessage(
			chat_id: result.message.chat.id
			text: text
			parse_mode:'Markdown'
		)!
	}

}
