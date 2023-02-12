module main

import vtelegram as vt
import os
import log
import database { Database, create_db_connection }

struct App {
	vt.Bot
	db.Database
}

const (
	ss_end_point = 'https://ss.com'
)

fn get_key() !string {
	file := os.read_file('config.json')!
	key := json2.raw_decode(file)!.as_map()
	return key['key']!.str()
}

pub fn start_bot(logger log.Log) !App {
	token := get_key()!
	mut app := App{
		token: token
	}
	app.log = logger
	set_bot_commands(mut app)!
	vt.poll(mut app,
		dry_start: true
		delay_time: 1000
		timeout: 11
		allowed_updates: [
			'message',
			'callback_query',
		]
	)
	return app
}
