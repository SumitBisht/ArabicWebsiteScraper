require 'mysql' # uses the ruby-mysql gem
class DbInserter
	
	# Inserts the dataset into the predefined table in the database.
	# The data inserted is incoded into UTF-8 and hence will require
	# a mechanism (like the mosaheh gem) to repair while retranslating
	# to arabic flawlessly.
	def insert(dataset)
		dbhost = 'localhost'
		dbuser = 'root'
		dbpwd = ''
		dbname = 'website_data'
		conn = Mysql.connect(dbhost, dbuser, dbpwd, dbname)

		dataset['type'] = dataset['type'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['area'] = dataset['area'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['city'] = dataset['city'].force_encoding("ISO-8859-1").encode("UTF-8")
		dataset['phone'] = dataset['phone'].force_encoding("ISO-8859-1").encode("UTF-8")

		stmt = conn.prepare('insert into contents(url, type, area, city, phone) values(?,?,?,?,?)')
		stmt.execute dataset['url'], dataset['type'], dataset['area'], dataset['city'], dataset['phone']
	end
end