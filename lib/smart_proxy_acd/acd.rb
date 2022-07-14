module Proxy
  module Acd
    class NotFound < RuntimeError; end

    # Implement a SmartProxy Plugin
    class Plugin < ::Proxy::Plugin
      plugin 'acd', Proxy::Acd::VERSION
      rackup_path File.expand_path('acd_http_config.ru', __dir__)

      load_classes do
        require 'smart_proxy_dynflow'
        require 'smart_proxy_acd/acd_runner'
        require 'smart_proxy_acd/acd_task_launcher'
      end

      default_settings :timeout => 60

      load_dependency_injection_wirings do |_container_instance, _settings|
        Proxy::Dynflow::TaskLauncherRegistry.register('acd', AcdTaskLauncher)
      end
    end
  end
end
