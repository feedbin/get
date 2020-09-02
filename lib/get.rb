require "zlib"
require "addressable"
require "socketry"
require "http-parser"

require "get/version"
require "get/errors"
require "get/timeout"
require "get/insensitive_hash"
require "get/parser"
require "get/request"

module Get
  module_function
  def get(*args, **options, &block)
    Request.new(*args, **options).perform(&block)
  end
end
