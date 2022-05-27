module Proxy
  # The ACD module
  module Acd
    extend ::Proxy::Util
    extend ::Proxy::Log

    class << self
      def plugin_settings
        # rubocop:disable ClassVars
        @@settings ||= OpenStruct.new(read_settings)
        # rubocop:enable ClassVars
      end

      def read_settings
        ::Proxy::Acd::Plugin.default_settings.merge(
          YAML.load_file(File.join(::Proxy::SETTINGS.settings_directory, ::Proxy::Acd::Plugin.settings_file))
        )
      end
    end
  end
end
