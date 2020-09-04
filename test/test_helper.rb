$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "get"
require "socket"
require "request_parser"
require "test_response"
require "minitest/autorun"

Thread.abort_on_exception = true

server = TCPServer.new("127.0.0.1", 0)
server_thread = Thread.start do
  request = RequestParser.new
  Socket.accept_loop(server) do |connection|
    begin
      until request.done?
        request.parse! connection.readpartial(4096)
      end
      response = TestResponse.respond(request)
      connection.write(response)
      request.reset
    rescue Errno::EAGAIN
      IO.select([connection])
      retry
    rescue Errno::EPIPE
      connection.close
    end
    connection.close
  end
end

$test_server = "http://127.0.0.1:#{server.addr[1]}"

Minitest.after_run do
  Thread.kill(server_thread)
end

def url(path)
  $test_server << path
end