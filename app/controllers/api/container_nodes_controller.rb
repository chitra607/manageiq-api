module Api
  class ContainerNodesController < BaseController
    def check_compliance_resource(type, id, _data = nil)
      enqueue_ems_action(type, id, "Check Compliance for", :method_name => "check_compliance", :supports => true)
    end

    def edit_resource(type, id, data = {})
      api_resource(type, id, "Updating") do |container_node|
        {:task_id => container_node.update_container_node_queue(User.current_userid, data)}
      end
    end

    def get_metadata_resource(type, id, data = {})
      container_node = resource_search(id, :container_nodes, ContainerNode)
      metadata = container_node.get_node_metadata
      {
        :id                        => container_node.id,
        :name                      => container_node.name,
        :container_runtime_version => container_node.container_runtime_version,
        :kernel_version            => container_node.operating_system.kernel_version,
        :kubernetes_version        => container_node.kubernetes_kubelet_version,
        :hostname                  => container_node.operating_system&.host&.hostname || 'unknown',
        :max_container_groups      => container_node.max_container_groups,
        :operating_system          => container_node.operating_system&.name || 'unknown',
        :ext_management_system     => {
          :id   => container_node.ext_management_system&.id,
          :name => container_node.ext_management_system&.name
        },
        :labels                    => metadata[:labels],
        :annotations               => metadata[:annotations],
        :addresses                 => metadata[:addresses],
        :schedulable               => metadata[:schedulable]
      }
    rescue => err
      action_result(false, err.to_s)
    end
  end
end
