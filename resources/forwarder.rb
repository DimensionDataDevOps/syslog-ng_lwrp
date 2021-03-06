resource_name :syslog_ng_forwarder

property :name, String, name_property: true
property :index, String, default: '04'
property :sources, [Array, String]
property :source_prefix, String, default: node['syslog_ng']['source_prefix']
property :filters, [Array, String, nil], default: nil

property :destination_host, required: true
property :destination_port, default: '514'
property :destination_protocol, default: 'udp'

default_action :create

action :create do
  syslog_ng_destination "#{new_resource.name}_destination" do
    index new_resource.index
    drivers(
      'driver' => new_resource.destination_protocol,
      'options' => "\"#{new_resource.destination_host}\" port(#{new_resource.destination_port})"
    )
  end

  syslog_ng_logpath "#{new_resource.name}_logpath" do
    action new_resource.sources ? :create : :delete
    index new_resource.index
    sources new_resource.sources
    filters new_resource.filters
    destinations ["#{new_resource.name}_destination"]
  end
end

action :delete do
  syslog_ng_destination "#{new_resource.name}_destination" do
    action :delete
  end

  syslog_ng_logpath "#{new_resource.name}_logpath" do
    action :delete
  end
end

# https://github.com/chef/chef/issues/4537
action_class do
  def whyrun_supported?
    true
  end
end
