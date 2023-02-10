module parser

import os
import x.json2 as json

pub fn to_url_str(str string) string {
	return str.replace('_', '/')
}

pub fn to_safe_str(str string) string {
	return str.replace('/', '_')
}

pub const (
	path_dir = 'output/'
)

pub fn read_sections(lang string, chosen_cat string, section string) !map[string]json.Any {
	cat := to_safe_str(chosen_cat)
	sec := to_safe_str(section)
	path := '${parser.path_dir}${lang}/sub_categories/${cat}/${sec}.json'
	result := os.read_file(path)!
	sections := json.raw_decode(result)!
	return sections.as_map()
}

pub fn read_second_categories(lang string, chosen_cat string) !map[string]json.Any {
	cat := to_safe_str(chosen_cat)
	path := '${parser.path_dir}${lang}/${cat}.json'
	result := os.read_file(path)!
	second := json.raw_decode(result)!
	return second.as_map()
}

pub fn read_categories(lang string) !map[string]json.Any {
	path := '${parser.path_dir}${lang}.json'
	// println(path+'.json <-------------')
	result := os.read_file(path)!
	first := json.raw_decode(result)!
	return first.as_map()
}
