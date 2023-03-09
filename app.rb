# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    return erb(:all_albums)
  end

  get "/albums/new" do
    return erb(:album_form)
  end

  get '/albums/:id' do
    id = params[:id]
    repo = AlbumRepository.new
    album = repo.find(id)
    artist_repo = ArtistRepository.new
    artist = artist_repo.find(album.artist_id)
    @artist = artist.name
    
    @title = album.title
    @release_year = album.release_year
    return erb(:id_html)
  end

  post '/albums' do
    if invalid_request_parameters? 
      status 400
      return ''
    end

    html_regex = /^<([a-z]+)([^>]+)*(?:>(.*)<\/\1>|\s+\/>)$/
    params[:title] = params[:title].gsub(html_regex, '')
    params[:release_year] = params[:release_year].gsub(html_regex, '')
    params[:artist_id] = params[:artist_id].gsub(html_regex, '')

    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params[:artist_id]
    repo = AlbumRepository.new
    repo.create(album)
    return erb(:add_album_success)
  end

  get '/artists/new' do
    return erb(:artist_form)
  end

  get '/artists/:id' do
    id = params[:id]
    repo = ArtistRepository.new
    @artist_name = repo.find(id).name
    @artist_genre = repo.find(id).genre
    return erb(:artists_id)
  end

  get "/artists" do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:all_artists)
  end

  post "/artists" do
    if invalid_artist_request_parameters?
      status 400
      return ""
    end

    html_regex = /^<([a-z]+)([^>]+)*(?:>(.*)<\/\1>|\s+\/>)$/
    params[:name] = params[:name].gsub(html_regex, '')
    params[:genre] = params[:genre].gsub(html_regex, '')

    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]
    repo = ArtistRepository.new
    repo.create(artist)
    return erb(:add_artist_success)
  end
end

def invalid_request_parameters?
  return true if params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  return true if params[:title] == "" || params[:release_year] == "" || params[:artist_id] == ""
  return false
end

def invalid_artist_request_parameters?
  return true if params[:name] == nil || params[:genre] == nil
  return true if params[:name] == "" || params[:genre] == ""
  return false
end

