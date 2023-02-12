module main

import bot
import log
import os

const (
	log_file_name = 'bot_log.txt'
)
fn main() {
	mut file := os.open_append(log_file_name)!
	mut logger := log.Log{
		level: log.Level.debug
		output_target: log.LogTarget.both
		output_file_name: log_file_name
		ofile: file
	}
	bot.start_bot(logger) or {
		// logger.fatal('${err}')
		panic(err)
	}
	file.close()
}
