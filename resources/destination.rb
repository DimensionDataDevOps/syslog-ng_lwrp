resource_name :syslog_ng_destination

property :name, String, name_property: true
property :host, String, default: 'localhost'
property :index, String, default: '02'
property :destination_prefix, String, default: node['syslog_ng']['destination_prefix']
property :template_file, String, default: 'syslog_ng_destination.erb'

property :drivers, [Hash, Array]

default_action :create

action :create do
  include_recipe 'syslog-ng'

  if drivers.is_a?(Hash)
    final_drivers = [drivers]
  elsif drivers.is_a?(Array)
    final_drivers = drivers
  elsif host
    final_drivers = [
      {
        'driver' => 'network',
        'options' => "host(\"#{host}\""
      }
    ]
  else
    fail 'Please specify driver(s) or a host.'
  end

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
      destination_name: new_resource.name,
      destination_prefix: destination_prefix,
      drivers: final_drivers
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