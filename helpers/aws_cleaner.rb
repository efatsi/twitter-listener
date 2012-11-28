require 'aws/s3'

class AWSCleaner

  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV["AMAZON_ACCESS_KEY"],
    :secret_access_key => ENV["AMAZON_SECRET_KEY"],
  )

  def self.remove_audio_files
    keys_for("voice_recordings").each{|key| AWS::S3::S3Object.delete(key, 'jinglebots') }
  end

  def self.remove_screenshots
    keys_for("screenshots").each{|key| AWS::S3::S3Object.delete(key, 'jinglebots') }
  end

  private

  def self.keys_for(file_type)
    all_files.select do |file|
      file.send(:attributes)["key"].to_s.include?(file_type)
    end.map{|f| f.send(:attributes)["key"]}
  end

  def self.all_files
    AWS::S3::Bucket.objects('jinglebots')
  end

end
