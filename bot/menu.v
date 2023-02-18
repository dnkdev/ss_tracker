module main

import vtelegram { KeyboardButton, ReplyKeyboardMarkup, Update }
import database { get_user_tracker_by_url, user_tracker_exists_by_id, User, update_user_tracker_filter_by_id, get_user_tracker_by_id,get_user_trackers, delete_user_tracker_with_id}
import os


[message]
pub fn (mut app App) message_for_custom_filter(result Update) ! {
	user := app.db.user_from_result(result)!
	text := result.message.text
	//if text.is_capital() || arr_ru.contains(text[0].str()) {
	if app.db.get_user_custom_filter_set(user) {
		if user.confirm_section.contains('/ru') {
			// V doesn't have localization for now
			arr_ru := ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Э', 'Ю', 'Я']
			for a in arr_ru {
				if a.bytes()[0] == text[0].ascii_str().bytes()[0]{
					break
				}
				else{
					app.db.set_user_custom_filter_set(user, false)
					return
				}
			}
		}
		else if !text[0].is_letter(){
			app.db.set_user_custom_filter_set(user, false)
			return
		}
		tracker := get_user_tracker_by_url(user, user.confirm_section)
		if tracker.id != 0 {
			update_user_tracker_filter_by_id(user, tracker.id, '${text}')
		}
		rtext := match user.lang {
			'lv' { 'Filters uzstādīts' }
			'ru' { 'Фильтр установлен' }
			else { 'Filter installed' }
		}
		app.sendmessage(
			chat_id: result.message.chat.id
			text: '❇️ *${rtext}*'
			parse_mode: 'Markdown'
		)!
		show_user_trackers(mut app, result)!
		app.db.set_user_custom_filter_set(user, false)
	}
}

['callback_query: starts_with: rcustom_']
pub fn (mut app App) set_custom_filter_my_tracker(result Update) ! {
	mut trackerid := result.callback_query.data.int()
	if trackerid != 0{
		result.callback_query.message.delete(mut app)!
		user := app.db.user_from_result(result)!
		app.db.set_user_custom_filter_set(user, true)
		text := match user.lang {
			'lv' { 'Ievadiet jūsu filtru, pēc kura jums būs sūtiti atbilstoši sludinājumi (Pilsēta):' }
			'ru' { 'Введите свой фильтр по которому вам будут выдаваться объявления (Город):' }
			else { 'Enter your custom filter, for which ads will be issued to you (City):' }
		}
		app.sendmessage(
			chat_id: result.callback_query.message.chat.id
			text: '❇️ *${text}*'
			parse_mode: 'Markdown'
		)!
	}
}

['callback_query: starts_with: r_']
pub fn (mut app App) set_region_my_tracker(result Update) ! {
	user := app.db.user_from_result(result)!
	data := result.callback_query.data.split(':')
	if data.len == 0 {
		return
	}
	trackerid := data[0].int()
	region := data[1]
	//app.db.update_tracker_filter_by_id(trackerid, region)
	if !user_tracker_exists_by_id(user, trackerid) {
		app.deletemessage(
			chat_id: result.callback_query.message.chat.id
			message_id: result.callback_query.message.message_id
		)!
		return
	}
	update_user_tracker_filter_by_id(user, trackerid, region)
	text := match user.lang {
		'lv' { 'Filters uzstādīts' }
		'ru' { 'Фильтр установлен' }
		else { 'Filter installed' }
	}
	app.sendmessage(
		chat_id: result.callback_query.message.chat.id
		text: '❇️ *${text}*'
		parse_mode: 'Markdown'
	)!
	app.deletemessage(
		chat_id: result.callback_query.message.chat.id
		message_id: result.callback_query.message.message_id
	)!
	show_user_trackers(mut app, result)!
}

fn category_without_filter(mut app App, user User, url string) !bool {
	if url.contains('/real-estate/') || url.contains('/transport/cargo-cars/')
		|| url.contains('/transport/cars/') {
		text := match user.lang {
			'lv' {
				'Šai sadaļai nav filtru.'
			}
			'ru' {
				'В этом разделе нет фильтров.'
			}
			else {
				"This section doesn't have filters."
			}
		}
		app.sendmessage(
			chat_id: user.telegram_id
			text: '*${text}*'
			parse_mode: 'Markdown'
		)!
		return true
	}
	return false
}

['callback_query: starts_with: f_']
pub fn (mut app App) filter_my_tracker(result Update) ! {
	mut number := result.callback_query.data.u16()
	if number != 0 {
		user := app.db.user_from_result(result)!
		tracker := get_user_tracker_by_id(user, number)
		if category_without_filter(mut app, user, tracker.section_url)! == true {
			return
		}
		mut which_lang := 'ru'
		if tracker.section_url.contains('/lv/') {
			which_lang = 'lv'
		} else if tracker.section_url.contains('/en/') {
			which_lang = 'en'
		}
		reply_markup := get_filter_regions_buttons(tracker, which_lang)!
		text := match user.lang {
			'lv' { 'Uzstādīt filtru:' }
			'ru' { 'Установить фильтр:' }
			else { 'Set filter:' }
		}
		app.sendmessage(
			chat_id: result.callback_query.message.chat.id
			text: '${tracker.subcategory_name}\n${tracker.section_name}\n*${text}*'
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		)!
		app.deletemessage(
			chat_id: result.callback_query.message.chat.id
			message_id: result.callback_query.message.message_id
		)!
	}
}

['callback_query: starts_with: d_']
pub fn (mut app App) delete_my_tracker(result Update) ! {
	mut number := result.callback_query.data.u16()
	if number != 0 {
		user := app.db.user_from_result(result)!
		delete_user_tracker_with_id(user,number)
		app.sendmessage(
			chat_id: result.callback_query.message.chat.id
			text: '✔️ Deleted'
		)!
		app.deletemessage(
			chat_id: result.callback_query.message.chat.id
			message_id: result.callback_query.message.message_id
		)!
	}
}

['message:starts_with: /my']
pub fn (mut app App) hanlde_my_tracker(result Update) ! {
	mut number := result.message.text.u16()
	if number != 0 {
		mut user := app.db.user_from_result(result)!
		tracker := get_user_tracker_by_id(user, number)
		user.confirm_section = tracker.section_url
		app.db.update_user(user)!
		//if tracker.id != 0 && 
		filter_text := match user.lang {
			'lv' {'Filtrs'}
			'ru' {'Фильтр'}
			else{'Filter'}
		}
		if user.telegram_id == tracker.telegram_id {
			text := '*${tracker.section_name}*\n*${tracker.subcategory_name}*\n${filter_text}: ${tracker.filter}\n${tracker.created_at.format()}'
			reply_markup := get_tracker_handle_button(tracker, user.lang)
			app.sendmessage(
				chat_id: result.message.chat.id
				text: text
				reply_markup: reply_markup
				parse_mode: 'Markdown'
			)!
		}
	}
}

[message:'👁 Select']
pub fn (mut app App) my_select(result Update) ! {
	mut user := app.db.user_from_result(result)!
	app.sendchataction(
		chat_id: result.message.chat.id
		action: 'typing'
	)!
	show_categories(mut app, mut user) or { println(err) }
}

fn show_user_trackers(mut app App, result Update)!{
	app.sendchataction(
		chat_id: result.message.chat.id
		action: 'typing'
	)!
	user := app.db.user_from_result(result)!
	trackers := get_user_trackers(user)
	mut text := match user.lang {
		'lv' {
			'Ja vēlies izdēst visus izsekotājus, ieraksti /stop\nTavi izsekotāji:\n\n'
		}
		'ru' {
			'Для удаления всех трекеров - введи /stop\nТвои трекеры:\n\n'
		}
		else {
			'/stop - For delete all trackers\nYour trackers:\n\n'
		}
	}
	for track in trackers {
		text += '/my${track.id} ${track.section_name} ${track.subcategory_name} *${track.filter}*\n'
	}
	if trackers.len == 0 {
		text += match user.lang {
			'lv' {
				'Tu neko neizseko.'
			}
			'ru' {
				'Ты ничего не отслеживаешь.'
			}
			else {
				"Your don't have trackers."
			}
		}
	} else {
		text += match user.lang {
			'lv' {
				'\n⬆️ Izvēlies savu izsekotāja numuru.'
			}
			'ru' {
				'\n⬆️ Выбери номер своего трекера.'
			}
			else {
				'\n⬆️ Select number of your tracker.'
			}
		}
	}

	app.sendmessage(
		chat_id: result.message.chat.id
		text: text
		parse_mode: 'Markdown'
	)!
}
[message:'📕 My Trackers']
pub fn (mut app App) my_trackers(result Update) ! {
	show_user_trackers(mut app, result)!
}

[message:'/menu']
pub fn (mut app App) on_menu(result Update) ! {
	user := app.db.user_from_result(result)!
	text := match user.lang {
		'lv' {
			'Izvelne zem ievades līnijas...'
		}
		'ru' {
			'Меню под строкой ввода...'
		}
		else {
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
		},
	]
	reply_markup := ReplyKeyboardMarkup{
		keyboard: buttons
		resize_keyboard: true
	}
	app.sendmessage(
		chat_id: result.message.chat.id
		text: '📕 ${text}'
		reply_markup: reply_markup
	)!
}

[message:'/stop']
pub fn (mut app App) on_stop(result Update) ! {
	user := app.db.user_from_result(result)!
	os.rmdir_all('output/trackers/${user.telegram_id}/') or {
		return
	}
	text := match user.lang {
		'lv'{'✔️ Viss ir izdēsts'}
		'ru'{'✔️ Всё удалено'}
		else{'✔️ All Deleted'}
	}
	app.sendmessage(
		chat_id: result.message.chat.id
		text: text
		parse_mode: 'Markdown'
	)!
}
