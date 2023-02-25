module main

import vtelegram as vt
import os
import log
import database { Database, create_db_connection }
import x.json2
import net.http

struct App {
	vt.Bot
	db Database
}

const (
	ss_end_point = 'https://ss.com'
)

fn ss_http_request(scrap_url string) !http.Response {
	config := http.FetchConfig{
		user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0'
	}
	response := http.fetch(http.FetchConfig{ ...config, url: ss_end_point + scrap_url })!
	return response
}

fn get_key() !string {
	file := os.read_file('config.json')!
	key := json2.raw_decode(file)!.as_map()
	return key['key']!.str()
}

pub fn start_bot() !App {
	db := create_db_connection()!
	token := get_key()!
	mut app := App{
		vt.Bot{
			token: token
		},
		db
	}
	app.log.set_level(.info)
	app.log.set_full_logpath('./bot.log')
	
	set_bot_commands(mut app)!
	polling_config := vt.PollingConfig[vt.Regular]{
		delay_time: 1000
		timeout: 11
		allowed_updates: [
			'message',
			'callback_query',
		]
	}
	vt.start_polling(mut app, polling_config)
	return app
}
