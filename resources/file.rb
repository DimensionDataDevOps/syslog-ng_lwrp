resource_name :syslog_ng_file

property :name, String, name_property: true
property :index, String, default: '04'
property :sources, [Array, String]
property :source_prefix, String, default: node['syslog_ng']['source_prefix']
property :filters, [Array, String, nil], default: nil

property :days_uncompressed, Integer, default: 1
property :log_base, String, default: node['syslog_ng']['log_dir']
property :log_name, String, default: 'default.log'

default_action :create

action :create do
  include_recipe 'syslog-ng'

  log_file = "#{new_resource.log_base}/#{new_resource.name}/#{new_resource.log_name}"

  directory new_resource.log_base do
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 0o0755
    action :create
  end

  directory "#{new_resource.log_base}/#{new_resource.name}" do
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 0o0755
    action :create
  end

  syslog_ng_destination "#{new_resource.name}_destination" do
    index new_resource.index
    drivers(
      'driver' => 'file',
      'options' => "\"#{log_file}\""
    )
  end

  syslog_ng_logpath "#{new_resource.name}_logpath" do
    action new_resource.sources ? :create : :delete
    index new_resource.index
    sources new_resource.sources
    filters new_resource.filters || []
    destinations ["#{new_resource.name}_destination"]
  end

  template "/etc/cron.daily/#{new_resource.name}_compress_logs" do
    source 'compress_logs.erb'
    cookbook 'syslog-ng'
    mode 0o0755
    owner 'root'
    group 'root'
    variables(
      log_base: new_resource.log_base,
      name: new_resource.name,
      days_uncompressed: new_resource.days_uncompressed
    )
  end
end

action :delete do
  syslog_ng_logpath "#{new_resource.name}_logpath" do
    action :delete
  end

  template "/etc/cron.daily/#{new_resource.name}_compress_logs" do
    action :delete
  end
end

# https://github.com/chef/chef/issues/4537
action_class do
  def whyrun_supported?
    true
  end
end
