require 'sinatra'
require 'sass'
require './song'
require 'sinatra/reloader' if development?

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

set :public_folder, 'assets'
set :views, 'templates'
set :session_secret, 'this is a long boring secret to the make it hard to figure out'

get('/stylesheets/styles.css'){ scss :styles }

get '/' do
  erb :home
end

get '/login' do
  erb :login
end

get '/logout' do
	session.clear
	redirect to('/login')
end

get '/about' do
  @title = "All About This Website"
  erb :about
end

get '/contact' do
 erb :contact
end

get '/set/:name' do
  session[:name] = params[:name]
end

get '/get/hello' do
  "Hello #{session[:name]}"
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    erb :login
  end
end

not_found do
  erb :not_found
end