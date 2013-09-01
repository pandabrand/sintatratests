require 'sinatra'
require 'sinatra/contrib'
require 'sinatra/flash'

require 'sass'
require 'pony'
require 'coffee-script'

require './song'
require './sinatra/auth'

require 'sinatra/reloader' if development?
require 'v8' if development?

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address    => 'smtp.gmail.com',
  		:email_user_name	=> 'pandabrand',
  		:email_password		=> 'secret',
  		:email_domain			=> 'localhost.localdomain'
end

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address    => 'smtp.sendgrid.net',
  		:email_user_name	=> ENV['SENDGRID_USERNAME'],
  		:email_password		=> ENV['SENDGRID_PASSWORD'],
  		:email_domain			=> 'heroku.com'
end

set :public_folder, 'assets'
set :views, 'templates'
set :session_secret, 'this is a long boring secret to the make it hard to figure out'

before do
	set_title
end

get('/styles.css'){ scss :styles }
get('/js/application.js'){ coffee :application }

get '/' do
  erb :home
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

post '/contact' do
	send_message
	flash[:notice] = "Thank you for your message. We'll be in touch soon."
	redirect to('/')
end

not_found do
	puts request.path_info
  erb :not_found
end

helpers do
  def css(*stylesheets)
  	stylesheets.map do |stylesheet|
  		"<link href=\"/#{stylesheet}.css\" media=\"screen, production\" rel=\"stylesheet\" />"
  	end.join
  end
  
  def current?(path='/')
  	(request.path==path || request.path==path+'/') ? "current" : nil
  end
  
  def set_title
  	@title ||= "Songs By Sinatra"
  end
  
  def send_message
  	Pony.mail(
  		:from => params[:name] + "<" + params[:email] + ">",
  		:to => 'pandabrand@gmail.com',
  		:subject => params[:name] + " has contacted you",
  		:body => params[:message],
  		:port => '587',
  		:via => :smtp,
  		:via_options => {
  			:address	=> 'smtp.gmail.com',
  			:port			=> '587',
  			:enable_srttls_auto	=> 'true',
  			:user_name	=> 'pandabrand',
  			:password	=> 'secret',
  			:authentication => :plain,
  			:domain 	=> 'localhost.localdomain'
  	})
  end
end