require 'dm-core'
require 'dm-migrations'

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
helpers SongHelpers

DataMapper.finalize

get '/songs' do
  find_songs
  erb :songs
end

get '/songs/new' do
	protected!
  @song = Song.new
  erb :new_song
end

get '/songs/:id' do
  @song = find_song
  erb :show_song
end

get '/songs/:id/edit' do
	protected!
  @song = find_song
  erb :edit_song
end

put '/songs/:id' do
	protected!
  song = find_song
  if song.update(params[:song])
  	flash[:notice] = "Song successfully updated" 
  end
  redirect to("/songs/#{song.id}")
end

post '/songs' do
	protected!
 	flash[:notice] = "Song successfully added" if create_song
  redirect to("songs/#{@song.id}")
end

delete '/songs/:id' do
	protected!
  if find_song.destroy
  	flash[:notice] = "Song deleted"
  end
  redirect to('/songs')
end

post '/songs/:id/like' do
	@song = find_song
	@song.likes = @song.likes.next
	@song.save
	redirect to"/songs/#{@song.id}" unless request.xhr?
	erb :likes, :layout => false
end