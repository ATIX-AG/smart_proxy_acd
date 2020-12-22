module Proxy
  module Acd
    class NotFound < RuntimeError; end

    class Plugin < ::Proxy::Plugin
      plugin 'acd', Proxy::Acd::VERSION
      http_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))
      https_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))
    end
  end
end
