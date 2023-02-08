module web

import vweb

['/']
pub fn (mut app App) home() vweb.Result {

	// $vweb.html() in `<folder>_<name> vweb.Result ()` like this
	// render the `<name>.html` in folder `./templates/<folder>`
	return $vweb.html()
}