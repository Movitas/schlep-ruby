# schlep [![Build Status](https://secure.travis-ci.org/Movitas/schlep-ruby.png)](https://secure.travis-ci.org/Movitas/schlep-ruby) [![Dependency Status](https://gemnasium.com/Movitas/schlep-ruby.png)](https://gemnasium.com/Movitas/schlep-ruby)

## Requirements

Schlep needs a [Redis server](http://redis.io), a [Schlep server](http://github.com/Movitas/schlep), and some events. It's [tested on most versions of Ruby](https://secure.travis-ci.org/Movitas/schlep-ruby).

## Installation

```sh
gem install schlep
```

or, add it to your Gemfile:

```rb
gem 'schlep'
```

and then run `bundle install`.

## Configuration

By default, Schlep will connect to Redis locally, use a blank string as the app name, and get the hostname by running `hostname`.

To change this, you can configure things one at a time:

```rb
Schlep.app       = "My App"
Schlep.host      = "localhost"
Schlep.redis_url = "redis://redis:password@localhost:6379"
```

or in a block:

```rb
Schlep.configure do |config|
  config.app       = "My App"
  config.host      = "localhost"
  config.redis_url = "redis://redis:password@localhost:6379"
end
```

If you're using Rails, you should probably put the block above in `config/initializers/schlep.rb`.

For other Ruby apps, anywhere before your first Schlep event is fine.

## Usage

### Basic event

```rb
Schlep.event "event_type", something
```

`something` can be almost any Ruby object, and Schlep will do it's best to serialize it to JSON.

### Multiple events

For performance, Schlep can send multiple events of the same type to Redis in a more efficient manner. To use this, simply call `Schlep.events` instead of `Schlep.event`, and pass an array of objects to serialize:

```rb
events = []

1_000_000.times { |n| events << n }

Schlep.events "load_test", events
```

## Support

If you run into any problems, please [submit an issue](http://github.com/Movitas/schlep-ruby/issues).
