module main

import vtelegram {InlineKeyboardMarkup,InlineKeyboardButton}

fn get_ad_buttons(ad Ad)InlineKeyboardMarkup{
	mut buttons := [][]InlineKeyboardButton{}
	if ad.ad_url.len > 64 {
		buttons << [
			InlineKeyboardButton{
				text: 'Link ➡️'
				url: '${ss_end_point}${ad.ad_url}'
			},
		]
	}
	else {
		buttons << [
			InlineKeyboardButton{
				text: 'Full Text'
				callback_data: '${ad.ad_url}'
			},
		]
	}
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}