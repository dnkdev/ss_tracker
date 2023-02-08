module bot

import vtelegram as vt
import database { Database, create_db_connection }

struct App {
	vt.Bot
	db Database
}

[time_event: 60_000]
fn (app App) handle_requests() {
	ss_scrap()
}

const do_job_time = i64(10)

pub fn start_bot() !App {
	db := create_db_connection()!
	mut app := App{vt.Bot{
		token: '5401623750:AAFWXZWx8V-SZIDQUI62AT7agCMs55aLIdU'
	}, db}

	vt.poll(app, delay_time: 1000) or {
		eprintln(err)
		flush_stdout()
	}
	return app
}
