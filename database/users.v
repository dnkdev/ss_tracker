module database

import time

[table: 'users']
pub struct User {
pub:
	id          i64 [primary; sql: serial]
	telegram_id i64
pub mut:
	created_at           time.Time [sql_type: 'DATETIME']
	updated_at           string    [sql_type: 'DATETIME']
	lang                 string    [default: 'en']
	bot_message_id       int       [default: '0']
	category             string    [default: '']
	category_name        string    [default: '']
	sub_category_name    string    [default: '']
	sub_category         string    [default: '']
	confirm_section_name string    [default: '']
	confirm_section      string    [default: '']
	set_custom_filter    bool	   [default: 'false']
}
