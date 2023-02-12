module bot

import vtelegram as vt
import database { Database, create_db_connection }
import x.json2
import os
import log

struct App {
	vt.Bot
	db Database
}

const (
	end_point = 'https://ss.com'
)

// [time_event: 60_000]
// fn (mut app App) handle_ss_requests() {
// 	trackers := app.db.get_trackers()
// 	for tracker in trackers {
// 		//ss_scrap(mut app, tracker.section_url)
// 		time.sleep(500*time.millisecond)
// 	}
// }

pub fn start_bot(logger log.Log) !App {
	db := create_db_connection()!
	file := os.read_file('config.json')!
	key := json2.raw_decode(file)!.as_map()
	token := key['key']!
	mut app := App{vt.Bot{
		token: token.str()
	}, db}
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
	// or {
	// 	eprintln(err)
	// 	flush_stdout()
	// }
	return app
}
