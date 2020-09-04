require "http/parser"

class RequestParser

  attr_reader :headers, :url

  def initialize
    @state = ::HttpParser::Parser.new_instance { |i| i.type = :request }
    reset
  end

  def parse!(chunk)
    http_parser.parse(@state, chunk)
  end

  def status
    @state.http_status
  end

  def done?
    @done
  end

  def reset
    @state.reset!
    @headers     = InsensitiveHash.new
    @reading     = false
    @done        = false
    @field       = +""
    @field_value = +""
  end

  def append_header
    @headers[@field] = @field_value
    @reading         = false
    @field_value     = +""
    @field           = +""
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

      parser.on_url do |instance, data|
        @url = data
      end

      parser.on_message_complete do |instance|
        @done = true
      end

      parser.on_headers_complete do |instance, data|
        append_header if @reading
      end
    end
  end
end