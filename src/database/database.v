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
	sql db {
		create table Tracker
	}
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

// Tracker database functions

pub fn (db Database) user_tracker_exists(user User, tr Tracker) bool {
	result := sql db {
		select from Tracker where telegram_id == user.telegram_id && section_url == tr.section_url
	}
	if result == [] {
		return false
	}
	return true
}

pub fn (db Database) add_user_tracker(user User, tr Tracker) bool {
	if db.user_tracker_exists(user, tr) {
		return false
	}
	sql db {
		insert tr into Tracker
	}
	return true
}

// pub fn (db Database) load_category(user User) string{
