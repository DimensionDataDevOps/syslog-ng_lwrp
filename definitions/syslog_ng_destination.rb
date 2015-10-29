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

define :syslog_ng_destination, :template => "syslog_ng_destination.erb" do
  include_recipe "syslog-ng"

  destination = {
    :name => params[:name],
    :destination_prefix => params[:destination_prefix] || node[:syslog_ng][:destination_prefix],
    :index => params[:index] || "02",
    :cookbook => params[:cookbook] || "syslog-ng",
  }

  if params[:host]
    drivers = [
      {
        "driver" => "network",
        "options" => "host(\"#{params[:host]}\"",
      }
    ]
  else
    drivers = params[:drivers]
  end

  template "#{node[:syslog_ng][:config_dir]}/conf.d/#{destination[:index]}#{destination[:name]}" do
    source params[:template]
    owner node[:syslog_ng][:user]
    group node[:syslog_ng][:group]
    mode 00640
    cookbook destination[:cookbook]

    if params[:cookbook]
      cookbook params[:cookbook]
    end

    variables(
      :destination => destination,
      :drivers => drivers
    )

    notifies :restart, resources(:service => "syslog-ng"), :immediately
  end
end
