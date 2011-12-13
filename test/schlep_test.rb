begin
  require "test_helper"
rescue LoadError
  require File.join(File.dirname(__FILE__), ".", "test_helper")
end

class SchlepTest < Test::Unit::TestCase
  def setup
    Schlep.reset
  end

  def teardown
    %w[REDIS_URL REDISTOGO_URL].each do |e|
      ENV[e] = nil
    end
  end

  context "schlep" do
    should "be defined as a module" do
      assert_equal Module, Schlep.class
    end
  end

  context "configure" do
    should "be configurable with setters" do
      Schlep.app       = "test_app_1"
      Schlep.hostname  = "test_hostname_1"
      Schlep.redis_url = "redis://localhost:1234"

      assert_equal "test_app_1",             Schlep.app,       "app"
      assert_equal "test_hostname_1",        Schlep.hostname,  "hostname"
      assert_equal "redis://localhost:1234", Schlep.redis_url, "redis_url"
    end

    should "be configurable with a block" do
      Schlep.configure do |config|
        config.app       = "test_app_2"
        config.hostname  = "test_hostname_2"
        config.redis_url = "redis://localhost:4321"
      end

      assert_equal "test_app_2",             Schlep.app,       "app"
      assert_equal "test_hostname_2",        Schlep.hostname,  "hostname"
      assert_equal "redis://localhost:4321", Schlep.redis_url, "redis_url"
    end
  end

  context "envelope" do
    should "return valid json" do
      assert_nothing_raised(Exception) {
        JSON.parse(Schlep.envelope "test_type", { :one => { :two => 3 }})
      }
    end
  end

  context "hostname" do
    should "be a string" do
      assert Schlep.hostname.is_a? String
    end
  end

  context "redis_url" do
    should "connect locally by default" do
      assert_equal "127.0.0.1", Schlep.redis.client.host
      assert_equal 6379,        Schlep.redis.client.port
    end

    should "connect to a basic url" do
      Schlep.redis_url = "redis://1.2.3.4:1234"

      assert_equal "1.2.3.4", Schlep.redis.client.host
      assert_equal 1234,      Schlep.redis.client.port
      assert_nil              Schlep.redis.client.password
    end

    should "connect to a url with a username and password" do
      Schlep.redis_url = "redis://redis:password@1.2.3.4:1234"

      assert_equal "1.2.3.4",  Schlep.redis.client.host
      assert_equal 1234,       Schlep.redis.client.port
      assert_equal "password", Schlep.redis.client.password
    end

    should "detect the url from ENV[\"REDIS_URL\"]" do
      ENV["REDIS_URL"] = "redis://redis:secret@4.3.2.1:4321"

      assert_equal "4.3.2.1", Schlep.redis.client.host
      assert_equal 4321,      Schlep.redis.client.port
      assert_equal "secret",  Schlep.redis.client.password
    end

    should "detect the url from ENV[\"REDISTOGO_URL\"]" do
      ENV["REDISTOGO_URL"] = "redis://redis:secret@4.3.2.1:4321"

      assert_equal "4.3.2.1", Schlep.redis.client.host
      assert_equal 4321,      Schlep.redis.client.port
      assert_equal "secret",  Schlep.redis.client.password
    end
  end

  context "reset" do
    should "reset instance variables to nil" do
      Schlep.configure do |config|
        config.app      = "test_app"
        config.hostname = "test_hostname"
      end

      Schlep.reset

      %w[app hostname redis].each do |ivar|
        assert_nil Schlep.instance_variable_get("@#{ivar}"), "@#{ivar}"
      end
    end
  end

  context "serialize message" do
    should "leave valid json alone" do
      assert_equal "{\"one\":{\"two\":3}}",
        Schlep.serialize_message("{\"one\":{\"two\":3}}")
    end

    should "leave strings alone" do
      assert_equal "test string",
        Schlep.serialize_message("test string")
    end

    should "convert arrays to json" do
      assert_equal "[1,2,[3,4]]",
        Schlep.serialize_message([1,2,[3,4]])
    end

    should "convert hashes to json" do
      assert_equal "{\"one\":{\"two\":3}}",
        Schlep.serialize_message({ :one => { :two => 3 }})
    end

    should "convert an array of hashes to json" do
      assert_equal "[{\"one\":{\"two\":3}},{\"four\":{\"five\":6}}]",
        Schlep.serialize_message([{ :one => { :two => 3 }},{ :four => { :five => 6 }}])
    end

    should "leave integers alone" do
      assert_equal 123,
        Schlep.serialize_message(123)
    end

    should "leave floats alone" do
      assert_equal 1.23,
        Schlep.serialize_message(1.23)
    end
  end

  context "timestamp" do
    should "be a float" do
      assert Schlep.timestamp.is_a? Float
    end
  end
end
