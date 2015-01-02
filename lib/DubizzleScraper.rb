require 'nokogiri'
require 'open-uri'


=begin
First find all items in the first page
See mysql for listing; if any found (from the Database) then skip to X else
continue with the next page
X-> From the current items list,
Get the required data
Save data + item name into Database.
=end

class DubizzleScraper

  def initialize
	@ads = []
	@existing = []
	@db = DbInserter.new
	@db.get_scanned_urls!(@existing)
	puts 'found '+@existing.length.to_s+' existing records in db'
  end

  # Find all new ads on the page
  def all_new_ads(url=nil)
	site = 'http://saudi.dubizzle.com'
	url =  site+"/ar/items-for-sale/search/" if(url==nil)
	proceed = true
	while proceed
  		puts "Fetching the ads from "+url
		doc = Nokogiri::HTML(open(url))
		nothing_found = doc.css('d-no-results__heading')
		if(nothing_found.children && nothing_found.children.length>0)
			return
		end
		contents = doc.at_css('.d-listing').css('.d-listing__item')
		puts 'found '+contents.length.to_s+' items to scan.'
		contents.each do |item|
		  text = item.children[1].children[1].children[1].attributes["href"].value
		  text = site+text

		  if(@existing.index(text)!=nil)
			puts 'stopping after getting already known url'
			proceed = false
		  else
		    @ads.push(text)
		  end
		end
		if(doc.css('.u-pager__item--next').children[1] == nil)
			puts 'Completed scanning for lists, proceeding to scrape individual items'
			return
		end
		url = site+doc.css('.u-pager__item--next').children[1].attribute('href').value
		puts 'now crawling to next page for items'
	end
	# all_new_ads(next_page_url)
  end

  def process_all_ads
  	@ads.map { |ad|
  		if(@existing.index(ad)!=nil)
  			puts 'Skipping already known element'
  		else
  			begin
				info = extract_information(ad)
				@db.insert(info)
  			rescue Exception => e
  				puts 'Error on scraping '+ad
  			end
		end
  	}
  end

  def test_one_page
  	details = extract_information(@ads[0])
  end

  # Extract the desired information from within the provided ad
  def extract_information(ad)
  	extrated = {}
  	puts "Extracting: "+ad
  	page = Nokogiri::HTML(open(ad))
  	area = ''
  	city = ''
  	details = []
  	page.css(".u-ml__val").each do |elem|
  	  details<<elem.text
  	  # if(elem.text.index('،')!=nil)
  	  # 	puts 'received city info. as '+elem.text
  	  # 	city= elem.text.split('،')[0]
  	  # 	province = elem.text.split('،')[1]
  	  # 	break
  	  # end
  	end
  	links = []
  	page.css(".u-link").each do |link|
  	  links<<link.text
  	end
  	puts 'received details as: '+details[1]+' and splitting at ، '
  	area = details[1].split('،')[1].to_s
  	city = details[1].split('،')[0].to_s
  	phone = page.css('.contact-number').children.text

  	puts "Type is "+links[8]
  	puts "area is "+area+" and city is "+city
  	puts "Phone number: "+ phone
  	extrated["url"] = ad
  	extrated["type"] = links[8]
  	extrated["area"] = area
  	extrated["city"] = city
  	extrated["phone"]= phone

  	return extrated
  end

end

