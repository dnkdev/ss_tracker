#!/usr/bin/env -S v

import time
import reader { to_url_str }
import os

fn bot_check() {
	mut bot := new_process('ssbot')
	for {
		if !bot.is_alive() {
			mut file := open_file('run.log', 'a') or {
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
		time.sleep(60_000 * time.millisecond)
	}
}

fn parse_check() {
	for {
		// files := walk_ext('output/tables/', '.json')
		user_trackers := walk_ext('output/trackers/', '.json')
		mut parsers := []os.Process{}
		for ut in user_trackers {
			mut p := new_process('ssparser')
			parsers << p
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
		}
		time.sleep(90_000 * time.millisecond)
		for mut p in parsers {
			if p.is_alive() {
				println('${time.now()} Process ${p.pid}, ${p.code}, ${p.status} ${p.err}. killing...')
				p.signal_kill()
				res := p.stdout_read().trim_indent()
				if res != '' {
					println('res2: ${res}')
				}
				p.close()
			}
		}
	}
}

mut threads := []thread{}
threads << spawn bot_check()
threads << spawn parse_check()

threads.wait()
