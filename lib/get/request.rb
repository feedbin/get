module Get
  class Request
    def initialize(url, timeouts: {}, headers: {})
      @url = Addressable::URI.parse(url)
      @timeouts = timeouts
      @headers = headers
      @timeout = 5
    end

    def perform(&block)
      get(@url, block)
    ensure
      socket&.close
    end

    private
      def get(url, block)
        socket.write(request(url))

        parser   = Parser.new(on_body: block)
        deadline = Timeout.new(@timeout)
        chunk    = "".b
        until parser.done?
          raise Get::TimeoutError, "read timed out after #{@timeout} seconds" if deadline.timed_out?
          socket.readpartial((1024 * 16), outbuf: chunk)
          parser.parse! chunk
        end
        # raise parser.error if parser.error
      ensure
        parser&.reset
      end

      def request(url)
        @headers["Host"] = url.host

        parts = ["GET #{url.request_uri} HTTP/1.1"]
        @headers.each do |header|
          parts.push header.join(": ")
        end
        parts.push("\r\n")
        parts.join("\r\n")
      end

      def socket
        @socket ||= begin
          klass = (@url.scheme == "https") ? Socketry::SSL::Socket : Socketry::TCP::Socket
          klass.new(resolver: Socketry::Resolver::Resolv).tap do |sock|
            sock.connect(@url.host, @url.inferred_port)
            sock.nodelay = true
          end
        end
      end
  end
end

