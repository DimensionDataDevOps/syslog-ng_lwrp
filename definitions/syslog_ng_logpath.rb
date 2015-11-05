#
# Cookbook Name:: syslog-ng
# Definition:: syslog_ng_logpath
#
# Copyright 2012, Artem Veremey
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

define :syslog_ng_logpath, template: 'syslog_ng_logpath.erb' do
  include_recipe 'syslog-ng'

  logpath = {
    name: params[:name],
    index: params[:index] || '02',
    cookbook: params[:cookbook] || 'syslog-ng',
    sources: params[:sources],
    destinations: params[:destinations],
    filters: params[:filters] || [],
    flags: params[:flags] || []
  }

  # Allow users to use a string if only one of a type is needed
  [:sources, :filters, :destinations, :flags].each do |type|
    logpath[type] = [logpath[type]] if logpath[type].is_a?(String)
  end

  template "#{node['syslog_ng']['config_dir']}/conf.d/#{logpath[:index]}#{logpath[:name]}" do
    source params[:template]
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 00640
    cookbook logpath[:cookbook]

    cookbook params[:cookbook] if params[:cookbook]

    variables(
      logpath: logpath
    )

    notifies :restart, 'service[syslog-ng]', :immediately
  end
end
