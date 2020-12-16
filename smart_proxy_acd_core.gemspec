# -*- coding: utf-8 -*-
require File.expand_path('../lib/smart_proxy_acd_core/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_acd_core'
  s.version     = SmartProxyAcdCore::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Bernhard suttner']
  s.email       = ['suttner@atix.de']
  s.homepage    = 'https://github.com/ATIX-AG/smart_proxy_acd'
  s.summary     = 'Smart Proxy ACD - core bits'
  s.description = <<DESC
  ACD remote execution provider code for Foreman-Proxy
DESC

  s.files = Dir['lib/smart_proxy_acd_core/**/*'] +
            ['lib/smart_proxy_acd_core.rb', 'LICENSE']

  s.add_runtime_dependency('foreman-tasks-core', '>= 0.3.1')
  s.add_runtime_dependency('foreman_remote_execution_core', '>= 0.1.2')
end
