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

  service 'syslog-ng' do
    action :nothing
  end

  template "#{node['syslog_ng']['config_dir']}/conf.d/#{index}#{name}" do
    action :create
    source template_file
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 00640
    cookbook 'syslog-ng'

    variables(
      index: index,
      logpath_name: name,
      # rubocop:disable Style/SpaceAroundOperators
      sources:      sources.is_a?(String)      ? [sources]      : sources,
      filters:      filters.is_a?(String)      ? [filters]      : filters,
      destinations: destinations.is_a?(String) ? [destinations] : destinations,
      flags:        flags.is_a?(String)        ? [flags]        : flags,
      # rubocop:enable Style/SpaceAroundOperators
      source_prefix: source_prefix,
      destination_prefix: destination_prefix,
      filter_prefix: filter_prefix
    )

    notifies :restart, 'service[syslog-ng]', :delayed
  end
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
