#
# Cookbook Name:: syslog-ng
# Recipe:: default
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

package 'syslog-ng-core' if platform?('ubuntu')

package 'syslog-ng'

directory "#{node['syslog_ng']['config_dir']}/conf.d" do
  owner node['syslog_ng']['user']
  group node['syslog_ng']['group']
  mode 00750
  action :create
end

directory node['syslog_ng']['log_dir'] do
  owner node['syslog_ng']['user']
  group node['syslog_ng']['group']
  mode 00755
  action :create
end

template "#{node['syslog_ng']['config_dir']}/syslog-ng.conf" do
  source 'syslog-ng.conf.erb'
  owner node['syslog_ng']['user']
  group node['syslog_ng']['group']
  mode 00640
  variables(
    conf_version: node['syslog_ng']['conf_version'],
    options: node['syslog_ng']['options']
  )
  notifies :restart, 'service[syslog-ng]', :delayed
end

service 'syslog-ng' do
  supports restart: true, status: true
  action [:enable, :start]
end
