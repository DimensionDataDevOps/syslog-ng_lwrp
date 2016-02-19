include_recipe 'yum-epel' if platform_family?('rhel')

include_recipe 'syslog-ng'

syslog_ng_source 'network_source' do
  index '01'
  host '127.0.0.1'
  port '514' # TCP+UDP
end

syslog_ng_source 'custom_source' do
  index '02'
  drivers [
    {
      'driver' => 'syslog',
      'options' => 'port(9999)'
    },
    {
      'driver' => 'pipe',
      'options' => '"/dev/pipe"'
    }
  ]
end

syslog_ng_filter 'warnings' do
  index  '04'
  filter 'level(warning)'
end

syslog_ng_forwarder 'application_foo_warnings' do
  index '05'
  source_name 'custom_source'
  filter_name 'warnings'
  destination_host 'localhost'
  destination_port '514'
  destination_protocol 'udp'
end

syslog_ng_destination 'tmp_logfile' do
  index '06'
  drivers [
    {
      'driver' => 'file',
      'options' => '"/tmp/logfile"'
    }
  ]
end

syslog_ng_logpath 'test_logpath' do
  index '07'
  sources ['custom_source']
  destinations ['tmp_logfile']
end

syslog_ng_file 'myapp' do
  index '08'
  source_name %w(custom_source network_source)
end
