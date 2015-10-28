
include_recipe "syslog-ng"

syslog_ng_source "source_foo" do
  index "02"
  host "127.0.0.1"
  port "514"
end

syslog_ng_file "application_foo" do
  index "03"
  source_name "source_foo"
  days_uncompressed "7"
  log_base "/var/applogs"
  log_name "default.log"
end

syslog_ng_filter "warnings" do
  index  "04"
  filter "level(warning)"
end

syslog_ng_forwarder "application_foo_warnings" do
  index "05"
  source_name "source_foo"
  filter_name "warnings"
  destination_host "example.com"
  destination_port "514"
  destination_protocol "udp"
end
