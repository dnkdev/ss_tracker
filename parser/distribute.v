module main

import vtelegram as vt
import os
import json
import x.json2

const (
	tracker_dir = 'output/trackers/'
)

fn process_tracker_file(file_name string, result SSAds, ads []Ad) {
	file := os.read_file(file_name) or {
		eprintln(err)
		return
	}
	tracker := json.decode(Tracker, file) or {
		eprintln(err)
		return
	}
	config := os.read_file('config.json') or {
		eprintln(err)
		return
	}
	key := json2.raw_decode(config) or { return }.as_map()
	token := key['key'] or { return }
	mut app := vt.Bot{
		token: token.str()
	}
	for ad in ads {
		println('${ad.region} == ${tracker.filter}')
		if ad.region != '' && tracker.filter != '' {
			words := tracker.filter.split(' ')
			if !ad.region.contains_any_substr(words) {
				continue
			}
		}
		mut c_text := ''
		for i, h in result.head_line {
			if ad.columns.len > i {
				c_text += '*${h}*: ${ad.columns[i]}\n'
			}
		}
		app.sendphoto(
			chat_id: tracker.telegram_id
			photo: ad.img_url
			caption: '${tracker.subcategory_name}\n*${tracker.section_name}*\n\n${ad.text}\n\n${c_text}' //[Link](${bot.end_point}${new_base.data[i][1]})
			parse_mode: 'Markdown'
			reply_markup: get_ad_buttons(ad)
		) or {
			eprintln(err)
			continue
		}
	}
	// println('${tracker.section_url} send to ${tracker.telegram_id}')
}

fn distribute_ads(result SSAds, ads []Ad) {
	url := result.url
	true_name := to_safe_str(url.all_after('.com')) + '.json'
	if !os.exists(tracker_dir) {
		os.mkdir_all(tracker_dir) or { return }
	}
	dir_content := os.ls(tracker_dir) or { return }
	for instance in dir_content {
		if !os.is_dir_empty(tracker_dir + instance) && os.is_dir(tracker_dir + instance) {
			files := os.walk_ext(tracker_dir + instance, '.json')
			for f in files {
				if f.ends_with(true_name) {
					process_tracker_file(f, result, ads)
				}
			}
		}
	}
}
