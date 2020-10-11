require 'faraday'
require 'faraday_middleware'

require_relative 'twitter_client/tweet'

class TwitterClient
  include Dry::Monads[:result]

  class ClientError < StandardError
    def initialize(response)
      super("Non-success response received, status code #{response.status}: #{response.body}")
    end
  end

  def initialize(bearer_token: ENV.fetch('TWITTER_BEARER_TOKEN'))
    @conn = initialize_connection(bearer_token)
  end

  # Success(TwitterClient::Tweet)
  # Failure(:not_found, :invalid_id, :unexpected_response)
  def get_tweet(id)
    response = conn.get('tweets', {
      ids: id,
      'tweet.fields': 'in_reply_to_user_id,author_id,created_at,conversation_id',
    })

    if !response.success?
      case response.status
      when 400
        return Failure(:invalid_id)
      else
        return Failure(:unexpected_response)
      end
    end

    errors = response.body['errors']
    if errors && errors.first.fetch('title') == 'Not Found Error'
      return Failure(:not_found)
    end

    Success(TwitterClient::Tweet.new(response.body.fetch('data').first))
  end

  private

  attr_reader :conn

  def initialize_connection(bearer_token)
    Faraday.new('https://api.twitter.com/2') do |conn|
      conn.authorization 'Bearer', bearer_token
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: false}
      conn.adapter :net_http
    end
  end
end
