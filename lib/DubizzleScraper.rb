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

  # Find all the ads on the page
  def all_ads(url=nil)
  	puts "Fetching the ads from the page"
	@ads = []
	site = 'http://saudi.dubizzle.com'
	url =  site+"/en/items-for-sale/search/" if(url==nil)
	doc = Nokogiri::HTML(open(url))
	contents = doc.at_css('.d-listing').css('.d-listing__item')
	contents.each do |item|
	  text = item.children[1].children[1].children[1].attributes["href"].value
	  # puts site+text
	  @ads.push(site+text)
	end
  end

  def process_all_ads
  	@ads.map { |ad| extract_information(ad) }
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

  	area = details[1].split('،')[0]
  	city = details[1].split('،')[1]
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

