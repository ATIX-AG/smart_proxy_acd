require 'foreman_tasks_core/runner/command_runner'
require 'tempfile'

module SmartProxyAcdCore
  # Implements the AcdRunner to be used by foreman_remote_execution
  class AcdRunner < ForemanTasksCore::Runner::CommandRunner
    DEFAULT_REFRESH_INTERVAL = 1

    def initialize(options, suspended_action:)
      super(options, :suspended_action => suspended_action)
      @options = options
    end

    def start
      parse_acd_job
      write_inventory
      command = generate_command
      logger.debug("Running command '#{command.join(' ')}'")
      initialize_command(*command)
    end

    def kill
      publish_data('== TASK ABORTED BY USER ==', 'stdout')
      publish_exit_status(1)
      ::Process.kill('SIGTERM', @command_pid)
    end

    private
    def parse_acd_job
      @acd_job = YAML.load(@options['script'])
      @playbook_name = @acd_job['playbook-name']
      @playbook_path = @acd_job['playbook-path']

      raise "'playbook-name' need to be specified" if @playbook_name.nil? || @playbook_name.empty?
      raise "'playbook-path' need to be specified" if @playbook_path.nil? || @playbook_path.empty?
    end

    def write_inventory
      inventory = Tempfile.new('acd_inventory')
      inventory << @acd_job['inventory']
      inventory << "\n"
      inventory.close
      @inventory_path = inventory.path
    end

    def environment
      env={}
      env['ANSIBLE_CALLBACK_WHITELIST'] = ''
      env['ANSIBLE_LOAD_CALLBACK_PLUGINS'] = '0'
      env
    end

    def generate_command
      logger.debug("Generate command with #{@inventory_path} to run #{@playbook_name} with path #{@playbook_path}")
      command = [environment]
      command << "ansible-playbook"
      command << "-i"
      command << @inventory_path
      command << "-v" if @acd_job['verbose'] == true
      if @acd_job.has_key?('extra-vars') && !@acd_job['extra-vars'].nil? && !@acd_job['extra-vars'].empty?
        command << "--extra-vars"
        command << "'#{@acd_job['extra-vars']}'"
      end
      command << "#{@playbook_path}"
      command
    end
  end
end
