module Proxy
  module Acd
    class NotFound < RuntimeError; end

    class Plugin < ::Proxy::Plugin
      plugin 'acd', Proxy::Acd::VERSION

      default_settings :hello_greeting => 'O hai!'
      default_settings :playbook_path => '/opt/acd/playbooks'

      http_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))
      https_rackup_path File.expand_path('acd_http_config.ru', File.expand_path('../', __FILE__))

      after_activation do
        if !Dir.exist? settings.playbook_path
          Dir.mkdir settings.playbook_path
        end
        if !(File.writable?(settings.playbook_path) && File.readable?(settings.playbook_path))
          raise "StorageDir #{settings.playbook_path.inspect} not read-/writeable"
        end
      end
    end
  end
end
