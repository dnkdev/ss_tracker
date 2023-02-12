module bot

import vtelegram { Result,InlineKeyboardMarkup,InlineKeyboardButton }
import net.html
import time
import encoding.utf8

['callback_query: starts_with: /msg']
fn (mut app App) show_full_text(result Result) ! {
	//println('Wait sec. ${result.query.data}')
	text := get_ss_full_text('/msg${result.query.data}')!
	reply_markup := get_link_button('$bot.end_point/msg${result.query.data}')
	message := result.query.message
	if message.caption.len + text.len > 1000 {
		mut new_text := ''
		if 1000 - message.caption.len > 0{
			new_text = text.substr(0,1000 - message.caption.len)
			a:
			if utf8.is_letter(new_text[new_text.len - 1]){
				new_text = text.substr(0, new_text.len - 1)
				unsafe{
					goto a
				}
			}
		}
		app.editmessagecaption(
			chat_id:message.chat.id
			message_id:message.message_id
			caption:'*${message.caption}*\n${new_text}\n*Message is too long*'
			parse_mode: 'Markdown'
			reply_markup:reply_markup
		)!
	}
	else {
			app.editmessagecaption(
			chat_id:message.chat.id
			message_id:message.message_id
			caption:'*$message.caption*$text'
			parse_mode: 'Markdown'
			reply_markup:reply_markup
		)!
	}
}
fn get_ss_full_text(url string) !string {
	time.sleep(100*time.millisecond)
	response := ss_http_request(url)!
	//println(response.status_code)
	mut document := html.parse(response.body)
	full_one := document.get_tag_by_attribute_value('id', 'content_sys_div_msg')
	//println(full[0].children[0].content)
	full_text := document.get_tag_by_attribute_value('id', 'msg_div_msg')
	//println(full_text)
	mut text := full_one[0].children[0].content
	for t in full_text{
		for tt in t.children{
			text += tt.content
		}
	}
	
	//os.write_file('result.html', full_text[0].content)!
	
	//text = string_from_wide(text)
	return text//enchtml.escape(text.replace('“',''),enchtml.EscapeConfig{true})
}


fn distribute_to_users(mut app App, text string,new_base SSBase, i int, scrap_url string) {
	mut buttons := [][]InlineKeyboardButton{}
	if new_base.data[i][1].len > 64 {
		buttons << [
			InlineKeyboardButton{
				text: 'Link ➡️'
				url: '${bot.end_point}${new_base.data[i][1]}'
			},
		]
	}
	else {
		buttons << [
			InlineKeyboardButton{
				text: 'Full Text'
				callback_data: '${new_base.data[i][1]}'
			},
		]
	}
	reply_markup := InlineKeyboardMarkup{buttons}
	// mut text := '${new_base.data[i][3]}\n${new_base.data[i][4]}\n${new_base.data[i][5]}\n${new_base.data[i][6]}\n${new_base.data[i][7]}'
	users := app.db.get_users_by_tracker_url(scrap_url, new_base.data[i][3])
	for u in users {
		// app.sendmessage(
		// 	chat_id: u.telegram_id
		// 	text: '${u.sub_category_name}\n*${u.confirm_section_name}*\n\n${text}\n\n[Link](${bot.end_point}${new_base.data[i][1]})'
		// 	parse_mode: 'Markdown'
		// ) or { println('Distribution failed on ${u.telegram_id}') }
		app.sendphoto(
			chat_id: u.telegram_id
			photo: '${new_base.data[i][2]}'
			caption: '${u.sub_category_name}\n*${u.confirm_section_name}*\n\n${new_base.data[i][4]}\n\n${text}' //[Link](${bot.end_point}${new_base.data[i][1]})
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		) or { println('Distribution failed on ${u.telegram_id}') }
	}
}