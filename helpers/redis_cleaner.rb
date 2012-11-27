class RedisCleaner

  uri = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

  def self.clear_database
    REDIS.flushdb
  end

end
