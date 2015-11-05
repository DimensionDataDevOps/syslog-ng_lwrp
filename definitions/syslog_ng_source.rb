#
# Cookbook Name:: syslog-ng
# Definition:: syslog_ng_file
#
# Copyright 2012, Artem Veremey
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

define :syslog_ng_source, template: 'syslog_ng_source.erb' do
  include_recipe 'syslog-ng'

  application = {
    name: params[:name],
    source_prefix: params[:source_prefix] || node['syslog_ng']['source_prefix'],
    index: params[:index] || '02',
    cookbook: params[:cookbook] || 'syslog-ng',
    host: params[:host] || '127.0.0.1',
    port: params[:port] || '514'
  }

  drivers = params[:drivers] || params[:driver]
  drivers = [drivers] if drivers.is_a?(Hash)

  if drivers.nil?
    drivers = [
      {
        'driver' => 'tcp',
        'options' => "ip(\"#{application[:host]}\") port(#{application[:port]})"
      },
      {
        'driver' => 'udp',
        'options' => "ip(\"#{application[:host]}\") port(#{application[:port]})"
      }
    ]
  end

  template "#{node['syslog_ng']['config_dir']}/conf.d/#{application[:index]}#{application[:name]}" do
    source params[:template]
    owner node['syslog_ng']['user']
    group node['syslog_ng']['group']
    mode 00640
    cookbook application[:cookbook]

    cookbook params[:cookbook] if params[:cookbook]

    variables(
      application: application,
      drivers: drivers
    )

    notifies :restart, 'service[syslog-ng]', :immediately
  end
end
