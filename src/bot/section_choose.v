module bot

import vtelegram { InlineKeyboardMarkup, Result }
import parser { read_second_categories, read_sections }

[callback_query: 'yes']
fn (app App) confirm_user_choice(result Result) ! {
	user := app.db.user_from_result(result)!
	section := user.confirm_section
	section_name := user.confirm_section_name
	println('Confirm ${section_name} ${section}')
	set_user_track(app, user, section, section_name, user.sub_category_name)!
}

[starts_with: '/']
fn (app App) show_section_choose(result Result) ! {
	mut number := result.message.text.int()
	if number != 0 {
		mut user := app.db.user_from_result(result)!
		category := user.category
		mut reply_markup := InlineKeyboardMarkup{}
		mut text := ''
		if number == 999{
			println('$user.sub_category_name $user.sub_category')
			ask_user_track(app, mut user, '${user.sub_category}/today/', user.sub_category_name,
					user.category_name)!
			return
		}
		else if number < 1000 {
			mut count := 1
			mut i := 1
			// app.db.load_category(user)
			// if category == ''{
			// 	return_error(user User)
			// }
			second := read_second_categories(user.lang, category)!
			for k, v in second {
				// println('- ${v.str()}')
				if count == number {
					user.sub_category = v.str()
					user.sub_category_name = k
					text += '*${k}* \n'
					sections := read_sections(user.lang, category, v.str())!
					for name, _ in sections {
						text += '/${1000 + i}. ${name}\n'
						i++
					}
					break
				}
				count++
			}
			if i == 1 {
				println('${user.sub_category} has no sections, only ads')
				ask_user_track(app, mut user, user.sub_category, user.sub_category_name,
					user.category_name)!
				return
			}
			text += match user.lang{
				'lv' { '/999 _Visas nodaļas._\n' }
				'ru' { '/999 _Все разделы._\n' }
				else { '/999 _All sections._\n' }
			}
			text += match user.lang {
				'lv' { '⬆️ *Izvēlaties nodaļu.*❗️' }
				'ru' { '⬆️ *Выберите раздел.*❗️' }
				else { '⬆️ *Choose a section* ❗️' }
			}
			reply_markup = get_back_button(user.lang)
		}
		// if < 1000
		else {
			number -= 1000
			sections := read_sections(user.lang, category, user.sub_category)!
			mut section := ''
			mut section_name := ''
			mut count := 1
			for name, val in sections {
				// println('$name + $val')
				if count == number {
					section_name = name
					section = val.str()
					break
				}
				count++
			}
			ask_user_track(app, mut user, section, section_name, user.sub_category_name)!
			return
		} // else
		message := app.sendmessage(
			chat_id: user.telegram_id
			text: text
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		)!
		delete_last_message(app, mut user, message.message_id)
		app.db.update_user(user)!
	}
	// number != 0
}
