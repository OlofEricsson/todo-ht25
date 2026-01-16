require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'

enable :sessions



# Routen /
get '/' do
  redirect "/todos"
end


get("/todos") do
  
  query = params[:q]

  p "Jag skrev #{query}"

  db = SQLite3::Database.new("db/todos.db")

  db.results_as_hash = true

  @datados = db.execute("SELECT * FROM todos WHERE done = 0")

  if query && !query.empty?
    @datados = db.execute("SELECT * FROM todos WHERE name LIKE ?","%#{query}%")
  else
    @datados = db.execute("SELECT * FROM todos WHERE done = 0")
  end

  p @datados

  @datadosdone = db.execute("SELECT * FROM todos WHERE done = 1")

  if query && !query.empty?
    @datadosdone = db.execute("SELECT * FROM todos WHERE name LIKE ?","%#{query}%")
  else
    @datadosdone = db.execute("SELECT * FROM todos WHERE done = 1")
  end

  p @datadosdone

  slim(:index)

end

post ("/todos/:id/done") do
  id = params[:id]

  db = SQLite3::Database.new("db/todos.db")

  db.results_as_hash = true
  
  db.execute("UPDATE todos SET done = 1 WHERE id = ?", id)

  redirect "/todos"
end

post ("/todos/:id/undone") do
  id = params[:id]

  db = SQLite3::Database.new("db/todos.db")

  db.results_as_hash = true
  
  db.execute("UPDATE todos SET done = 0 WHERE id = ?", id)

  redirect "/todos"
end

post("/todos/:id/delete") do

  id = params[:id].to_i
  db = SQLite3::Database.new('db/todos.db')

  db.execute("DELETE FROM todos WHERE id = ?", id)

  redirect("/todos")
end

post("/todo") do 

  new_todo = params[:new_todo]
  description = params[:description]
  
  db = SQLite3::Database.new('db/todos.db')
  db.execute("INSERT INTO todos (name, description) VALUES (?,?)",[new_todo,description])
  
  redirect("/todos")

end

get("/todos/:id/edit") do

  db = SQLite3::Database.new('db/todos.db')
  db.results_as_hash = true
  id = params[:id].to_i
  @special_todo = db.execute("SELECT * FROM todos WHERE id = ?", id).first

  slim(:edit)
      
end

post("/todos/:id/update") do

  id = params[:id].to_i
  name = params[:name]
  description = params[:description]

  db = SQLite3::Database.new('db/todos.db')
  db.execute("UPDATE todos SET name=?, description=? WHERE id=?",[name,description,id])

  redirect("/todos")

end

post('/store') do
	session[:key] = params[:username] 
	redirect to('/view')
end

get('/view') do
	@name = session[:key]

end

post('/login') do
 nameAndSecret = [params[:namn],params[:password]]
 session[:things] = nameAndSecret #Sparas i session
 redirect('/result')#Posten skickas till Geten!
end

get('/result') do
 slim(:result) 
end

#Länk som tömmer session (blir 'nil')
get('/clear_session') do
 session.clear
 slim(:login)
end

get('/register') do
  db = SQLite3::Database.new("db/user.db")
  username = params["username"]
  password = params["password"]
  password_confirmation = params["confirm_password"]

  result = db.execute("SELECT id FROM users WHERE username=?", username)

  if result.empty?
    if password == password_confirmation
      password_digest = BCrypt::Password.create(password)
      p password_digest
      db.execute("INSERT INTO users(username, password_digest) VALUES (?,?)", [username, password_digest])
      redirect('/register_confirmation')
    else
      set_error("Password don't match")
      redirect("/error")
    end
  else
    set_error("Username already exists")
    redirect("/error")
  end
end