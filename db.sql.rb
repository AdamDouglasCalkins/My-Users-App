#!/usr/env ruby
##
## QWASAR.IO -- rename this db.sql
##
##
##
require 'sqlite3'
require 'sinatra'
require 'rubygems'
set :port, 8080
#set :bind, '0.0.0.0'

enable :sessions

class User
    # constructor
    def initialize()
        #puts "constructor intiated"
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            db.execute "CREATE TABLE IF NOT EXISTS users(Id INTEGER PRIMARY KEY, firstname TEXT, lastname TEXT, age INT, password TEXT, email TEXT)"
            ary2 = db.execute "SELECT Count(*) FROM users;"    
            #print ary2
            if (ary2[0]['Count(*)'] == 0)
                @PrimeKeyNum = 0
            else
                ary = db.execute "SELECT ID FROM users ORDER BY ID DESC LIMIT 1;"    
                @PrimeKeyNum = ary[0]['Id']
            end
            #puts @PrimeKeyNum
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e           
        ensure
            #stm.close if stm #this won't work if you return hash and use array
            db.close if db
        end
    end
    # methods
    def create(firstname, lastname, age, password, email)
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            @PrimeKeyNum += 1
            db.execute "INSERT INTO users (Id, firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?, ?)", @PrimeKeyNum, firstname, lastname, age, password, email
            #puts @PrimeKeyNum
            return (@PrimeKeyNum)
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
    def get(user_id)
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            rs = db.execute "SELECT * FROM users WHERE Id=?", user_id
        
            /rs.each do |row|
                printf "%s %s %s %s %s %s\n", row['Id'], row['firstname'], row['lastname'], row['age'], row['password'], row['email']
            end/ 
            return (rs)
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
    def all()
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            ary = db.execute "SELECT * FROM users"    
                
            /ary.each do |row|
                printf "%s %s %s %s %s %s\n", row['Id'], row['firstname'], row['lastname'], row['age'], row['password'], row['email']
            end/ 
            return (ary)
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
    def update(user_id, attribute, value)
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            db.transaction
            sqlString = "UPDATE users SET " + attribute + "=" + "? WHERE Id=?"
            ary = db.execute sqlString, value, user_id 
            db.commit
            return (get(user_id))
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
    def destroy(user_id)
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            rs = db.execute "DELETE FROM users WHERE Id=?", user_id
        
            n = db.changes
            puts "There has been #{n} changes"
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
    def find(password, email)
        begin
            db = SQLite3::Database.open "my_user_app"
            db.results_as_hash = true
            rs = db.execute "SELECT * FROM users WHERE password=? AND email=?", password, email
        /
            rs.each do |row|
                printf "%s %s %s %s %s %s\n", row['Id'], row['firstname'], row['lastname'], row['age'], row['password'], row['email']
            end /
            return (rs.dig(0, "Id"))
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e    
        ensure
            db.close if db
        end
    end
end

/def getformat(result)
    index = 0
    @Rstr = Array.new
    while (index < result.count)
        Rstr[index] = result.dig(index, "Id").to_s + ' ' + result.dig(index, "firstname") + ' ' + result.dig(index, "lastname") + ' ' +result.dig(index, "age").to_s + ' ' + result.dig(index, "email")
        index += 1
    end
    return (@Rstr)
end/

get '/' do
    inst = User.new
    result = inst.all
    @testerb = result
    erb :index# Looks for `views/index.erb`
end

post('/users') do
    firstname = params['firstname']
    lastname = params['lastname']
    age = params['age']
    password = params['password']
    email = params['email']
    object = User.new
    obj2 = object.create(firstname, lastname, age.to_i, password, email)
    content_type :txt
    obj2.to_s  # or object.to_json
end

get '/users' do
    object = User.new
    /obj2 = object.all
    content_type :txt
    obj2.to_s  # or object.to_json/
    result = object.all
    index = 0
    Rstr = ""
    while (index < result.count)
        Rstr += result.dig(index, "Id").to_s + ' ' + result.dig(index, "firstname") + ' ' + result.dig(index, "lastname") + ' ' +result.dig(index, "age").to_s + ' ' + result.dig(index, "email") + "\n"
        index += 1
    end
    content_type :txt
    Rstr
end

post '/sign_in' do
    email = params['email']
    password = params['password']
    object = User.new
    obj2 = object.find(password, email)
    session[:mydata] = obj2
    session[:logged] = "logged in"
    "Data: #{session[:mydata]}"
end

get '/sign_in2' do
    if (session[:logged] = "logged in")
        "Data: #{session[:mydata]} \nLogged Status: #{session[:logged]}"
    end
end

put '/users' do
    attribute = params['attribute']
    value = params['value']
    checkStr = session[:logged]
    if (checkStr == "logged in")
        data = session[:mydata]
        object = User.new
        obj2 = object.update(data, attribute, value)
    end
    if (checkStr == "logged in")
        'value updated'
    else
        'not logged in'
    end
end

delete '/sign_out' do
    session.clear
end

delete '/users' do 
    if (session[:logged] == "logged in")
        data = session[:mydata]
        object = User.new
        obj2 = object.destroy(data)
    end
    'deletion'
end

/inst = User.new
result = inst.create("Adam", "Calkins", 25, "Chess", "ac@gmail.com")
#result = inst.all
#result = inst.get(1)
#result = inst.update(1, 'lastname', 'Calkins')
#result = inst.create("John", "Doe", 25, "Chess", "JD@gmail.com")
inst.destroy(2)
result = inst.all
print result/