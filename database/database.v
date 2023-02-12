module database

import vtelegram { Result }
import db.sqlite { DB } // can change to 'db.mysql', 'db.pg'
import time

pub struct Database {
	DB
}

pub fn result_to_user(result Result) User {
	mut message := result.message
	if message.chat.id == 0 {
		message = result.query.message
	}
	user := User{
		telegram_id: message.chat.id
	}
	return user
}

pub fn create_db_connection() !Database {
	mut db := sqlite.connect('app.db')!
	sql db {
		create table User
	}
	// sql db {
	// 	create table Tracker
	// }
	return Database{db}
}

// User database functions

pub fn (db Database) load_category(user User) string {
	result := sql db {
		select from User where telegram_id == user.telegram_id
	}
	if result.len == 0 {
		return ''
	}
	return result[0].category
}

pub fn (db Database) save_category(user User) {
	sql db {
		update User set category = user.category, updated_at = time.now() where telegram_id == user.telegram_id
	}
}

pub fn (db Database) save_language(user User) ! {
	sql db {
		update User set lang = user.lang, updated_at = time.now() where telegram_id == user.telegram_id
	}
}

pub fn (db Database) update_user(user User) ! {
	sql db {
		update User set confirm_section_name = user.confirm_section_name, category = user.category,
		category_name = user.category_name, confirm_section = user.confirm_section, sub_category_name = user.sub_category_name,
		sub_category = user.sub_category, bot_message_id = user.bot_message_id, updated_at = time.now()
		where telegram_id == user.telegram_id
	}
}

pub fn (db Database) user_from_result(result Result) !User {
	user := result_to_user(result)
	data := sql db {
		select from User where telegram_id == user.telegram_id
	}
	if data == [] {
		db.add_user(user)
		return user
	}
	return data[0]
}

pub fn (db Database) user_get(user User) !User {
	mut data := sql db {
		select from User where telegram_id == user.telegram_id
	}
	return data[0]
}

pub fn (db Database) user_exist(user User) bool {
	result := sql db {
		select from User where telegram_id == user.telegram_id
	}
	if result == [] {
		return false
	}
	return true
}

pub fn (db Database) add_user(user User) {
	sql db {
		insert user into User
	}
}

//
// Tracker database functions
//

// pub fn (db Database) user_tracker_exists(user User, tr Tracker) bool {
// 	result := sql db {
// 		select from Tracker where telegram_id == user.telegram_id && section_url == tr.section_url
// 	}
// 	if result.len == 0 {
// 		return false
// 	}
// 	for r in result {
// 		if r.filter == '' {
// 			return true
// 		}
// 	}
// 	return false
// }

// pub fn (db Database) add_user_tracker(user User, tr Tracker) bool {
// 	if db.user_tracker_exists(user, tr) {
// 		return false
// 	}
// 	if !os.exists('output/trackers/${user.telegram_id}/') {
// 		os.mkdir_all('output/trackers/${user.telegram_id}/') or { return false }
// 	}
// 	os.write_file('output/trackers/${user.telegram_id}/${reader.to_safe_str(tr.section_url)}.json',
// 		json.encode_pretty(tr)) or { return false }

// 	sql db {
// 		insert tr into Tracker
// 	}
// 	return true
// }

// pub fn (db Database) update_tracker_filter_by_id(trid i64, filter string) bool {
// 	sql db {
// 		update Tracker set filter = filter where id == trid
// 	}
// 	return true
// }

// pub fn (db Database) get_users_by_tracker_url(url string, filter string) []User {
// 	trackers := sql db {
// 		select from Tracker where section_url == url
// 	}
// 	mut users := []User{}
// 	for t in trackers {
// 		if t.section_url == url {
// 			if t.filter == '' {
// 				users << User{
// 					telegram_id: t.telegram_id
// 					sub_category_name: t.subcategory_name
// 					confirm_section_name: t.section_name
// 				}
// 			} else {
// 				words := t.filter.split(' ')
// 				if filter.contains_any_substr(words) {
// 					users << User{
// 						telegram_id: t.telegram_id
// 						sub_category_name: t.subcategory_name
// 						confirm_section_name: t.section_name
// 					}
// 				}
// 			}
// 		}
// 	}
// 	return users
// }

// pub fn (db Database) get_trackers() []Tracker {
// 	trackers := sql db {
// 		select from Tracker
// 	}
// 	return trackers
// }

// pub fn (db Database) delete_tracker_with_url(url string) bool {
// 	for file_name in os.walk_ext('output/trackers/', '.json') {
// 		os.rm(file_name) or { continue }
// 	}
// 	sql db {
// 		delete from Tracker where section_url == url
// 	}
// 	return true
// }

// pub fn (db Database) delete_tracker_with_id(id i64) bool {
// 	sql db {
// 		delete from Tracker where id == id
// 	}
// 	return true
// }

// pub fn (db Database) get_trackers_by_id(id i64) Tracker {
// 	tracker := sql db {
// 		select from Tracker where id == id
// 	}
// 	if tracker.id == 0 {
// 		return Tracker{}
// 	}
// 	return tracker
// }

// pub fn (db Database) get_trackers_by_user(user User) []Tracker {
// 	data := sql db {
// 		select from Tracker where telegram_id == user.telegram_id
// 	}
// 	return data
// }
