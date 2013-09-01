require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/extension'

module Sinatra

	module Auth
	
		module Helpers
			def authorized?
				session[:admin]
			end
			
			def protected!
				halt 401, erb(:unauthorized) unless authorized?
			end
			
		end
		
		def self.registered(app)
			app.helpers Auth::Helpers
			
			app.enable :sessions
			
			app.set :user => 'frank',
							:password => 'sinatra'
			
			app.get '/login' do
				erb :login
			end
			
			app.post 'login' do
				if params[:username] == settings.username && params[:password] == settings.password
					session[:admin] = true
					flash[:notice] = "You are now logged in as #{settings.username}"
					redirect to('/songs')
				else
					flash[:notice] = "The username or password you entered are incorrect."
					erb :login
				end
			end
			
			app.get 'logout' do
				session[:admin] = nil
				flash[:notice] = "You have now logged out."
				redirect to('/')
			end
		end

	end
	register Auth
	
end