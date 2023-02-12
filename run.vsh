#!/usr/bin/env -S v

import time

mut p := new_process('ss_tracker')
for {
	time.sleep(10000 * time.millisecond)
	if !p.is_alive() {
		mut file := open_file('run_log.txt', 'a') or {
			println(err)
			continue
		}
		file.writeln('Run ${time.now()}') or { println(err) }
		file.close()
		p.close()
		p.wait()
		p = new_process('ss_tracker')
		p.run()
	}
}
