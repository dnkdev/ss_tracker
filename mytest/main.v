module main

import os

fn main() {
	mut p := os.new_process('parser/parser')
	p.set_args(['1'])
	p.set_redirect_stdio()
	p.run()
	p.wait()
	res := p.stdout_read().trim_indent()
	// res := os.execute('parser/parser')
	println('res: ${res}')
	f := os.ls('output/trackers/')!
	for ff in f {
		println(os.is_dir('output/trackers/${ff}'))
	}
	println(f)
}
