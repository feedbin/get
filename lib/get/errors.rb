module Get
  # generic error which is a superclass to all other errors
  class Error < StandardError; end

  # raised when there was an error connecting to the server
  class ConnectionError < Error; end

  # raised when connecting to the server too longer than the specified timeout
  class TimeoutError < ConnectionError; end

end
