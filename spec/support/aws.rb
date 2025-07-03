require "aws-sdk-s3"

ENV["AWS_DEFAULT_REGION"] ||= "ap-southeast-1"
ENV["AWS_ACCESS_KEY_ID"] ||= "access-key-id"
ENV["AWS_SECRET_ACCESS_KEY"] ||= "secret-key"

Aws.config[:s3] ||= { stub_responses: true }
