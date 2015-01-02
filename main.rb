require './lib/DubizzleScraper'
require './lib/DbInserter'
v = DubizzleScraper.new
v.all_new_ads
v.process_all_ads

f = File.new('./script-run.log', 'a')
f.write("Script ran at: "+Time.now.to_s)
f.close