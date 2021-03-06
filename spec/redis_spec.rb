require "spec_helper"

REDIS_ENABLED = `which redis-server`.lines.any? && RUBY_PLATFORM != "java"

describe Schlep do
  before :all do
    print "("
  end

  after :all do
    stop_redis
    print ")"
  end

  before :each do
    start_redis
    Schlep.reset
    Schlep.redis_url = "redis://localhost:#{REDIS_OPTIONS[:port]}"
    Schlep.redis.flushall
  end

  context ".event" do
    it "should push an event to the schlep key" do
      Schlep.event :test, "test"

      Schlep.redis.llen(Schlep.key).should == 1
      envelope = JSON.parse(Schlep.redis.lpop(Schlep.key))
      envelope['type'].should    == "test"
      envelope['message'].should == "test"
    end

    it "should sanitize overridden options" do
      Schlep.event "test", "test", :app => "a:b/c^d$$e", :host => "a:b/c^d$$e"
      envelope = JSON.parse(Schlep.redis.lpop(Schlep.key))
      envelope['app'].should  == "a:b:c:d:e"
      envelope['host'].should == "a:b:c:d:e"
    end

    it "should suppress connection errors" do
      stop_redis

      Schlep.event :test, "test"
    end
  end

  context ".events" do
    it "should push multiple events to the schlep key" do
      Schlep.events :test, [1,2,3]

      Schlep.redis.llen(Schlep.key).should == 3

      (1..3).each do |n|
        envelope = JSON.parse(Schlep.redis.lpop(Schlep.key))
        envelope['type'].should    == "test"
        envelope['message'].should == n
      end
    end

    it "should sanitize overridden options" do
      Schlep.events "test", ["test"], :app => "a:b/c^d$$e", :host => "a:b/c^d$$e"
      envelope = JSON.parse(Schlep.redis.lpop(Schlep.key))
      envelope['app'].should  == "a:b:c:d:e"
      envelope['host'].should == "a:b:c:d:e"
    end

    it "should suppress connection errors" do
      stop_redis

      Schlep.events :test, [1,2,3]
    end
  end
end if REDIS_ENABLED
