default['syslog_ng']['user']            = 'root'
default['syslog_ng']['group']           = 'root'
default['syslog_ng']['log_dir']         = '/var/log/syslog-ng'
default['syslog_ng']['config_dir']      = '/etc/syslog-ng'
default['syslog_ng']['conf_version']    = '3.2'

default['syslog_ng']['options'] = {
  flush_lines: 0,
  time_reopen: 10,
  log_fifo_size: 1000,
  use_dns: 'no',
  use_fqdn: 'no',
  create_dirs: 'yes',
  keep_hostname: 'yes',
  chain_hostnames: 'yes'
}

# Objects of different types share the same namespace,
# so Hungarian notation is used to reduce collisions.
default['syslog_ng']['source_prefix']      = 's_'
default['syslog_ng']['destination_prefix'] = 'd_'
default['syslog_ng']['filter_prefix']      = 'f_'
