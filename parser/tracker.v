module main

import time
import os
import json

pub struct Tracker {
pub:
	id               i64
	telegram_id      i64
	section_name     string
	subcategory_name string
	section_url      string
	filter           string
pub mut:
	created_at time.Time
}

fn read_user_trackers(user_id int) []Tracker {
	mut trackers := []Tracker{}
	if os.exists('output/trackers/${user_id}/') {
		files := os.walk_ext('output/trackers/${user_id}/', '.json')
		for f in files {
			content := os.read_file('${f}') or { '' }
			tracker := json.decode(Tracker, content) or { Tracker{} }
			if tracker != Tracker{} {
				trackers << tracker
			}
		}
	}
	return trackers
}
