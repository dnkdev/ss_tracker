module main

import json
import os

const (
	save_dir = 'output/tables'
)

pub fn to_url_str(str string) string {
	return str.replace('_', '/')
}

pub fn to_safe_str(str string) string {
	return str.replace('/', '_')
}

fn save_local_table(table SSAds) ! {
	os.write_file('${save_dir}/${to_safe_str(table.url)}.json', json.encode_pretty(table))!
}

pub fn load_local_table(url string) !SSAds {
	file := os.read_file('${save_dir}/${to_safe_str(url)}.json')!
	data := json.decode(SSAds, file)!
	return data
}
