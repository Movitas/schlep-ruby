require "schlep/version"

require "json"
require "redis"

module Schlep
  extend self

  attr_writer :app, :hostname

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
    @redis ||= Redis.new
  end

  def reset
    %w[app hostname redis].each do |ivar|
      instance_variable_set "@#{ivar}", nil
    end
  end

  def serialize_message(message)
    return message if message.is_a? String
    message.to_json
  end

  def timestamp
    Time.now.to_f
  end
end
