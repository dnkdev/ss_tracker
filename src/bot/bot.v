module bot

import vtelegram as vt
import database { Database, create_db_connection }
import x.json2
import os

struct App {
	vt.Bot
	db Database
}

const (
	end_point = 'https://ss.com'
)

[time_event: 60_000]
fn (app App) handle_ss_requests() {
	trackers := app.db.get_trackers()
	for tracker in trackers {
		ss_scrap(app, tracker.section_url)
	}
}

pub fn start_bot() !App {
	db := create_db_connection()!
	file := os.read_file('config.json')!
	key := json2.raw_decode(file)!.as_map()
	token := key['key']!
	mut app := App{vt.Bot{
		token: token.str()
	}, db}
	set_bot_commands(app) !
	vt.poll(app, delay_time: 1000) !
	// or {
	// 	eprintln(err)
	// 	flush_stdout()
	// }
	return app
}
