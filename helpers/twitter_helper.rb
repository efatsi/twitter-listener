require 'twitter'

::Twitter.configure do |config|
  config.consumer_key       = ENV["JINGLEBOTS_TWITTER_CONSUMER_KEY"]
  config.consumer_secret    = ENV["JINGLEBOTS_TWITTER_CONSUMER_SECRET"]
  config.oauth_token        = ENV["JINGLEBOTS_TWITTER_TOKEN"]
  config.oauth_token_secret = ENV["JINGLEBOTS_TWITTER_SECRET"]
end

class Tweeter

  def initialize(username = "", count = "", message = "")
    @username = username
    @count    = count
    @message  = message
  end

  def send
    Twitter.update(new_message)
  end

  def new_message
    @message.include?("#happyholidays") ? happy_holidays_message.sample : regular_messages.sample
  end

  def happy_holidays_messages
    ["No, happy holidays to YOU #{@username} #{link}",
    "#{@username} Thanks for sharing some cheer, here's a little something for you: #{link}",
    "The latest to spread holiday cheer? That would be #{@username}  #{link}",
    "Holiday cheer from #{@username} captured: #{link}",
    "#{@username} Thanks for spreading some cheer! Here's a gift for you from the JingleBots: #{link}",
    "#{@username} Your cheer was just spoken for all to hear by us! #{link}"
    ]
  end

  def regular_messages
    ["#{@username} Thanks for your holiday wishes, check out your JingleBots souvenir! #{link}",
    "No, happy holidays to YOU #{@username}! #{link}",
    "#{@username} our moment together was special and well-documented: #{link}",
    "#{@username} Here is Random Access to our Memory together - happy holidays: #{link}",
    "32k of holiday memory for you #{@username}! #{link}",
    "#{@username} Thanks for sharing some cheer, here's a little something for you: #{link}",
    "Holiday cheer from #{@username} captured: #{link}",
    "We cherish the moment we had with you #{@username}: #{link}",
    "#{@username} Thanks for spreading some cheer! Here's a gift for you from the JingleBots: #{link}",
    "#{@username} Thanks! Now, a gift for you: #{link} Love, the JingleBots",
    "#{@username} We know you'll want to forever cherish the moment you had with the JingleBots: #{link}",
    "A classic holiday memory for you #{@username}: #{link}"
    ]
  end
  
  def link
    "jinglebots.com/report/#{@count}"
  end
end

class TweetDestroyer

  def self.destroy_jinglebots_tweets
    Twitter.user_timeline('jinglebots', :count => 200, :trim_user => true).each do |tweet|
      Twitter.status_destroy(tweet.id)
    end
    destroy_allemando_tweets
  end

  def self.destroy_allemando_tweets
    Twitter.configure do |config|
      config.consumer_key       = ENV["JINGLEBOTS_TWITTER_CONSUMER_KEY"]
      config.consumer_secret    = ENV["JINGLEBOTS_TWITTER_CONSUMER_SECRET"]
      config.oauth_token        = ENV["ALLEMANDOSAUCE_TWITTER_TOKEN"]
      config.oauth_token_secret = ENV["ALLEMANDOSAUCE_TWITTER_SECRET"]
    end
    
    Twitter.user_timeline('allemandosauce', :count => 200, :trim_user => true).each do |tweet|
      Twitter.status_destroy(tweet.id)
    end
  end

end
