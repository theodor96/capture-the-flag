$LOAD_PATH << '.'
require 'socket'
require 'ostruct'
require 'constants'

module Client
  # client manager class used to communicate with other servers
  class Connection
    def initialize
      @connection = false
    end

    def connect_to(hostname, port)
      disconnect
      @connection = TCPSocket.new(hostname, port)
    end

    def disconnect
      if @connection
        begin
          @connection.close
        rescue
          return
        end
      end
    end

    # since server is responding with puts, we have an extra new line at the end of each response stirng which is not exactly what we wanna
    def fix_response(response)
      response.chop
    end

    def ask_next_server
      unless @connection
        fail 'Cannot get next server without a connection'
      end
      next_server = OpenStruct.new
      next_server.port = Constants::PORT
      @connection.puts Constants::ASK_NEXT_SERVER
      next_server.hostname = fix_response(@connection.gets)
      next_server
    end

    def ask_server_identity
      unless @connection
        fail 'Cannot get server identity without a connection'
      end
      @connection.puts Constants::ASK_GET_ID
      fix_response(@connection.gets)
    end

    def ask_about_flag
      unless @connection
        fail 'Cannot ask server about flag without a connection'
      end
      @connection.puts Constants::ASK_HAVE_FLAG
      response = fix_response(@connection.gets)
      if response == Constants::ANSWER_HAVE_FLAG_NO
        false
      else
        pattern = /#{Constants::ANSWER_HAVE_FLAG_YES} (?<flag_token>.+)/
        if match = pattern.match(response)
          match['flag_token']
        else
          false
        end
      end
    end

    def capture_flag(token)
      unless @connection
        fail 'Cannot capture flag without a connection'
      end
      @connection.puts Constants::ASK_CAPTURE_FLAG + ' ' + token
      response = fix_response(@connection.gets)
      pattern = /#{Constants::ANSWER_CAPTURE_FLAG_YES} (?<flag_value>.+)/
      if match = pattern.match(response)
        match['flag_value']
      else
        false
      end
    end

    def hide_flag(value)
      unless @connection
        fail 'Cannot hide flag without a connection'
      end
      @connection.puts Constants::ASK_HIDE_FLAG + ' ' + value
    end

    private :fix_response
  end
end
