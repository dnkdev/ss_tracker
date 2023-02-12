module bot

import vtelegram { InlineKeyboardButton, InlineKeyboardMarkup, Result }
import reader { read_second_categories, read_sections }
import database { User }
import net.http
import net.html

[callback_query: 'yes']
fn (mut app App) confirm_user_choice(result Result) ! {
	user := app.db.user_from_result(result)!
	section := user.confirm_section
	section_name := user.confirm_section_name
	// println('Confirm ${section_name} ${section}')
	set_user_track(mut app, user, section, section_name, user.sub_category_name)!
}

[callback_query: 'all_p']
fn (mut app App) all_category_plus(result Result) ! {
	mut user := app.db.user_from_result(result)!
	// section_name := user.confirm_section_name
	section := user.confirm_section
	resp := http.get(end_point + section)!
	if resp.status_code == 200 {
		mut document := html.parse(resp.body)
		// tags := document.get_tags_by_class_name('msg2')
		tags := document.get_tag_by_attribute_value('id', 'head_line')
		if tags.len != 0 {
			app.deletemessage(
				chat_id: result.query.message.chat.id
				message_id: result.query.message.message_id
			)!
			ask_user_track(mut app, mut user, section, user.confirm_section_name, user.sub_category_name)!
		} else {
			text := match user.lang {
				'lv' { 'Nevar šo izdarīt šajā nodaļā.' }
				'ru' { 'Невозможно это выбрать в этом разделе.' }
				else { "Can't do it in this section." }
			}
			app.sendmessage(
				chat_id: user.telegram_id
				text: text
			)!
		}
	}
}

['callback_query: starts_with: p_']
fn (mut app App) confirm_category_plus(result Result) ! {
	url := result.query.data
	mut user := app.db.user_from_result(result)!
	for b in result.query.message.reply_markup.inline_keyboard {
		if b.len > 0 {
			if b[0].callback_data == 'p_${url}' {
				user.sub_category_name += ' ${b[0].text}'
				app.db.update_user(user) or {
					println('update_user confirm_category_plus ${err}')
					return
				}
				break
				// println(b[0].text)
			}
		}
	}
	app.deletemessage(
		chat_id: result.query.message.chat.id
		message_id: result.query.message.message_id
	)!
	ask_user_track(mut app, mut user, url, user.confirm_section_name, user.sub_category_name)!
}

fn check_ss_on_categories_plus(mut app App, mut user User, section string, section_name string, sub_category_name string) InlineKeyboardMarkup {
	response := http.get(end_point + section) or {
		println('check_ss_on_categories_plus ${err}')
		return InlineKeyboardMarkup{}
	}
	if response.status_code == 200 {
		user.confirm_section_name = section_name
		user.confirm_section = section
		user.sub_category_name = sub_category_name
		app.db.update_user(user) or {
			println('update_user check_ss_on_categories_plus ${err}')
			return InlineKeyboardMarkup{}
		}
		mut document := html.parse(response.body)
		tags := document.get_tags_by_class_name('a_category')
		othertags := document.get_tag_by_attribute_value('id', 'head_line')
		if (tags.len > 0 && othertags.len == 0) || section.contains('/transport/') {
			if tags.len > 0 {
				mut buttons := [][]InlineKeyboardButton{}
				for tag in tags {
					buttons << [
						InlineKeyboardButton{
							text: tag.content
							callback_data: 'p_${tag.attributes['href'].replace('/sell/',
								'')}'
						},
					]
				}
				alltext := match user.lang {
					'lv' {
						'🏷 Visas'
					}
					'ru' {
						'🏷 Все'
					}
					else {
						'🏷 All'
					}
				}
				buttons << [
					InlineKeyboardButton{
						text: alltext
						callback_data: 'all_p'
					},
				]
				reply_markup := InlineKeyboardMarkup{buttons}
				return reply_markup
			}
		}
	}
	return InlineKeyboardMarkup{}
}

[starts_with: '/']
fn (mut app App) show_section_choose(result Result) ! {
	mut number := result.message.text.int()
	if number != 0 {
		mut user := app.db.user_from_result(result)!
		category := user.category
		mut reply_markup := InlineKeyboardMarkup{}
		mut text := ''
		if number == 999 {
			println('${user.sub_category_name} ${user.sub_category}')
			ask_user_track(mut app, mut user, '${user.sub_category}today/', user.sub_category_name,
				user.category_name)!
			return
		} else if number < 1000 {
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
				ask_user_track(mut app, mut user, user.sub_category, user.sub_category_name,
					user.category_name)!
				return
			}
			text += match user.lang {
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
			rm := check_ss_on_categories_plus(mut app, mut user, section, section_name,
				user.sub_category_name)
			if rm != InlineKeyboardMarkup{} {
				app.sendmessage(
					chat_id: user.telegram_id
					text: '${section_name}\n⬇️⬇️⬇️'
					parse_mode: 'Markdown'
					reply_markup: rm
				)!
				return
			}
			ask_user_track(mut app, mut user, section, section_name, user.sub_category_name)!
			return
		} // else
		message := app.sendmessage(
			chat_id: user.telegram_id
			text: text
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		)!
		delete_last_message(mut app, mut user, message.message_id)
		app.db.update_user(user)!
	}
	// number != 0
}
