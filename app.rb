require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'





# Routen /
get '/' do
    slim(:index)
end


get("/todos") do
  
  query = params[:q]

  p "Jag skrev #{query}"

  db = SQLite3::Database.new("db/todos.db")

  db.results_as_hash = true

  @datados = db.execute("SELECT * FROM todos")

  if query && !query.empty?
    @datados = db.execute("SELECT * FROM todos WHERE name LIKE ?","%#{query}%")
  else
    @datados = db.execute("SELECT * FROM todos")
  end

  p @datados

  slim(:index)

end