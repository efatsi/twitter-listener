require 'rubygems'
require 'twitter/json_stream'
require 'json'
require 'pony'
require 'redis'

## Only one office robot should run this whole file!

load 'helpers/gif_collection.rb'
load 'helpers/twitter_helper.rb'

uri = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

TWITTER = {
  :username     => ENV["JINGLEBOTS_TWITTER_USERNAME"],
  :password     => ENV["JINGLEBOTS_TWITTER_PASSWORD"],
  :search_terms =>["@JingleBots"]
}

EventMachine::run do

  stream = Twitter::JSONStream.connect(
  :path    => '/1/statuses/filter.json',
  :auth    => "#{TWITTER[:username]}:#{TWITTER[:password]}",
  :method  => 'POST',
  :content => "track=#{TWITTER[:search_terms].join(',')}"
  )

  stream.each_item do |item|
    tweet = JSON.parse(item)
    if tweet && tweet["user"]
      data = assemble_data(tweet)
      REDIS.lpush("messages", data.to_json)
      REDIS.set("message:#{data[:count]}", data.to_json)
      REDIS.publish("holiday_messages", data.to_json)
      Tweeter.new(data[:name], data[:count]).send
    end
  end

  
  stream.on_error do |message|
    mail_me("Error", message)
  end

  stream.on_reconnect do |timeout, retries|
    mail_me("Reconnect", "Reconnecting in #{timeout} seconds")
  end

  stream.on_max_reconnects do |timeout, retries|
    mail_me("Max Reconnects", "Failed after #{retries} failed reconnects, at #{timeout} seconds")
  end

  def mail_me(subject, body)
    Pony.mail(
    :from => 'jinglebots@gmail.com',
    :to => 'eli.fatsi@viget.com',
    :subject => subject,
    :body => body,
    :port => '587',
    :via => :smtp,
    :via_options => { 
      :address              => 'smtp.gmail.com', 
      :port                 => '587', 
      :enable_starttls_auto => true, 
      :user_name            => 'jinglebots', 
      :password             => 'Viget123', 
      :authentication       => :plain, 
      :domain               => 'localhost.localdomain'
    })
  end
  
  def assemble_data(tweet)
    count = REDIS.llen("messages") + 1
    {:msg => tweet["text"], :name => "@#{tweet["user"]["screen_name"]}", :count => count, :gif_name => random_gif, :robot_name => random_robot, :time => Time.now, :source => "twitter"}
  end

  def random_robot
    ["klaus", "rudy", "cornelious"].sample
  end

end
