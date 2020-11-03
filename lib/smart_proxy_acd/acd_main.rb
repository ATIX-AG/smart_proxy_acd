module Proxy::Acd
  extend ::Proxy::Util
  extend ::Proxy::Log

  class << self

    def say_hello
      Proxy::Acd::Plugin.settings.hello_greeting
    end

    def read_playbooks
    end

    def read_playbook_vars
    end
  end
end
