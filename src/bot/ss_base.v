module bot

import json
import time
import os
import parser { to_safe_str, to_url_str }

pub struct SSBase {
	head_line []string
mut:
	url        string
	data       [][]string
	updated_at time.Time
}

const (
	save_dir = 'tables'
)

pub fn (ss SSBase) save_ss_table() ! {
	os.write_file('${bot.save_dir}/${to_safe_str(ss.url)}.json', json.encode_pretty(ss))!
}

pub fn load_ss_table(url string) !SSBase {
	full_url := '${bot.save_dir}/${to_safe_str(url)}.json'
	file := os.read_file(full_url)!
	data := json.decode(SSBase, file)!
	return data
}
