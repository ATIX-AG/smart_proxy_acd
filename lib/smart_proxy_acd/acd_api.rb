require 'sinatra'
require 'smart_proxy_acd/acd'
require 'smart_proxy_acd/acd_main'

module Proxy
  module Acd

    class Api < ::Sinatra::Base
      include ::Proxy::Log
      helpers ::Proxy::Helpers
    end
  end
end
