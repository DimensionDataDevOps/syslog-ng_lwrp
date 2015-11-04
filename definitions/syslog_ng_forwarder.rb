#
# Cookbook Name:: syslog-ng
# Definition:: syslog_ng_forwarder
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

define :syslog_ng_forwarder, template: 'syslog_ng_forwarder.erb' do
  include_recipe 'syslog-ng'

  application = {
    name: params[:name],
    index: params[:index] || '02',
    cookbook: params[:cookbook] || 'syslog-ng',
    source_name: params[:source_name],
    source_prefix: params[:source_prefix] || node[:syslog_ng][:source_prefix],
    destination_host: params[:destination_host],
    destination_port: params[:destination_port] || '514',
    destination_protocol: params[:destination_protocol] || 'udp'
  }

  # filter_name is optional
  application[:filter_name] = params[:filter_name] if params[:filter_name]

  syslog_ng_destination "#{application[:name]}_destination" do
    index application[:index]
    drivers(
      'driver' => application[:destination_protocol],
      'options' => "\"#{application[:destination_host]}\" port(#{application[:destination_port]})"
    )
  end

  if application[:source_name]
    syslog_ng_logpath "#{application[:name]}_logpath" do
      index application[:index]
      sources application[:source_name]
      filters application[:filter_name]
      destinations ["#{application[:name]}_destination"]
    end
  end
end
