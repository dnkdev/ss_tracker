module web

import vweb
import os

struct App {
    vweb.Context
}
pub fn (app App) before_request() {
	println('[vweb] request: ${app.req.method} ${app.req.header.get(.host)} ${app.req.url}')
}
pub fn new_app() &App{
	mut app := &App{}
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
   // app.serve_static('/favicon.ico', 'favicon.ico')
   return app
}
pub fn start_server(app App){
	vweb.run(app, 8080)
}