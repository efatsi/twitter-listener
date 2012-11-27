require 'redis'
require 'uri'

uri = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

def clean_it_up
  REDIS.keys("message:*").each do |key|
    REDIS.del(key)
  end
  
  REDIS.llen("messages").times do
    REDIS.rpop("messages")
  end
end
