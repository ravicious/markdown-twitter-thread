require 'sinatra/base'
require 'sinatra/flash'
require 'erubi'
require 'dry-monads'

require_relative 'lib/twitter_client'

class App < Sinatra::Base
  enable :sessions
  set :erb, :escape_html => true
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
    tweet_id = parse_tweet_id(params[:id])

    tweet_result = twitter_client.get_tweet(tweet_id)

    erb :'tweets/show', locals: {
      tweet_result: tweet_result,
    }
  end

  TWEET_ID_REGEX = /(\A|\/)(\d+)\z/

  def parse_tweet_id(string)
    match = TWEET_ID_REGEX.match(string)
    match && match[2]
  end

  def twitter_client
    @twitter_client ||= TwitterClient.new
  end
end

if App.development?
  require 'dotenv/load'
  require 'pry'
end
