include Chef::SyslogNg

resource_name :syslog_ng_filter

property :name, String, name_property: true
property :index, String, default: '03'
property :filter_prefix, String, default: node['syslog_ng']['filter_prefix']
property :template_file, String, default: 'syslog_ng_filter.erb'

property :filter, String, required: true

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
      filter_name: new_resource.name,
      filter_prefix: new_resource.filter_prefix,
      filter: new_resource.filter
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
