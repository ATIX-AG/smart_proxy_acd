module Proxy
  module Acd
    # Implements the TaskLauncher::Batch for Acd
    class AcdTaskLauncher < ForemanTasksCore::TaskLauncher::Batch
      # Implements the Runner::Action for Acd
      class AcdRunnerAction < ForemanTasksCore::Runner::Action
        def initiate_runner
          additional_options = {
            :step_id => run_step_id,
            :uuid => execution_plan_id
          }
          ::Proxy::Acd::AcdRunner.new(
            input.merge(additional_options),
            :suspended_action => suspended_action
          )
        end
      end

      def child_launcher(parent)
        ForemanTasksCore::TaskLauncher::Single.new(world, callback, :parent => parent,
                                                                    :action_class_override => AcdRunnerAction)
      end
    end
  end
end
