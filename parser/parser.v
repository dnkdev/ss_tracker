module main

import time
import os

const (
	ss_end_point = 'https://ss.com'
)

fn main() {
	if os.args.len <= 1 {
		exit(1)
	}
	url := os.args[1]
	if !url.starts_with('https://') {
		eprintln('Incorrect url')
		exit(2)
	}
	mut option := '--ads'
	if os.args.len > 2 {
		option = os.args[2]
	}
	if option == '--ads' {
		result := get_ads(url) or {
			eprintln(err)
			exit(3)
		}
		if result == SSAds{} {
			eprintln('Provided url is not ad url ${url}')
			exit(1)
		}
		if result != SSAds{} {
			mut is_new_local := false
			local_table := load_local_table(result.url) or {
				save_local_table(result) or {
					eprintln(err)
					exit(4)
				}
				is_new_local = true
				result
			}
			if result.compare(local_table) && !is_new_local {
				// eprintln('compare error')
				// exit(0)
			}
			ads := result.get_ads_to_number(local_table.get_last_number())
			save_local_table(result)or {
				eprintln(err)
				exit(5)
			}
			distribute_ads(result, ads)
		}
	}
}
