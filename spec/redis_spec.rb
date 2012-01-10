require "spec_helper"

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

  context "#event" do
    it "should push an event to the schlep key" do
      Schlep.event "test", "test"

      Schlep.redis.llen(Schlep.key).should == 1
    end

    it "should suppress connection errors" do
      stop_redis

      Schlep.event "test", "test"
    end
  end

  context "#events" do
    it "should push multiple events to the schlep key" do
      Schlep.events "test", [1,2,3]

      Schlep.redis.llen(Schlep.key).should == 3
    end

    it "should suppress connection errors" do
      stop_redis

      Schlep.events "test", [1,2,3]
    end
  end
end if `which redis-server`.lines.any?
