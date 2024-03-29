require 'rubygems'
require 'twitter/json_stream'
require 'json'
require 'pony'
require 'redis'

load 'helpers/gif_collection.rb'
load 'helpers/twitter_helper.rb'
load 'helpers/data_mapper.rb'

uri = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :timeout => 60*60*24*7)

TWITTER = {
  :username     => ENV["JINGLEBOTS_TWITTER_USERNAME"],
  :password     => ENV["JINGLEBOTS_TWITTER_PASSWORD"],
}

EventMachine::run do

  stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json',
    :auth    => "#{TWITTER[:username]}:#{TWITTER[:password]}",
    :method  => 'POST',
    :content => "track=#jinglebots"
  )

  stream.each_item do |item|
    tweet = JSON.parse(item)
    if tweet && tweet["user"]
      data = assemble_data(tweet)
      puts "#{data[:name]} - #{data[:msg]}"
      save_message_in_pg(data)
      REDIS.publish("holiday_messages", data.to_json)
      Tweeter.new(data[:name], data[:count], data[:msg]).send unless data[:name] == "@JingleBots"
    end
  end

  stream.on_error do |message|
    mail_me("Error", message)
  end

  stream.on_reconnect do |timeout, retries|
    mail_me("Reconnect", "Twitter listener went down. Reconnecting in #{timeout} seconds. Someone should restart it.")
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

    Pony.mail(
    :from => 'jinglebots@gmail.com',
    :to => 'ben.eckerson@viget.com',
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

  def save_message_in_pg(data)
    Message.create!(data)
  end

  def assemble_data(tweet)
    count = Message.all.length + 1
    {:msg => tweet["text"], :name => "@#{tweet["user"]["screen_name"]}", :count => count, :gif_name => random_gif, :robot_name => random_robot, :time => Time.now, :source => "twitter", :avatar_url => avatar_url_for(tweet["user"]["screen_name"])}
  end

  def random_robot
    ["klaus", "rudy", "cornelious"].sample
  end

  def avatar_url_for(username)
    Twitter.user(username).profile_image_url(:bigger)
  end

end
