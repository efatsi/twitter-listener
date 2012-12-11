require 'json'
require 'data_mapper'
require 'uri'
require 'redis'

uri         = URI.parse(ENV["JINGLEBOTS_REDIS_URI"])
REDIS       = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_CHARCOAL_URL'])

class Message
  include DataMapper::Resource
  property :id,         Serial
  property :msg,        Text
  property :name,       String
  property :count,      Integer
  property :gif_name,   String
  property :robot_name, String
  property :time,       DateTime
  property :source,     String
  property :avatar_url, Text
end

DataMapper.finalize

messages = REDIS.lrange("messages", 0, -1).map{|m| JSON.parse(m)}

Message.all.destroy

messages.reverse.each do |m|
  Message.create(m)
end
