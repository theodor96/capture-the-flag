$LOAD_PATH << '.'
require 'constants'
require 'server'
include Server

# get correct port number
if ARGV.length == 0
  if Constants::DEBUGGING == false
    puts 'You need to give the server a port that should be listened on'
    exit
  else # coulda used end since we exit above anyway
    port = Constants::PORT
  end
else
  port = ARGV[0]
end

# initialize the connection and start listening
connection = Connection.new(Constants::HOSTNAME, port)
loop do
  connection.listen
end
