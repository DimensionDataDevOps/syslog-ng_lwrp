include Chef::SyslogNg

resource_name :syslog_ng_logpath

property :name, String, name_property: true
property :index, String, default: '04'
property :template_file, String, default: 'syslog_ng_logpath.erb'

property :sources, [String, Array], required: true
property :filters, [String, Array], default: []
property :destinations, [String, Array], required: true
property :flags, [String, Array]

property :source_prefix, String, default: node['syslog_ng']['source_prefix']
property :filter_prefix, String, default: node['syslog_ng']['filter_prefix']
property :destination_prefix, String, default: node['syslog_ng']['destination_prefix']

default_action :create

action :create do
  include_recipe 'syslog-ng'

  tmpl = template "#{node['syslog_ng']['config_dir']}/conf.d/#{new_resource.index}#{new_resource.name}" do
    action :create
    source new_resource.template_file
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 0o0640
    cookbook 'syslog-ng'

    variables(
      index: new_resource.index,
      logpath_name: new_resource.name,
      sources: new_resource.sources.is_a?(String) ? [new_resource.sources] : new_resource.sources,
      filters: new_resource.filters.is_a?(String) ? [new_resource.filters] : new_resource.filters,
      destinations: new_resource.destinations.is_a?(String) ? [new_resource.destinations] : new_resource.destinations,
      flags: new_resource.flags.is_a?(String) ? [new_resource.flags] : new_resource.flags,
      source_prefix: new_resource.source_prefix,
      destination_prefix: new_resource.destination_prefix,
      filter_prefix: new_resource.filter_prefix
    )
  end

  service_notify tmpl, new_resource
end

action :delete do
  service 'syslog-ng' do
    action :nothing
  end

  file "#{node['syslog_ng']['config_dir']}/conf.d/#{new_resource.index}#{new_resource.name}" do
    action :delete
    notifies :restart, 'service[syslog-ng]', :delayed
  end
end

# https://github.com/chef/chef/issues/4537
action_class do
  def whyrun_supported?
    true
  end
end
