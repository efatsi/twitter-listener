require 'aws/s3'

class AWSCleaner

  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV["AMAZON_ACCESS_KEY"],
    :secret_access_key => ENV["AMAZON_SECRET_KEY"],
  )

  def self.remove_audio_files
    audio_file_keys.each{|key| AWS::S3::S3Object.delete(key, 'jinglebots') }
  end

  private

  def self.audio_file_keys
    all_files.select do |file|
      file.send(:attributes)["key"].include?("voice_recordings")
    end.map{|f| f.send(:attributes)["key"]}
  end

  def self.all_files
    AWS::S3::Bucket.objects('jinglebots')
  end

end
