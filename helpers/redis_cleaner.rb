class RedisCleaner

  uri         = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
  REDIS       = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  train_uri   = URI.parse(ENV["JINGLEBOTS_TRAIN_REDIS_URI"])
  train_redis = Redis.new(:host => train_uri.host, :port => train_uri.port, :password => train_uri.password)

  def self.clear_database
    REDIS.flushdb
    train_redis.flushdb
  end

end
