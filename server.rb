$LOAD_PATH << '.'
require 'constants'
require 'socket'
require 'thread'

module Server
  # manages the server application
  class Processor
    def initialize
      @flag_value = 'DVA7867a8s6aasahhh'
      @flag_token = false
      @ip_list = get_ip_list_from_file
    end

    def who_are_you?
      Constants::ID
    end

    def have_flag?
      if @flag_value == false
        Constants::ANSWER_HAVE_FLAG_NO
      else
        @flag_token = generate_flag_token
        "#{Constants::ANSWER_HAVE_FLAG_YES} #{@flag_token}"
      end
    end

    def generate_flag_token
      rand(36**9).to_s(36)
    end

    def next_server
      new_ip = @ip_list.sample
      while new_ip == Socket.ip_address_list.detect(&:ipv4_private?).ip_address
        new_ip = @ip_list[rand(@ip_list.length)]
      end
      new_ip
    end

    def capture_flag(flag_token)
      if flag_token == @flag_token
        value = @flag_value
        @flag_value = false
        "#{Constants::ANSWER_CAPTURE_FLAG_YES} #{value}"
      else
        Constants::ANSWER_CAPTURE_FLAG_NO
      end
    end

    def hide_flag(flag_value)
      @flag_value = flag_value
      @flag_token = generate_flag_token
    end

    def method_missing(name, *params)
      if match = /capture_flag (?<flag_token>.+)/.match(name)
        capture_flag(match['flag_token'])
      elsif match = /hide_flag (?<flag_value>.+)/.match(name)
        hide_flag(match['flag_value'])
      else
        puts "Got malformed command: #{name}"
      end
    end

    def get_ip_list_from_file
      list = []
      file = File.open('list.txt', 'r')

      file.each_line do |line|
        if line[0] != "#"
          list.push(line)
        end
      end
      file.close
      list
    end

    private :capture_flag, :hide_flag, :method_missing, :generate_flag_token, :get_ip_list_from_file
  end

  # manages connection and sending/receiving from/to clients
  class Connection
    def initialize(hostname, port)
      @connection = TCPServer.new(hostname, port)
      @processor = Processor.new
      @mutex = Mutex.new
    end

    def listen
      Thread.start(@connection.accept) do |client|
        while msg = client.gets.chomp
          @mutex.synchronize do
            begin
              client.puts(@processor.send(msg))
            rescue StandardError => e
              puts e.message
              client.close
              break
            end
          end
        end
        client.close
      end
    end
  end
end
