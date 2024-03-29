require 'data_mapper'
require 'uri'
require 'redis'

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
