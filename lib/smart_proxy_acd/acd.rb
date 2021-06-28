module Proxy
  module Acd
    class NotFound < RuntimeError; end

    # Implement a SmartProxy Plugin
    class Plugin < ::Proxy::Plugin
      plugin 'acd', Proxy::Acd::VERSION
      http_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))
      https_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))

      after_activation do
        require 'smart_proxy_dynflow'
        require 'smart_proxy_acd/acd_runner'
        require 'smart_proxy_acd/acd_task_launcher'

        Proxy::Dynflow::TaskLauncherRegistry.register('acd', AcdTaskLauncher)
      end
    end
  end
end
