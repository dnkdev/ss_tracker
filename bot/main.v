module main

import log
import os

const (
	log_file_name = 'bot_log.txt'
)

fn main() {
	mut file := os.open_append(log_file_name)!
	mut logger := log.Log{
		level: log.Level.info
		output_target: log.LogTarget.file
		output_file_name: log_file_name
		ofile: file
	}
	start_bot(logger) or {
		// logger.fatal('${err}')
		panic(err)
	}
	file.close()
}
