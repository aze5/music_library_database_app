require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

def reset_artists_table
  seed_sql = File.read('spec/seeds/artists_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  before(:each) do 
    reset_artists_table
    reset_albums_table
  end
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "POST /albums" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/albums', title: 'Trompe le monde', release_year: "1991", artist_id: "1")
      expect(response.status).to eq(200)
    end

    it 'database includes new album' do
      response = post('/albums', title: 'Trompe le monde', release_year: "1991", artist_id: "1")
      get_response = get('/albums/13')
      expect(get_response.status).to eq(200)
      expect(get_response.body).to include 'Trompe le monde'
    end

    it 'returns success message' do
      response = post('/albums', title: 'Trompe le monde', release_year: "1991", artist_id: "1")
      expect(response.status).to eq(200)
      expect(response.body).to eq("<h1>Successfully added album</h1>")
    end

    it "Responds with 400 if input is invalid" do
      response = post('/albums', title: '', release_year: "", artist_id: "")
      expect(response.status).to eq(400)
    end

    it "Responds with 400 if input is invalid" do
      response = post('/albums', title: nil, release_year: nil, artist_id: nil)
      expect(response.status).to eq(400)
    end
  end

  context "GET /albums/new" do
    it "returns 200 OK" do
      response = get("/albums/new")
    end

    it "returns form" do
      response = get('/albums/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Add an album</h1>')
      expect(response.body).to include('<form action="/albums" method="POST">')
    end
  end

  context "GET/albums/:id" do
    it "returns 200 OK" do
      response = get('/albums/1')
      expect(response.status).to eq 200
    end

    it "returns HTML album title" do
      response = get('/albums/1')
      expect(response.body).to include('<h1>Doolittle</h1>')
    end

    it "returns HTML paragraph" do
      response = get('/albums/1')
      expect(response.body).to include('<p>')
      expect(response.body).to include('</p>')
    end

    it "returns release year" do
      response = get('/albums/13')
      expect(response.body).to include('Release year: 1991')
    end

    it "returns artist name" do
      response = get('/albums/13')
      expect(response.body).to include('Artist: Pixies')
    end
  end

  context "GET /albums" do
    it "returns 200 OK" do
      response = get("/albums")
      expect(response.status).to eq 200
    end

    it "returns HTML header" do
      response = get("/albums")
      expect(response.body).to include("<h1>Albums</h1>")
    end


    it "outputs fifth element in albums list as a link" do
      response = get("/albums")
      expect(response.body).to include('<a href="/albums/5">Bossanova </a>')
      
    end

    it "outputs last element in albums list as a link" do
      response = get("/albums")
      expect(response.body).to include('<a href="/albums/12">Ring Ring </a>')
    end

    it "outputs first element in albums list as a link" do
      response = get("/albums")
      expect(response.body).to include('<a href="/albums/1">Doolittle </a>')
    end
  end

  context "GET /artists" do
    it "returns 200 OK" do
      response = get('/artists')
      expect(response.status).to eq 200
    end

    it "returns 1st artist with link" do
      response = get('/artists')
      expect(response.body).to include('<a href="/artists/1">Pixies </a>')
    end

    it "returns last artist with link" do
      response = get('/artists')
      expect(response.body).to include('<a href="/artists/4">Nina Simone </a>')
    end
  end

  context "POST /artists" do
    it "returns 200 OK" do
      response = post('/artists', name: 'Dave', genre: 'rap')
      expect(response.status).to eq 200
    end

    it "adds an artist to database" do
      response = post('/artists', name: 'Dave', genre: 'rap')
      get_response = get('/artists')
      expect(get_response.body).to include('<a href="/artists/5">Dave </a>')
    end

    it 'returns success message' do
      response = post('/artists', name: 'Dave', genre: 'rap')
      expect(response.status).to eq(200)
      expect(response.body).to eq("<h1>Successfully added artist</h1>")
    end

    it "Responds with 400 if input is invalid" do
      response = post('/artists', name: nil, genre: nil)
      expect(response.status).to eq(400)
    end

    it "Responds with 400 if input is invalid" do
      response = post('/artists', name: "", genre: "")
      expect(response.status).to eq(400)
    end
  end

  context "GET /artists/new" do
    it "returns 200 OK" do
      response = get("/artists/new")
      expect(response.status).to eq 200
    end

    it "returns form" do
      response = get("/artists/new")
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Add an artist</h1>')
      expect(response.body).to include('<form action="/artists" method="POST">')
    end
  end

  context "GET /artists/:id" do
    it "returns 200 Ok" do
      response = get('/artists/1')
      expect(response.status).to eq 200
    end

    it "outputs name and genre" do
      response1 = get('/artists/1')
      expect(response1.body).to include('Pixies')
      expect(response1.body).to include('Genre: Rock')
      
      response2 = get('/artists/2')
      expect(response2.body).to include('ABBA')
      expect(response2.body).to include('Pop')
    end
  end
end
