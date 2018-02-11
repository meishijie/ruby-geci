require 'sqlite3'
db = SQLite3::Database.new("lyc.db")
db.execute("select * from lyc") do |row|
	p row
end
db.close