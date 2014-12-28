require 'mysql' # uses the ruby-mysql gem
class DbInserter
	
	# Inserts the dataset into the predefined table in the database.
	# The data inserted is incoded into UTF-8 and hence will require
	# a mechanism (like the mosaheh gem) to repair while retranslating
	# to arabic flawlessly.
	def insert(dataset)
		conn = get_connection
		dataset['type'] = dataset['type'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['area'] = dataset['area'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['city'] = dataset['city'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['phone'] = dataset['phone'].force_encoding("ISO-8859-1").encode("UTF-8")

		stmt = conn.prepare('insert into contents(url, type, area, city, phone) values(?,?,?,?,?)')
		stmt.execute dataset['url'], dataset['type'], dataset['area'], dataset['city'], dataset['phone']
		conn.close!
	end

	def get_scanned_urls!(array)
		conn = get_connection
		conn.query("select url from contents").each do |col|
			array<<col
		end
		conn.close!
	end

	def get_connection
		dbhost = 'localhost'
		dbuser = 'root'
		dbpwd = ''
		dbname = 'website_data'
		Mysql.connect(dbhost, dbuser, dbpwd, dbname)
	end
end