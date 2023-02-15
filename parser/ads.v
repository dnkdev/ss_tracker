module main

import net.http
import net.html
import time

struct Ad {
	number  int
	ad_url  string
	img_url string
	region  string
	text    string
	columns []string
}

struct SSAds {
	head_line  []string
	url        string
	data       []Ad
	updated_at time.Time
}

fn (ads SSAds) compare(comp_ads SSAds) bool {
	if ads.data.len > 0 && comp_ads.data.len > 0 {
		if ads.data[0].number == comp_ads.data[0].number {
			return true
		}
	}
	return false
}

fn (ads SSAds) get_last_number() int {
	if ads.data.len > 0 {
		return ads.data[0].number
	}
	return 0
}

// get_ads_to_number Get all last ads from latest to the existed number
fn (ads SSAds) get_ads_to_number(number int) []Ad {
	mut r_ads := []Ad{}
	for ad in ads.data {
		if ad.number == number {
			break
		}
		r_ads << ad
	}
	if r_ads.len == ads.data.len { // check for removed ad
		for i, ad in ads.data {
			if ad.number == r_ads[i].number {
				return r_ads[..i]
			}
		}
	}
	return r_ads
}

fn check_tag_on_headline(main_tag html.Tag) []string {
	mut headers := []string{}
	for tag in main_tag.children {
		for k, v in tag.attributes {
			// println('${k} - ${v}')
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
				break
			}
		}
	}
	return headers
}

fn check_tag_on_ads(main_tag html.Tag) []Ad {
	mut ads := []Ad{}
	for tag in main_tag.children {
		for k, v in tag.attributes {
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
				mut columns := []string{}
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
						columns << column_info
					}
				}
				mut ad := Ad{
					number: number.int()
					ad_url: href
					img_url: img_url
					region: region_save
					text: text
					columns: columns
				}
				ads << ad
			}
		}
	}
	return ads
}

fn get_ads(url string) !SSAds {
	response := http.get(url)!
	if response.status_code == 200 {
		mut document := html.parse(response.body)
		tags := document.get_tag('table')
		for tag in tags {
			head_line := check_tag_on_headline(tag)
			ads := check_tag_on_ads(tag)
			if ads.len > 0 {
				return SSAds{
					head_line: head_line
					url: url
					data: ads
					updated_at: time.now()
				}
			}
		}
		return SSAds{}
	} else {
		return error('get_ads response error ${response.status_code} ${response.status_msg} ${response.header}')
	}
}
