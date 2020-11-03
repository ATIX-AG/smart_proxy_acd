require File.expand_path('../lib/smart_proxy_acd/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_acd'
  s.version = Proxy::Acd::VERSION

  s.summary = 'Application Centric Deployment smart proxy plugin'
  s.description = 'Application Centric Deployment smart proxy plugin'
  s.authors = ['Markus Bucher']
  s.email = 'info@atix.de'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = Dir['{lib,settings.d,bundler.d}/**/*'] + s.extra_rdoc_files
  s.homepage = 'http://github.com/ATIX-AG/smart_proxy_acd'
  s.license = 'GPLv3'
end
