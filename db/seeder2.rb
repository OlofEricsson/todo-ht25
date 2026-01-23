require 'sqlite3'

udb = SQLite3::Database.new("user.db")


def seed!(udb)
  puts "Using udb file: db/user.db"
  puts "🧹 Dropping old tables..."
  drop_tables(udb)
  puts "🧱 Creating tables..."
  create_tables(udb)
  puts "🍎 Populating tables..."
  populate_tables(udb)
  puts "✅ Done seeding the database!"
end

def drop_tables(udb)
  udb.execute('DROP TABLE IF EXISTS user')
end


def create_tables(udb)
  udb.execute('CREATE TABLE user (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT, 
              pwd_digest TEXT)')
end
 
def populate_tables(udb)
  udb.execute('INSERT INTO user (id, username, pwd_digest) VALUES (0, "admin", "admin")')
end

seed!(udb)