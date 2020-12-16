require 'foreman_tasks_core'
require 'foreman_remote_execution_core'

# SmartProxyAcdCore
module SmartProxyAcdCore
  extend ForemanTasksCore::SettingsLoader

  if ForemanTasksCore.dynflow_present?
    require 'smart_proxy_acd_core/acd_runner'
    require 'smart_proxy_acd_core/acd_task_launcher'

    if defined?(SmartProxyDynflowCore)
      SmartProxyDynflowCore::TaskLauncherRegistry.register('acd', AcdTaskLauncher)
    end
  end
end
