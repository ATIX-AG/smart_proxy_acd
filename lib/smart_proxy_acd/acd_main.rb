module Proxy
  module Acd
    extend ::Proxy::Util
    extend ::Proxy::Log

    class << self

      def say_hello
        Proxy::Acd::Plugin.settings.hello_greeting
      end

      def save_playbook
        filename = params[:file][:filename]
        file = params[:file][:tempfile]

        # sanitize filename (to avoid exploits such as "../../../etc/")
        # might need additional work
        filename = File.basename filename

        file_path = File.join(settings.playbook_path, filename)
        File.open(file_path, 'wb') do |f|
          f.write(file.read)
        end

      end

      def read_playbooks
      end

      def read_playbook_vars
      end
    end
  end
end
