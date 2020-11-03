require 'smart_proxy_acd/acd_api'

map '/acd' do
  run Proxy::Acd::Api
end
