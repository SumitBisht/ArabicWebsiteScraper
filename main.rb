require './lib/DubizzleScraper'
require './lib/DbInserter'
v = DubizzleScraper.new
v.all_new_ads
v.process_all_ads
