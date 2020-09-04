class TestResponse

  def response_not_found
    response("404 Not Found")
  end

  def response_home
    response("200 OK", headers: {"Server" => "Get"}, body: "Hello")
  end

  def initialize(request)
    @request = request
  end

  def self.respond(request)
    instance = new(request)
    method = "response#{request.url.sub("/", "_")}".to_sym
    if instance.respond_to?(method)
      instance.send(method)
    else
      instance.send(:response_not_found)
    end
  end

  def response(status, headers: {}, body: "")
    response = ["HTTP/1.1 #{status}"]
    headers.each do |header|
      response.push header.join(": ")
    end
    response.push("")
    response.push(body)
    response.join("\r\n")
  end
end



