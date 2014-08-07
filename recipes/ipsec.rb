#
# Cookbook Name:: strongSwan-base
# Description:: Installs and launches a StrongSwan server.
# Recipe:: ipsec
# Author:: Jerry Jackson (<jerry.w.jackson@gmail.com>)
#
# Copyright 2012, Infochimps
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

# if we're on AltLinux, Debian, Fedora, Oracle, Redhat, RHEL, or CentOS we need to install the EPEL 
# yum repository.
if %w{ altlinux, amazon, centos, debian, fedora, oracle, redhat, rhel }.include?(node["platform_family"])
	node.default['yum']['epel-testing']['enabled'] = true
	node.default['yum']['epel-testing']['managed'] = true
	include_recipe 'yum-epel'
end

# install strongswan from package
# Note: future versions will use the charon daemon only; watch out for
#   changed package names and configuration formats on upgrade
package "strongswan"      # the new charon daemon

# ipsec service definition
service "ipsec" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

%w{ ipsec.conf ipsec.secrets strongswan.conf }.each do |fname|
  template "/etc/#{fname}" do
    source "ipsec-core/#{fname}.erb"
    notifies :reload, "service[ipsec]", :delayed
  end
end

announce( :strongswan, :ipsec )
