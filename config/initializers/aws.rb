require 'aws-sdk'
# Rails.configuration.aws is used by AWS, Paperclip, and S3DirectUpload
if Rails.env == "production"
  Rails.configuration.aws = { access_key_id: ENV['s3_access_key_id'], secret_access_key: ENV['s3_secret_access_key'], bucket: ENV['s3_bucket'] }
else
  Rails.configuration.aws = YAML.load(ERB.new(File.read("#{Rails.root}/config/aws.yml")).result)[Rails.env].symbolize_keys!
end
AWS.config(logger: Rails.logger)
AWS.config(Rails.configuration.aws)