#!/usr/bin/env -S v

import time
import reader { to_url_str }
import os

fn bot_check(mut bot os.Process) {
	for {
		if !bot.is_alive() {
			mut file := open_file('run_log.txt', 'a') or {
				println(err)
				continue
			}
			file.writeln('Run ${time.now()}') or { println(err) }
			file.close()
			bot.close()
			bot.wait()
			bot = new_process('ssbot')
			bot.run()
		}
		time.sleep(30_000 * time.millisecond)
	}
}

fn parse_check() {
	for {
		// files := walk_ext('output/tables/', '.json')
		user_trackers := walk_ext('output/trackers/', '.json')
		// for f in files {
		// url := to_url_str(f)
		for ut in user_trackers {
			// if file_name(ut) == f.all_after('.com') {
			mut p := new_process('ssparser')
			p.set_args([
				'https://ss.com${to_url_str(file_name(ut).trim_right('.json'))}',
			])
			p.set_redirect_stdio()
			p.run()
			p.wait()
			res := p.stdout_read().trim_indent()
			if res != '' {
				println('res: ${res}')
			}
			// println('pau pau ${ut}')
			//}
		}
		time.sleep(60_000 * time.millisecond)
		//}
	}
}

mut threads := []thread{}
mut bot := new_process('ssbot')
threads << spawn bot_check(mut bot)
threads << spawn parse_check()

threads.wait()
