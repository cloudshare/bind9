#
# Cookbook Name:: bind9
# Recipe:: default
#
# Copyright 2012, CloudShare, Inc.
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

zones = data_bag_item(node.chef_environment, node['bind9']['zones_db_item'])

package "bind9" do
    action :install
    version "1:9.7.0.dfsg.P1-1ubuntu0.8"
end

ruby_block "read_rndc_key" do
    block do
        rndc_file = File.open('/etc/bind/rndc.key')
        node['bind9']['rndc_key'] = rndc_file.read()
        rndc_file.close()
    end
    action :create
end

package "dnsutils" do
    action :install
    version "1:9.7.0.dfsg.P1-1ubuntu0.8"
end

directory node['bind9']['log_dir'] do
    owner node['bind9']['user']
    group node['bind9']['user']
    mode 0755
end

service "bind9" do
    supports :status => true, :reload => true, :restart => true
    action :enable
end

template node['bind9']['options_file'] do
    source "named.conf.options.erb"
    owner 'root'
    group 'root'
    mode 0644
    notifies :restart, resources(:service => 'bind9')
end

template node['bind9']['local_file'] do
    source "named.conf.local.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables :zones => zones[node['bind9']['zones_db_item']]
    notifies :restart, resources(:service => 'bind9')
end

zones[node['bind9']['zones_db_item']].each do |domain, zone|
    zonefile_action = :create_if_missing

    if zone['mode'] == 'managed'
        search(:node, "chef_environment:#{node.chef_environment}").each do |host|
            next if host['ipaddress'] == '' || host['ipaddress'].nil?
            zone['records'].push({
                'name' => host['hostname'],
                'type' => 'A',
                'ip' => host['ipaddress'],
                'ttl' => zone['global_ttl']
            })
        end

        zonefile_action = :create
    end

    template "#{node['bind9']['data_dir']}/#{domain}.db" do
        source "zone.erb"
        owner "bind"
        group "bind"
        mode 0644
        variables :serial => Time.new.tv_sec,
            :master_nameserver => zone['master_nameserver'],
            :contact => zone['contact'],
            :domain => domain,
            :global_ttl => zone['global_ttl'],
            :nameservers => zone['nameservers'],
            :records => zone['records']

        notifies :restart, resources(:service => 'bind9')
        action zonefile_action
    end
end

service "bind9" do
    action :start
end
