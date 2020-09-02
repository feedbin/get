module Get
  class Response
    attr_reader :status, :headers
    def initialize(status:, headers:)
      @status = status
      @headers = headers
    end
  end
end
