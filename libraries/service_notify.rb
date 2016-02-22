class Chef
  module SyslogNg
    # Adds a notification directly to the top level run_context based on if the template changed.
    # This hoop jumping is because I can't figure out how to have the template notify the service directly without other problems.
    # https://github.com/chef/chef/issues/3123
    # https://github.com/chef/chef/issues/3575
    def service_notify(tmpl, new_resource)
      updated_by_last_action ||= tmpl.updated_by_last_action?
      syslog_ng_service = Chef.run_context.resource_collection.find('service[syslog-ng]')
      Chef.run_context.notifies_delayed(Chef::Resource::Notification.new(syslog_ng_service, :restart, new_resource))
    end
  end
end
