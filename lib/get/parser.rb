# frozen_string_literal: true

module Get
  class Parser

    SUPPORTED_ENCODING = Set.new(%w[deflate gzip x-gzip]).freeze

    attr_reader :headers

    def initialize(on_body:)
      @state   = ::HttpParser::Parser.new_instance { |i| i.type = :response }
      @on_body = on_body

      reset
    end

    def parse!(chunk)
      http_parser.parse(@state, chunk)
    end

    def status
      @state.http_status
    end

    def reset
      @state.reset!
      @headers     = InsensitiveHash.new
      @reading     = false
      @field       = +""
      @field_value = +""
      @error       = nil
      @done        = false
    end

    def error
      @error || @state.error
    end

    def done?
      @done
    end

    def inflate(chunk)
      if chunk
        chunk = zstream.inflate(chunk)
      elsif !zstream.closed?
        zstream.finish
        zstream.close
      end
      chunk
    end

    def zstream
      @zstream ||= Zlib::Inflate.new(32 + Zlib::MAX_WBITS)
    end

    def inflate?
      SUPPORTED_ENCODING.include?(@headers["content-encoding"])
    end

    def append_header
      @headers[@field] = @field_value
      @reading                  = false
      @field_value              = +""
      @field                    = +""
    end

    def http_parser
      @http_parser ||= HttpParser::Parser.new do |parser|
        parser.on_header_field do |instance, data|
          append_header if @reading
          @field << data
        end

        parser.on_header_value do |instance, data|
          @reading = true
          @field_value << data
        end

        parser.on_message_complete do |instance|
          @done = true
        end

        parser.on_headers_complete do |instance, data|
          append_header if @reading
          # @state.stop!
        end

        parser.on_body do |instance, data|
          if @on_body.respond_to?(:call)
            data = inflate(data) if inflate?
            @on_body.call(data)
          end
        rescue => exception
          @error = exception
        end
      end
    end
  end
end
