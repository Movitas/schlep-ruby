ENV['RUBY_ENV'] = 'test'

require "schlep"

REDIS_OPTIONS = {
  :daemonize  => :yes,
  :dbfilename => "dump.rdb",
  :dir        => ".",
  :pidfile    => "redis.pid",
  :port       => 9736
}

def start_redis
  until FileTest.exists? REDIS_OPTIONS[:pidfile]
    `echo '#{REDIS_OPTIONS.map { |k, v| "#{k} #{v}" }.join('\n')}' | redis-server -`
    sleep 0.01
  end
end

def stop_redis
  if FileTest.exists? REDIS_OPTIONS[:pidfile]
    %x{
      cat #{REDIS_OPTIONS[:pidfile]} | xargs kill -QUIT
      rm -f #{REDIS_OPTIONS[:dir]}/#{REDIS_OPTIONS[:dbfilename]}
      rm -f #{REDIS_OPTIONS[:dir]}/#{REDIS_OPTIONS[:pidfile]}
    }
  end
end
