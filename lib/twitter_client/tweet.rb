class TwitterClient
  class Tweet
    def initialize(tweet)
      @tweet = tweet
    end

    def id
      tweet.fetch('id')
    end

    def created_at
      tweet.fetch('created_at')
    end

    def text
      tweet.fetch('text')
    end

    def conversation_id
      tweet.fetch('conversation_id')
    end

    def conversation_starter?
      id == conversation_id
    end

    def in_reply_to_user_id
      tweet['in_reply_to_user_id']
    end

    def author_id
      tweet['author_id']
    end

    private

    attr_reader :tweet
  end
end
