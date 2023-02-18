module main

import vtelegram { InlineKeyboardButton, InlineKeyboardMarkup }
import database { Tracker }
import json
import os

pub fn get_filter_regions_buttons(tracker Tracker, lang string) !InlineKeyboardMarkup {
	file_name := match lang {
		'lv' {
			'output/ss/regions_lv.json'
		}
		'ru' {
			'output/ss/regions_ru.json'
		}
		else {
			'output/ss/regions_en.json'
		}
	}
	content := os.read_file(file_name) or {
		println(err)
		return InlineKeyboardMarkup{}
	}
	data := json.decode([]string, content)!
	mut buttons := [][]InlineKeyboardButton{}
	for d in data {
		buttons << [
			InlineKeyboardButton{
				text: d
				callback_data: 'r_${tracker.id}:${d}'
			},
		]
	}
	customtext := match lang {
		'lv' {
			'🏷 Litotāja filtrs'
		}
		'ru' {
			'🏷 Пользовательский фильтр'
		}
		else {
			'🏷 Custom filter'
		}
	}
	buttons << [
		InlineKeyboardButton{
			text: customtext
			callback_data: 'rcustom_${tracker.id}'
		},
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_tracker_handle_button(tracker Tracker, lang string) InlineKeyboardMarkup {
	mut buttons := [][]InlineKeyboardButton{}
	text_delete := match lang {
		'lv' { '❌ Izdzēst' }
		'ru' { '❌ Удалить' }
		else { '❌ Delete' }
	}
	text_filters := match lang {
		'lv' { '📬 Filtri' }
		'ru' { '📬 Фильтры' }
		else { '📬 Filters' }
	}
	buttons << [
		InlineKeyboardButton{
			text: text_delete
			callback_data: 'd_${tracker.id}'
		},
		InlineKeyboardButton{
			text: text_filters
			callback_data: 'f_${tracker.id}'
		},
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_link_button(url string) InlineKeyboardMarkup {
	mut buttons := [][]InlineKeyboardButton{}
	buttons << [
		InlineKeyboardButton{
			text: 'Link ➡️'
			url: url
		},
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_select_buttons(lang string) InlineKeyboardMarkup {
	yes := match lang {
		'lv' { 'Jā' }
		'ru' { 'Да' }
		else { 'Yes' }
	}
	back := match lang {
		'lv' { 'Atpakaļ' }
		'ru' { 'Назад' }
		else { 'Back' }
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
		},
	]
	reply_markup := InlineKeyboardMarkup{buttons}
	return reply_markup
}

pub fn get_back_button(lang string) InlineKeyboardMarkup {
	text := match lang {
		'lv' { 'Atpakaļ' }
		'ru' { 'Назад' }
		else { 'Back' }
	}
	mut buttons := [][]InlineKeyboardButton{}
	buttons << [
		InlineKeyboardButton{
			text: text
			callback_data: 'back'
		},
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
