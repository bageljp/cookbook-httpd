#
# Cookbook Name:: httpd
# Recipe:: default
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

case node['platform_family']
when "rhel"
  case node['httpd']['version']['major']
  when "2.4"
    # apache 2.4
    case node['httpd']['install_flavor']
    when "yum"
      %w(
        httpd24
        httpd24-devel
        httpd24-manual
      ).each do |pkg|
        package pkg
      end
    when "rpm"
      %w(
        db4-devel
        expat-devel
      ).each do |pkg|
        package pkg
      end

      %W(
        apr-1.5.1-1.x86_64.rpm
        apr-devel-1.5.1-1.x86_64.rpm
        apr-util-1.5.3-1.x86_64.rpm
        apr-util-devel-1.5.3-1.x86_64.rpm
        httpd-#{node['httpd']['version']['major']}.#{node['httpd']['version']['minor']}-1.x86_64.rpm
        httpd-devel-#{node['httpd']['version']['major']}.#{node['httpd']['version']['minor']}-1.x86_64.rpm
        httpd-tools-#{node['httpd']['version']['major']}.#{node['httpd']['version']['minor']}-1.x86_64.rpm
      ).each do |pkg|
        remote_file "/usr/local/src/#{pkg}" do
          owner "root"
          group "root"
          mode 00644
          source "#{node['httpd']['rpm']['url']}#{pkg}"
        end

        package pkg do
          provider Chef::Provider::Package::Rpm
          action :install
          source "/usr/local/src/#{pkg}"
        end
      end
    end

    template "/etc/sysconfig/httpd" do
      owner "root"
      group "root"
      mode 00644
      source "httpd.sysconfig24.erb"
      notifies :restart, 'service[httpd]'
    end
  when "2.2"
    # apache 2.2
    %w(httpd httpd-devel).each do |pkg|
      package pkg
    end

    template "/etc/sysconfig/httpd" do
      owner "root"
      group "root"
      mode 00644
      source "httpd.sysconfig.erb"
      notifies :restart, 'service[httpd]'
    end
  end

  template "/etc/logrotate.d/httpd" do
    owner "root"
    group "root"
    mode 00644
    source "httpd.logrotate.erb"
  end

  if node['httpd']['group']['add'] != nil
    group "#{node['httpd']['group']['add']}" do
      action :modify
      members "#{node['httpd']['user']}"
      append true
    end
  end

  include_recipe 'httpd::mods'

  service 'httpd' do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

end

