require "schlep/version"

require "json"
require "redis"
require "uri"

module Schlep
  extend self

  attr_writer :app, :hostname, :redis_url

  def app
    @app ||= ""
  end

  def configure
    yield self
  end

  def envelope(type, message)
    {
      :timestamp => timestamp,
      :app =>       app,
      :host =>      hostname,
      :type =>      type,
      :message =>   serialize_message(message)
    }.to_json
  end

  def event(type, message)
    e = envelope(type, message)
    redis.rpush 'schlep', e
    e
  end

  def hostname
    @hostname ||= `hostname`.split(".").first
  end

  def redis
    @redis ||= Redis.new redis_options
  end

  def redis_options
    return {} unless redis_url

    parsed_url = URI::parse(redis_url)

    {
      :host     => parsed_url.host,
      :port     => parsed_url.port,
      :password => parsed_url.password
    }
  end

  def redis_url
    @redis_url ||= ENV["REDIS_URL"] or ENV["REDISTOGO_URL"]
  end

  def reset
    %w[app hostname redis redis_url].each do |ivar|
      instance_variable_set "@#{ivar}", nil
    end
  end

  def serialize_message(message)
    return message if [String, Fixnum, Float].index message.class
    message.to_json
  end

  def timestamp
    Time.now.to_f
  end
end
