module parser

import database {User}
import os
import x.json2 as json

// [params]
// struct CategoryConfig{
// 	lang string = 'en'
// 	category string = '/en/work'
// }
// pub fn get_category(c CategoryConfig) string {	return c.category	}
// [params]
// struct SubCategoryConfig{
// 	lang string = 'en'
// 	subcategory string = '/en/work/are-required/'
// }
pub fn to_url_str(str string) string { 	return str.replace('_', '/')	}
pub fn to_safe_str(str string) string { 	return str.replace('/', '_')	}

pub const (
	path_prefix = 'output/'
	subcategory_dir = 'sub_categories'
)

pub fn read_sections(lang string, chosen_cat string, section string) !map[string]json.Any{
	cat := to_safe_str(chosen_cat)
	sec := to_safe_str(section)
	path := '${path_prefix}${lang}/sub_categories/${cat}/${sec}.json'
	result := os.read_file(path) !
	sections := json.raw_decode(result) !
	return sections.as_map()
}

pub fn read_second_categories(lang string,chosen_cat string) !map[string]json.Any{
	cat := to_safe_str(chosen_cat)
	path := '${path_prefix}${lang}/${cat}.json'
	result := os.read_file(path) !
	second := json.raw_decode(result) !
	return second.as_map()
}

pub fn read_categories(lang string) !map[string]json.Any{
	path := '${path_prefix}${lang}.json'
	//println(path+'.json <-------------')
	result := os.read_file(path) !
	first := json.raw_decode(result) !
	return first.as_map()
}