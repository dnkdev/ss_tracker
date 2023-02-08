module bot

import database { User, Tracker }
import time

fn ask_user_track(app App,mut user User, section string, section_name string, subcategory_name string)! {
	mut text := ''
	user.confirm_section = section
	user.confirm_section_name = section_name
	//subcategory := user.sub_category
	text += match user.lang {
		'lv' { '${subcategory_name}\n*${section_name}*\nLai apstiprinātu savu izvēli, nospiediet Jā.\nUz šo čatu jums būs sūtīti visi jauni sludinājumi no izvēlētās sadaļas.' }
		'ru' { '${subcategory_name}\n*${section_name}*\nНажмите Да для подтверждения. Вам будут присылаться все новые объявления из данного раздела.' }
		else { '${subcategory_name}\n*${section_name}*\nTo confirm your choice, click Yes. You will receive all new ads from the chosen section.' }
	}
	reply_markup := get_select_button(user.lang)
	message := app.sendmessage(
		chat_id: user.telegram_id
		text: text
		parse_mode: 'Markdown'
		reply_markup: reply_markup
	)!
	delete_last_message(app, mut user, message.message_id)
	app.db.update_user(user)!
}

fn set_user_track(app App, user User, section string)!{
	println('User track has been set $user.telegram_id $section')
	mut text := ''
	tr := Tracker {
		telegram_id: user.telegram_id
		section_url: section
		created_at: time.now()
	}
	if app.db.add_user_tracker(user, tr) {
		text += match user.lang {
			'lv'{'✅ Sadaļa *${user.confirm_section_name}* tagad tiks izsekota!'}
			'ru'{'✅ Раздел *${user.confirm_section_name}* теперь отслеживается!'}
			else {'✅ Section *${user.confirm_section_name}* is now tracked!'}
		}
	}
	else {
		text += match user.lang {
			'lv'{'‼️ Sadaļa *${user.confirm_section_name}* jau ir izsekošanas režīmā, izvēlaties citu, vai izslēdzat izsekošanu galvenajā izvelnē!'}
			'ru'{'‼️ Раздел *${user.confirm_section_name}* уже отслеживается вами, выберите другой раздел или отключите отслеживание в главном меню!'}
			else {'‼️ Section *${user.confirm_section_name}* is already tracked, you can select another one or turn off track in main menu!'}
		}
	}
	mut to_user := user
	message := app.sendmessage(chat_id:user.telegram_id, text: text, parse_mode: 'Markdown', reply_markup: get_back_button(user.lang))!
	delete_last_message(app, mut to_user, message.message_id)
	app.db.update_user(to_user)!
}
