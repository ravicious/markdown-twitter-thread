require 'sinatra/base'
require 'sinatra/flash'

class App < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  get '/' do
    erb :index
  end

  post '/tweets' do
    id_or_url = params.fetch(:id)
    tweet_id = parse_tweet_id(id_or_url)

    if tweet_id
      redirect to("/tweets/#{tweet_id}")
    else
      flash[:error] = "Couldn't find a Tweet ID in the given URL"
      redirect '/'
    end
  end

  get '/tweets/:id' do
    tweet_id = parse_string_to_integer(params[:id])

    erb :'tweets/show', locals: {
      tweet_id: tweet_id
    }
  end

  TWEET_ID_REGEX = /(\d+)\z/

  def parse_tweet_id(string)
    match = TWEET_ID_REGEX.match(string)
    match && match[0]&.to_i
  end

  def parse_string_to_integer(string)
    int = string.to_i

    string == int.to_s && int
  end
end
