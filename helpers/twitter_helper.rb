require 'twitter'

::Twitter.configure do |config|
  config.consumer_key       = ENV["JINGLEBOTS_TWITTER_CONSUMER_KEY"]
  config.consumer_secret    = ENV["JINGLEBOTS_TWITTER_CONSUMER_SECRET"]
  config.oauth_token        = ENV["JINGLEBOTS_TWITTER_TOKEN"]
  config.oauth_token_secret = ENV["JINGLEBOTS_TWITTER_SECRET"]
end

class Tweeter

  def initialize(username = "", count = "")
    @username = username
    @count    = count
  end

  def send
    Twitter.update(new_message)
  end

  def new_message
    "#{@username} Thanks for your holiday wishes, check out your JingleBots receipt! jinglebots.herokuapp.com/souvenir/#{@count}"
  end

end

class TweetDestroyer

  def self.destroy_all_tweets
    Twitter.user_timeline('jinglebots').each do |tweet|
      Twitter.status_destroy(tweet.attrs["id"])
    end
  end

end
