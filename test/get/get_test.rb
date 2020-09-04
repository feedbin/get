require "test_helper"
require "http"

class GetTest < Minitest::Test
  def test_that_it_has_a_version_number
    r = HTTP.get url("/home")
    pp r.status
    pp r.headers[:server]
    pp r.to_s
  end
end
