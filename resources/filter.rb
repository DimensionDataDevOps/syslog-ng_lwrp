resource_name :syslog_ng_filter

property :name, String, name_property: true
property :host, String, default: 'localhost'
property :index, String, default: '03'
property :filter_prefix, String, default: node['syslog_ng']['filter_prefix']
property :template_file, String, default: 'syslog_ng_filter.erb'

property :filter, String, required: true

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
      filter_name: new_resource.name,
      filter_prefix: filter_prefix,
      filter: filter
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