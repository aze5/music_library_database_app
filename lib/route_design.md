# POST /albums Route Design Recipe


## 1. Route Signature

method:
POST

path: 
/albums

Body params:
title, 
release_year,
artist_id


## 2. Response

Response when the album is successfully created: 200 OK 

## 3. Examples


```
# Request:

POST /albums?title=Trompe%20le%20monde&release_year=1991&artist_id=1

# Expected response:

200 OK
```

## 4. Encode as Tests Examples

```ruby
# EXAMPLE
# file: spec/integration/application_spec.rb

require "spec_helper"

describe Application do
  include Rack::Test::Methods

  let(:app) { Application.new }

  context "POST /albums" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/albums' title: 'Trompe le monde', release_year: 1991, artist_id: 1)

      expect(response.status).to eq(200)
    end

    it 'includes new album' do
      response = get('/albums/13')

      expect(response.status).to eq(200)
      # expect(response.body).to eq(expected_response)
    end
  end
end
```

