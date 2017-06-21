include Chef::SyslogNg

resource_name :syslog_ng_source

property :name, String, name_property: true
property :host, String, default: 'localhost'
property :port, [Integer, String], default: 514
property :index, String, default: '02'
property :source_prefix, String, default: node['syslog_ng']['source_prefix']
property :template_file, String, default: 'syslog_ng_source.erb'

property :drivers, [Hash, Array]

default_action :create

action :create do
  include_recipe 'syslog-ng'

  final_drivers = if drivers.is_a?(Hash)
                    [drivers]
                  elsif drivers.is_a?(Array)
                    drivers
                  else
                    [
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

  tmpl = template "#{node['syslog_ng']['config_dir']}/conf.d/#{index}#{name}" do
    action :create
    source template_file
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 0o0640
    cookbook 'syslog-ng'

    variables(
      index: index,
      source_name: new_resource.name,
      source_prefix: source_prefix,
      drivers: final_drivers
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
