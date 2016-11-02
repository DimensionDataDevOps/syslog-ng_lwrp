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

  tmpl = template "#{node['syslog_ng']['config_dir']}/conf.d/#{index}#{name}" do
    action :create
    source template_file
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 00640
    cookbook 'syslog-ng'

    variables(
      index: index,
      logpath_name: name,
      sources:      sources.is_a?(String)      ? [sources]      : sources,
      filters:      filters.is_a?(String)      ? [filters]      : filters,
      destinations: destinations.is_a?(String) ? [destinations] : destinations,
      flags:        flags.is_a?(String)        ? [flags]        : flags,
      source_prefix: source_prefix,
      destination_prefix: destination_prefix,
      filter_prefix: filter_prefix
    )
  end

  service_notify tmpl, new_resource
end

action :delete do
  service 'syslog-ng' do
    action :nothing
  end

  file "#{node['syslog_ng']['config_dir']}/conf.d/#{index}#{name}" do
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
