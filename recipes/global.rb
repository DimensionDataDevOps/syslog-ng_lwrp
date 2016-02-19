#
# Cookbook Name:: syslog-ng
# Recipe:: global
#
# Copyright 2011,2012 Artem Veremey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'syslog-ng'

package 'rsyslog' do
  action :purge
end

# Cleanup from < 2.0.2
cookbook_file "#{node['syslog_ng']['config_dir']}/conf.d/01global" do
  action :delete
  notifies :restart, 'service[syslog-ng]', :delayed
end

syslog_ng_source 'sys' do
  drivers [
    { 'driver' => 'file', 'options' => '"/proc/kmsg" log_prefix("kernel: ")' },
    { 'driver' => 'unix-stream', 'options' => '"/dev/log"' },
    { 'driver' => 'internal' }
  ]
end

{
  'cons' => { 'driver' => 'file', 'options' => '"/dev/console"' },
  'mesg' => { 'driver' => 'file', 'options' => '"/var/log/messages"' },
  'auth' => { 'driver' => 'file', 'options' => '"/var/log/secure"' },
  'mail' => { 'driver' => 'file', 'options' => '"/var/log/maillog" flush_lines(10)' },
  'spol' => { 'driver' => 'file', 'options' => '"/var/log/spooler"' },
  'boot' => { 'driver' => 'file', 'options' => '"/var/log/boot.log"' },
  'cron' => { 'driver' => 'file', 'options' => '"/var/log/cron"' },
  'kern' => { 'driver' => 'file', 'options' => '"/var/log/kern"' },
  'mlal' => { 'driver' => 'usertty', 'options' => '"*"' }
}.each do |dest_name, driver|
  syslog_ng_destination(dest_name) { drivers driver }
end

{
  'default' => 'level(info..emerg) and not (facility(mail) or facility(authpriv) or facility(cron))',
  'kernel' => 'facility(kern)',
  'auth' => 'facility(authpriv)',
  'mail' => 'facility(mail)',
  'emergency' => 'level(emerg)',
  'news' => 'facility(uucp) or (facility(news) and level(crit..emerg))',
  'boot' => 'facility(local7)',
  'cron' => 'facility(cron)'
}.each do |filter_name, filter_rule|
  syslog_ng_filter filter_name do
    filter filter_rule
  end
end

{
  'cons' => 'kernel',
  'kern' => 'kernel',
  'mesg' => 'default',
  'auth' => 'auth',
  'mail' => 'mail',
  'mlal' => 'emergency',
  'spol' => 'news',
  'boot' => 'boot',
  'cron' => 'cron'
}.each do |logpath_destination, logpath_filters|
  syslog_ng_logpath "global_#{logpath_destination}" do
    sources 'sys'
    filters logpath_filters
    destinations logpath_destination
  end
end
