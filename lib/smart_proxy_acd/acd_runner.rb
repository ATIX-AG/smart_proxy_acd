require 'smart_proxy_dynflow/runner/base'
require 'smart_proxy_dynflow/runner/command_runner'
require 'tempfile'
require 'rest-client'
require 'tmpdir'
require 'socket'

# rubocop:disable ClassLength

module Proxy
  module Acd
    # Implements the AcdRunner to be used by foreman_remote_execution
    class AcdRunner < Proxy::Dynflow::Runner::CommandRunner
      DEFAULT_REFRESH_INTERVAL = 1

      class << self
        def parse_dynflow_settings(path)
          return @dynflow_settings if defined? @dynflow_settings
          if File.exist?(path)
            @dynflow_settings = {}
            YAML.load_file(path).each do |key, value|
              @dynflow_settings[key.to_s] = value
            end
          end
          @dynflow_settings
        end

        def parse_ssl_options
          return @ssl_options if defined? @ssl_options

          @ssl_options = {}
          return @ssl_options unless URI.parse(@dynflow_settings['foreman_url']).scheme == 'https'

          @ssl_options[:verify_ssl] = OpenSSL::SSL::VERIFY_PEER

          private_key_file = @dynflow_settings['foreman_ssl_key'] || @dynflow_settings['ssl_private_key']
          if private_key_file
            private_key = File.read(private_key_file)
            @ssl_options[:ssl_client_key] = OpenSSL::PKey::RSA.new(private_key)
          end
          certificate_file = @dynflow_settings['foreman_ssl_cert'] || @dynflow_settings['ssl_certificate']
          if certificate_file
            certificate = File.read(certificate_file)
            @ssl_options[:ssl_client_cert] = OpenSSL::X509::Certificate.new(certificate)
          end
          ca_file = @dynflow_settings['foreman_ssl_ca'] || @dynflow_settings['ssl_ca_file']
          @ssl_options[:ssl_ca_file] = ca_file if ca_file
          @ssl_options
        end
      end

      def initialize(options, suspended_action:)
        super(options, :suspended_action => suspended_action)
        @options = options
      end

      def get_playbook(playbook_id)
        logger.debug("Get playbook with id #{playbook_id}")
        response = playbook_resource(playbook_id).get
        if response.code.to_s != '200'
          raise "Failed performing callback to Foreman server: #{response.code} #{response.body}"
        end
        tmp_file = Tempfile.new.path
        File.write(tmp_file, response)
        @playbook_tmp_base64_file = tmp_file
      end

      def playbook_resource(playbook_id)
        dynflow_settings = self.class.parse_dynflow_settings('/etc/foreman-proxy/settings.yml')
        playbook_url = dynflow_settings['foreman_url'] + "/acd/api/v2/ansible_playbooks/#{playbook_id}/grab"
        @resource ||= RestClient::Resource.new(playbook_url, self.class.parse_ssl_options)
      end

      def store_playbook
        logger.debug('Unpack ansible playbook')
        dir = Dir.mktmpdir
        raise 'Could not create temporary directory to run ansible playbook' if dir.nil? || !Dir.exist?(dir)
        command = "base64 -d #{@playbook_tmp_base64_file} | tar xz -C #{dir}"
        system(command)
        @playbook_tmp_dir = dir
      end

      def cleanup
        File.unlink(@playbook_tmp_base64_file) if File.exist?(@playbook_tmp_base64_file)
        FileUtils.rm_rf(@playbook_tmp_dir) if Dir.exist?(@playbook_tmp_dir)
      end

      def start
        parse_acd_job

        publish_data("Grab playbook to configure application #{@application_name}...", 'stdout')
        get_playbook(@playbook_id)
        store_playbook

        @playbook_path = File.join(@playbook_tmp_dir, @playbook_file)
        raise "Could not run playbook: playbook file #{@playbook_file} not found in playbook dir #{@playbook_tmp_dir}" unless File.exist?(@playbook_path)

        publish_data('Write temporary inventory', 'stdout')
        write_inventory

        command = generate_command
        logger.debug("Running command #{command.join(' ')}")
        initialize_command(*command)
      end

      def close
        logger.debug("Cleanup ansible playbook #{@playbook_tmp_dir} and #{@playbook_tmp_base64_file}")
        cleanup
      end

      def kill
        publish_data('== TASK ABORTED BY USER ==', 'stdout')
        publish_exit_status(1)
        ::Process.kill('SIGTERM', @command_pid)
      end

      private

      def parse_acd_job
        @acd_job = YAML.safe_load(@options['script'])
        @application_name = @acd_job['application_name']
        @playbook_id = @acd_job['playbook_id']
        @playbook_file = @acd_job['playbook_file']

        raise "'playbook_file' need to be specified" if @playbook_file.nil? || @playbook_file.empty?
        raise "'playbook_id' need to be specified" if @playbook_id.nil?
      end

      def proxy_hostname
        Socket.gethostbyname(Socket.gethostname).first
      end

      def write_inventory
        complete_inventory = YAML.safe_load(@acd_job['inventory'])
        my_inventory = complete_inventory[proxy_hostname]

        tmp_inventory_file = Tempfile.new('acd_inventory')
        tmp_inventory_file << my_inventory.to_yaml
        tmp_inventory_file << "\n"
        tmp_inventory_file.close
        @inventory_path = tmp_inventory_file.path
      end

      def environment
        env = {}
        env['ANSIBLE_CALLBACK_WHITELIST'] = ''
        env['ANSIBLE_LOAD_CALLBACK_PLUGINS'] = '0'
        env
      end

      def setup_verbosity
        verbosity = ''
        if @acd_job['verbose']
          verbosity_level = @acd_job['verbose'].split(' ').first.to_i
          if verbosity_level.positive?
            verbosity = '-'
            verbosity_level.times do
              verbosity += 'v'
            end
          end
        end
        verbosity
      end

      def valid_tags(tag)
        re = /^\w+(\s*,\s*\w+)*$/
        return true if @acd_job[tag] && @acd_job[tag].match?(re)
      end

      def generate_command
        logger.debug("Generate command with #{@inventory_path} to run #{@playbook_id} with path #{@playbook_path}")
        command = [environment]
        command << 'ansible-playbook'
        command << '-i'
        command << @inventory_path
        verbose = setup_verbosity
        command << verbose unless verbose.empty?
        command << "--tags '#{@acd_job['tags']}'" if valid_tags('tags')
        command << "--skip-tags '#{@acd_job['skip_tags']}'" if valid_tags('skip_tags')
        if @acd_job.key?('extra_vars') && !@acd_job['extra_vars'].nil? && !@acd_job['extra_vars'].empty?
          command << '--extra-vars'
          command << "'#{@acd_job['extra_vars']}'"
        end
        command << @playbook_path.to_s
        command
      end
    end
  end
end

# rubocop:enable ClassLength
