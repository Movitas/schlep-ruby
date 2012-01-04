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
    redis.rpush 'schlep', envelope(type, message)
  end

  def events(type, messages)
    messages.map! { | message| envelope(type, message) }

    redis.pipelined do
      while messages.any?
        redis.rpush 'schlep', messages.pop
      end
    end
  end

  def hostname
    @hostname ||= `hostname`

    @hostname.gsub! /\s/, "" if @hostname =~ /\s/

    @hostname
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
