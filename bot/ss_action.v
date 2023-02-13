module main

import vtelegram { Result }
import net.html
import time
import encoding.utf8

['callback_query: starts_with: /msg']
fn (mut app App) show_full_text(result Result) ! {
	// println('Wait sec. ${result.query.data}')
	text := get_ss_full_text('/msg${result.query.data}')!
	reply_markup := get_link_button('${ss_end_point}/msg${result.query.data}')
	message := result.query.message
	if message.caption.len + text.len > 1000 {
		mut new_text := ''
		if 1000 - message.caption.len > 0 {
			new_text = text.substr(0, 1000 - message.caption.len)
			a:
			if utf8.is_letter(new_text[new_text.len - 1]) {
				new_text = text.substr(0, new_text.len - 1)
				unsafe {
					goto a
				}
			}
		}
		app.editmessagecaption(
			chat_id: message.chat.id
			message_id: message.message_id
			caption: '*${message.caption}*\n${new_text.trim_indent()}\n*Message is too long*'
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		)!
	} else {
		app.editmessagecaption(
			chat_id: message.chat.id
			message_id: message.message_id
			caption: '*${message.caption}*${text}'
			parse_mode: 'Markdown'
			reply_markup: reply_markup
		)!
	}
}

fn get_ss_full_text(url string) !string {
	time.sleep(100 * time.millisecond)
	response := ss_http_request(url)!
	// println(response.status_code)
	mut document := html.parse(response.body)
	full_one := document.get_tag_by_attribute_value('id', 'content_sys_div_msg')
	full_text := document.get_tag_by_attribute_value('id', 'msg_div_msg')
	// println(full_text)
	mut text := full_one[0].children[0].content
	for t in full_text {
		for tt in t.children {
			text += tt.content
		}
	}
	return text
}
