require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require 'sinatra/flash'
require_relative 'sinatra/auth'
require_relative 'asset-handler'


class Song
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :lyrics, Text
  property :length, Integer
  property :released_on, Date
  property :likes, Integer, :default => 0
  
  def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
  end
end

module SongHelpers
	def find_songs
		@songs = Song.all
	end
	
	def find_song
		Song.get(params[:id])
	end
	
	def create_song
		@song = Song.create(params[:song])
	end
end

class SongController < Sinatra::Base
	use AssetHandler
	enable :method_override
	register Sinatra::Flash
	register Sinatra::Auth
	helpers SongHelpers
	
	set :public_folder, 'assets'
	set :views, 'templates'
	
	configure do
		enable :sessions
		set :username, 'frank'
		set :password, 'sinatra'
	end

	configure :development do
		DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
	end

	configure :production do
		DataMapper.setup(:default, ENV['DATABASE_URL'])
	end

	before do
		set_title
	end
	
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

	get '/' do
		find_songs
		erb :songs
	end

	get '/new' do
		protected!
		@song = Song.new
		erb :new_song
	end

	get '/:id' do
		@song = find_song
		erb :show_song
	end

	get '/:id/edit' do
		protected!
		@song = find_song
		erb :edit_song
	end

	put '/:id' do
		protected!
		song = find_song
		if song.update(params[:song])
			flash[:notice] = "Song successfully updated" 
		end
		redirect to("/#{song.id}")
	end

	post '/' do
		protected!
		flash[:notice] = "Song successfully added" if create_song
		redirect to("/#{@song.id}")
	end

	delete '/:id' do
		protected!
		if find_song.destroy
			flash[:notice] = "Song deleted"
		end
		redirect to('/')
	end

	post '/:id/like' do
		@song = find_song
		@song.likes = @song.likes.next
		@song.save
		redirect to"/#{@song.id}" unless request.xhr?
		erb :likes, :layout => false
	end
end

DataMapper.finalize

