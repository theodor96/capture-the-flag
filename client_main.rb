$LOAD_PATH << '.'
require 'constants'
require 'client'
require 'thread'
include Client

# get correct port number
if ARGV.length == 0
  if Constants::DEBUGGING == false
    puts 'You need to give the connection a port that it should connect on'
    exit
  else # coulda used end since we exit above anyway
    port = Constants::PORT
  end
else
  port = ARGV[0]
end

# save the captured flag to our own server. should be run on a separate thread!
def hide_flag(flag_value)
  if flag_value == false # got ERROR trying to trick me or smth
    return
  end
  connection = Connection.new
  connection.connect_to(Constants::HOSTNAME, port)
  connection.hide_flag(flag_value)
  connection.disconnect
end

# initialize the connection and then start running the application
connection = Connection.new
connection.connect_to(Constants::HOSTNAME, port)
loop do
  loop do
    next_server = connection.ask_next_server
    begin
      connection.connect_to(next_server.hostname, next_server.port)
    rescue
      puts "Cannot connect to #{next_server.hostname}, connecting to my own server and getting another next_server"
      connection.connect_to(Constants::HOSTNAME, port)
    else
      break
    end
  end
  server_id = connection.ask_server_identity
  puts "Talking with #{server_id}"
  if response = connection.ask_about_flag
    Thread.new do
      hide_flag(connection.capture_flag(response))
      Thread.stop
    end
    puts "Got the flag from #{server_id}"
    wait = Random.rand(Constants::SLEEP_AFTER_CAPTURE_UPPER) + Constants::SLEEP_AFTER_CAPTURE_LOWER
    puts "Resting now for #{wait} seconds"
    sleep(wait)
    connection.connect_to(Constants::HOSTNAME, port)
  else
    sleep(Constants::SLEEP_AFTER_FAIL_CAPTURE)
    next
  end
end
