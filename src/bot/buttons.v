module bot

import vtelegram { InlineKeyboardButton, InlineKeyboardMarkup }

pub fn get_select_button(lang string) InlineKeyboardMarkup {
	yes := match lang {
		'lv'{'Jā'}
		'ru'{'Да'}
		else{'Yes'}
	}
	back := match lang {
		'lv'{'Atpakaļ'}
		'ru'{'Назад'}
		else{'Back'}
	}
	mut buttons := [][]InlineKeyboardButton{}
	buttons << [
		InlineKeyboardButton{
			text: back
			callback_data: 'back'
		},
		InlineKeyboardButton{
			text: yes
			callback_data: 'yes'
		}
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_back_button(lang string) InlineKeyboardMarkup {
	text := match lang {
		'lv'{'Atpakaļ'}
		'ru'{'Назад'}
		else{'Back'}
	}
	mut buttons := [][]InlineKeyboardButton{}
	buttons << [
		InlineKeyboardButton{
			text: text
			callback_data: 'back'
		}
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_language_buttons() InlineKeyboardMarkup {
	mut buttons := [][]InlineKeyboardButton{}
	// 'ru':'🇷🇺 Выбрать язык',
	// 'en':'🇺🇸 Select Language',
	// 'lv':'🇱🇻 Izvēlēties valodu'
	buttons << [
		InlineKeyboardButton{
			text: '🇷🇺 Выбрать язык'
			callback_data: 'ru'
		},
	]
	buttons << [
		InlineKeyboardButton{
			text: '🇺🇸 Select Language'
			callback_data: 'en'
		},
	]
	buttons << [
		InlineKeyboardButton{
			text: '🇱🇻 Izvēlēties valodu'
			callback_data: 'lv'
		},
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}
