module bot

import net.http
import net.html
import time

const (
	endpoint = 'https://ss.com'
)

fn ss_scrap() {
	scrap_url := '/ru/transport/cars/audi/'
	// test_url := '/ru/home-stuff/searches-finds/search-of-the-stolen-moto-and-cars/'//'/ru/transport/cars/audi/'
	config := http.FetchConfig{
		user_agent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0'
	}
	time.sleep(500 * time.millisecond)
	response := http.fetch(http.FetchConfig{ ...config, url: bot.endpoint + scrap_url }) or {
		// response := http.get(endpoint+test_url) or {
		eprintln(err)
		http.Response{}
	}
	println('${response.status_code}')
	// ut result := ''
	mut document := html.parse(response.body)
	// tags := document.get_tag_by_attribute('data')
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
					// result += tag.str()
					number := v.split('_')[1]
					mut text_tag := tag.get_tags_by_attribute_value('id', 'dm_${number}')
					if text_tag[0].content == '' {
						text_tag[0] = text_tag[0].children[0]
					}
					mut href := text_tag[0].attributes['href']
					text := text_tag[0].content.trim_space().trim_indent()
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
	println(ads)
	println(ads.len)
	// println(tags.len)
	base := SSBase{
		head_line: headers
		url: scrap_url
		data: ads
		updated_at: time.now()
	}
	base.save_ss_table() or { eprintln(err) }
}
