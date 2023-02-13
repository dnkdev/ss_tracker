module database

import time
import os
import json
import reader

//[table: 'trackers']
pub struct Tracker {
pub:
	id           i64 //[primary; sql: serial]
	telegram_id  i64
	section_name string
	section_url  string
pub mut:
	subcategory_name string
	filter           string    //[default: '']
	created_at       time.Time //[sql_type: 'DATETIME']
	// deleted_at  time.Time   [sql_type: 'DATETIME']
}

pub fn delete_user_tracker_with_id(user User, number int) bool {
	trackers := get_user_trackers(user)
	for tr in trackers {
		if tr.id == number {
			os.rm('output/trackers/${user.telegram_id}/${reader.to_safe_str(tr.section_url)}.json') or {
				eprintln('delete_user_tracker_with_id ${err}')
				return false
			}
			return true
		}
	}
	return false
}

pub fn get_user_tracker_by_id(user User, number int) Tracker {
	trackers := get_user_trackers(user)
	for t in trackers {
		if t.id == number {
			return t
		}
	}
	return Tracker{}
}

pub fn update_user_tracker_filter_by_id(user User, trid int, filter string) bool {
	user_dir := 'output/trackers/${user.telegram_id}/'
	trackers := get_user_trackers(user)
	for tr in trackers {
		if tr.id == trid {
			file := os.read_file(user_dir + reader.to_safe_str(tr.section_url) + '.json') or {
				eprintln(err)
				continue
			}
			mut tracker := json.decode(Tracker, file) or {
				eprintln(err)
				continue
			}
			tracker.filter = filter
			add_user_tracker(user, tracker, true)
			return true
		}
	}
	return false
}

pub fn get_user_trackers(user User) []Tracker {
	mut trackers := []Tracker{}
	user_dir := 'output/trackers/${user.telegram_id}/'
	dir_content := os.ls(user_dir) or {
		// eprintln('get_user_trackers ls ${err}')
		return trackers
	}
	for instance in dir_content {
		if !os.is_dir_empty(user_dir) {
			if instance.ends_with('.json') {
				file := os.read_file(user_dir + instance) or {
					eprintln(err)
					continue
				}
				tracker := json.decode(Tracker, file) or {
					eprintln(err)
					continue
				}
				trackers << tracker
			}
		}
	}
	return trackers
}

pub fn user_tracker_exists_by_id(user User, trid int) bool {
	if get_user_tracker_by_id(user, trid) != Tracker{} {
		return true
	}
	return false
}

fn user_tracker_exists(user User, tr Tracker) bool {
	if !os.exists('output/trackers/${user.telegram_id}/') {
		os.mkdir_all('output/trackers/${user.telegram_id}/') or { return false }
		return false
	}
	if !os.exists('output/trackers/${user.telegram_id}/${reader.to_safe_str(tr.section_url)}.json') {
		return false
	}
	return true
}

pub fn add_user_tracker(user User, tr Tracker, forse bool) bool {
	if !forse && user_tracker_exists(user, tr) {
		return false
	}
	os.write_file('output/trackers/${user.telegram_id}/${reader.to_safe_str(tr.section_url)}.json',
		json.encode_pretty(tr)) or { return false }
	return true
}
