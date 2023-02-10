module database

import time

[table: 'trackers']
pub struct Tracker {
pub:
	id               i64    [primary; sql: serial]
	telegram_id      i64
	section_name     string
	subcategory_name string
	section_url 	string
	filter 			string [default: '']
pub mut: 
	created_at time.Time [sql_type: 'DATETIME']
	// deleted_at  time.Time   [sql_type: 'DATETIME']
}
