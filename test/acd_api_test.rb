require 'test_helper'
require 'webmock/test_unit'
require 'mocha/test_unit'
require 'rack/test'

require 'smart_proxy_acd/acd'
require 'smart_proxy_acd/acd_api'

class AcdApiTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Proxy::Acd::Api.new
  end

  def test_returns_hello_greeting
    # add test here
  end
end
