module bot

import net.http
import net.html
import time

fn get_local_table(scrap_url string) !SSBase {
	ss := load_ss_table(scrap_url)!
	return ss
}

fn get_last_number_from_table(ss SSBase) !int {
	if ss != SSBase{} {
		return ss.data[0][0].int()
	} else {
		return 0
	}
}

fn ss_http_request(scrap_url string) !http.Response {
	// config := http.FetchConfig{
	// 	user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0'
	// }
	println(end_point + scrap_url)
	response := http.get(end_point + scrap_url)!
	//http.fetch(http.FetchConfig{ ...config, url: end_point + scrap_url })!
	return response
}

fn ss_scrap(mut app App, scrap_url string) {
	if scrap_url == '' {
		println('SS url for scraping is empty!')
		return
	}

	time.sleep(500 * time.millisecond)
	response := ss_http_request(scrap_url) or {
		app.log.info('ss_http_request $err')
		return
	}
	if response.status_code != 200 {
		println('SS Response Status Code ${response.status_code}')
		return
	}
	// println('${response.status_code}')
	mut document := html.parse(response.body)
	tags := document.get_tag('table')
	mut headers := []string{}
	mut ads := [][]string{}
	// Magic of parsing ss.com
	for main_tag in tags {
		for tag in main_tag.children {
			for k, v in tag.attributes {
				// println('$k - $v')
				if k == 'id' && v == 'head_line' {
					for t in tag.children {
						for ht in t.children {
							for rt in ht.children {
								if rt.content.trim_indent().trim_space() != '' {
									// println('${rt.content}')
									headers << rt.content
								}
							}
						}
					}
				}
				if k == 'id' && v.contains('tr_') && !v.contains('tr_bnr') {
					number := v.split('_')[1]
					mut text_tag := tag.get_tags_by_attribute_value('id', 'dm_${number}')
					if text_tag[0].content == '' {
						text_tag[0] = text_tag[0].children[0]
					}
					mut href := text_tag[0].attributes['href']
					mut text := text_tag[0].content.trim_space().trim_indent()
					region := tag.get_tags_by_class_name('ads_region')
					mut region_save := ''
					if region.len > 0 {
						text += '\n${region[0].content}'
						region_save = region[0].content
					}
					a_img := tag.get_tags_by_attribute_value('id', 'im${number}')
					img := a_img[0].get_tags('img')
					img_url := img[0].attributes['src']
					if href == '' {
						href = a_img[0].attributes['href']
					}
					// println('${text_tag[0].attributes}')
					mut ad_pre := []string{}
					ad_pre << number
					ad_pre << href
					ad_pre << img_url
					ad_pre << region_save
					ad_pre << text
					// println('${number} ${text} ${href}')
					for t in tag.children {
						mut column_info := '' //[]&html.Tag{}
						column_info = t.content
						if t.children.len > 0 {
							for rt in t.children {
								if rt.name == 'b' {
									column_info = rt.content
									if rt.children.len > 0 {
										column_info += '${rt.children[0].content}'
									}
								}
							}
						}
						if column_info.trim_space() != '' {
							ad_pre << column_info
							// println('///// ${column_info}')
						}
					}
					ads << ad_pre
				}
			}
		}
	}
	new_base := SSBase{
		head_line: headers
		url: scrap_url
		data: ads
		updated_at: time.now()
	}
	//
	mut new_local := false
	local_table := get_local_table(scrap_url) or {
		new_base.save_ss_table() or { eprintln(err) }
		new_local = true
		new_base
		// println('Failed load a local table.')
		// return
	}

	//
	//
	//
	if new_base.data.len == 0 {
		println('Wrong table: ${new_base.url}')
		app.db.delete_tracker_with_url(new_base.url)
		return
	}
	last_number := get_last_number_from_table(local_table) or { 0 }

	mut found_last_id := -1
	// println('Last_number = ${last_number}')
	for i, b in new_base.data {
		if b[0].int() == last_number {
			// println('HERE IS LAST ${last_number} ${b[0]}')
			found_last_id = i
			break
		}
	}
	if found_last_id == -1 {
		for i := 0; i < 30; i++ {
			if local_table.data.len > i && new_base.data.len > i
				&& new_base.data[i][0] == local_table.data[i][0] {
				println('SS found another last ${new_base.data[i][0]}')
				found_last_id = i
				break
			}
		}
	}
	if found_last_id == 0 && new_local == false { // 0 here mean that it is last already distributed to users
		// println('SS already distributed ${scrap_url}')
		return
	}
	found_last_id = if found_last_id == -1 { 0 } else { found_last_id }
	mut head_len := new_base.data[0].len
	head_len -= 5
	if head_len > 0 {
		for i := 0; i <= found_last_id; i++ {
			mut text := ''
			// println('$i $headers ${new_base.data[i]}')
			// for a := new_base.data[0].len

			for a in 0 .. head_len {
				if headers.len <= head_len && headers.len != 0 && a < headers.len {
					text += '*${headers[a]}*: '
				}
				if a + 5 < new_base.data[i].len {
					if i < new_base.data.len {
						text += '${new_base.data[i][a + 5]}\n'
					}
				} else {
					text += '\n'
				}
			}

			distribute_to_users(mut app, text, new_base, i, scrap_url)
		}
		new_base.save_ss_table() or { eprintln(err) }
	}
}
