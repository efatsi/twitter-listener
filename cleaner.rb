require 'twitter'
require 'redis'
require 'uri'

load 'helpers/twitter_helper.rb'
load 'helpers/redis_cleaner.rb'
load 'helpers/aws_cleaner.rb'

TweetDestroyer.destroy_jinglebots_tweets
RedisCleaner.clear_database
AWSCleaner.remove_audio_files
AWSCleaner.remove_screenshots
