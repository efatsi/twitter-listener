require 'twitter'
require 'redis'
require 'uri'

load 'helpers/twitter_helper.rb'

uri = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

REDIS.flushdb

TweetDestroyer.destroy_all_tweets
