begin
  require "test_helper"
rescue LoadError
  require File.join(File.dirname(__FILE__), ".", "test_helper")
end

class SchlepTest < Test::Unit::TestCase
  context "schlep" do
    should "be defined as a module" do
      assert_equal Module, Schlep.class
    end
  end

  context "configure" do
    should "be configurable with setters" do
      Schlep.app      = "test_app_1"
      Schlep.hostname = "test_hostname_1"

      assert_equal "test_app_1",      Schlep.app,      "app"
      assert_equal "test_hostname_1", Schlep.hostname, "hostname"
    end

    should "be configurable with a block" do
      Schlep.configure do |config|
        config.app      = "test_app_2"
        config.hostname = "test_hostname_2"
      end

      assert_equal "test_app_2",      Schlep.app,      "app"
      assert_equal "test_hostname_2", Schlep.hostname, "hostname"
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

    should "convert integers to strings" do
      assert_equal "123",
        Schlep.serialize_message(123)
    end

    should "convert floats to strings" do
      assert_equal "1.23",
        Schlep.serialize_message(1.23)
    end
  end

  context "timestamp" do
    should "be a float" do
      assert Schlep.timestamp.is_a? Float
    end
  end
end
