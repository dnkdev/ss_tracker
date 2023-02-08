module database

import time

[table: 'trackers']
pub struct Tracker {
	id          i64    [primary; sql: serial]
	telegram_id i64		
	section_url string
mut:
    created_at  time.Time   [sql_type: 'DATETIME']
    //deleted_at  time.Time   [sql_type: 'DATETIME']
}