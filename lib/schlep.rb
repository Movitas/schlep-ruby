require "schlep/version"

require "json"
require "redis"
require "uri"

module Schlep
  extend self

  attr_writer :redis_url

  def app
    @app ||= ""
  end

  def app=(string)
    @app = sanitize string
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
    events type, [message]
  end

  def events(type, messages)
    messages.map! { |message| envelope type, message }

    redis.pipelined do
      while messages.any?
        redis.rpush key, messages.pop
      end
    end
  end

  def hostname
    @hostname ||= sanitize `hostname`
  end

  def hostname=(string)
    @hostname = sanitize string
  end

  def key
    @key ||= :schlep
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
    return message unless
      message.is_a? String and
      message.match /\{.+\}/

    begin
      JSON.parse message
    rescue JSON::ParserError
      message
    end
  end

  def timestamp
    Time.now.to_f
  end

  private

  def sanitize(string)
    string.gsub! /\s/, ""
    string.gsub! /^[^\w]+|[^\w]+$/, ""
    string.gsub! /[^\w\.\-]+/, ":"

    string
  end
end
