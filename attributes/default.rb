default[:syslog_ng][:user]            = 'root'
default[:syslog_ng][:group]           = 'root'
default[:syslog_ng][:log_dir]         = '/var/log/syslog-ng'
default[:syslog_ng][:config_dir]      = '/etc/syslog-ng'
default[:syslog_ng][:sync]            = 0
default[:syslog_ng][:time_reopen]     = 10
default[:syslog_ng][:log_fifo_size]   = 1000
default[:syslog_ng][:long_hostnames]  = 'off'
default[:syslog_ng][:use_dns]         = 'no'
default[:syslog_ng][:use_fqdn]        = 'no'
default[:syslog_ng][:create_dirs]     = 'yes'
default[:syslog_ng][:keep_hostname]   = 'yes'
default[:syslog_ng][:chain_hostnames] = 'yes'
default[:syslog_ng][:global_opts]     = []

# Objects of different types share the same namespace,
# so Hungarian notation is used to reduce collisions.
default[:syslog_ng][:source_prefix]      = 's_'
default[:syslog_ng][:destination_prefix] = 'd_'
default[:syslog_ng][:filter_prefix]      = 'f_'
