resource_name :syslog_ng_source

property :name, String, name_property: true
property :host, String, default: 'localhost'
property :port, [Fixnum, String], default: 514
property :index, String, default: '02'
property :source_prefix, String, default: node['syslog_ng']['source_prefix']
property :template_file, String, default: 'syslog_ng_source.erb'

property :drivers, [Hash, Array]

default_action :create

action :create do
  include_recipe 'syslog-ng'

  if drivers.is_a?(Hash)
    final_drivers = [drivers]
  elsif drivers.is_a?(Array)
    final_drivers = drivers
  else
    final_drivers = [
      {
        'driver' => 'tcp',
        'options' => "ip(\"#{host}\") port(#{port})"
      },
      {
        'driver' => 'udp',
        'options' => "ip(\"#{host}\") port(#{port})"
      }
    ]
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
      source_name: new_resource.name,
      source_prefix: source_prefix,
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
