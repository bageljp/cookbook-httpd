#
# Cookbook Name:: httpd
# Recipe:: mods
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

if node['httpd']['mod_extract_forwarded']['enable']
  case node['httpd']['version']['major']
  when '2.4'
    log "Please use the mod_remoteip that are loaded by default apache 2.4"
  else
    yum_package "mod_extract_forwarded" do
      action :install
      options "--enablerepo=epel"
      notifies :restart, 'service[httpd]'
    end
  
    template "/etc/httpd/conf.d/mod_extract_forwarded.conf" do
      owner "root"
      group "root"
      mode 00644
    end
  end
end

if node['httpd']['mod_ssl']['enable']
  case node['httpd']['version']['major']
  when "2.4"
    case node['httpd']['install_flavor']
    when "yum"
      package 'mod24_ssl'
    when "rpm"
      %w(
        mod_ssl-2.4.10-1.x86_64.rpm
      ).each do |pkg|
        remote_file "/usr/local/src/#{pkg}" do
          owner "root"
          group "root"
          mode 00644
          source "#{node['httpd']['rpm']['url']}#{pkg}"
        end

        package pkg do
          action :install
          provider Chef::Provider::Package::Rpm
          source "/usr/local/src/#{pkg}"
        end
      end
    end
  when "2.2"
    package 'mod_ssl'
  end

  directory "#{node['httpd']['mod_ssl']['root_dir']}" do
    owner "root"
    group "root"
    mode 00755
    recursive true
  end

  directory "#{node['httpd']['mod_ssl']['root_dir']}/#{node['httpd']['mod_ssl']['link_dir']}" do
    owner "root"
    group "root"
    mode 00755
    recursive true
  end

  %W(
    #{node['httpd']['mod_ssl']['server_key']}
    #{node['httpd']['mod_ssl']['server_crt']}
    #{node['httpd']['mod_ssl']['chain_crt']}
  ).each do |pem|
    if !pem.empty?
      cookbook_file "#{node['httpd']['mod_ssl']['root_dir']}/#{node['httpd']['mod_ssl']['link_dir']}/#{pem}" do
        owner "root"
        group "root"
        mode 00644
        notifies :restart, 'service[httpd]'
      end
      link "#{node['httpd']['mod_ssl']['root_dir']}/#{pem}" do
        owner "root"
        group "root"
        to "#{node['httpd']['mod_ssl']['link_dir']}/#{pem}"
      end
    end
  end
end

if node['httpd']['mod_php']['enable']
  template "/etc/httpd/conf.d/php.conf" do
    owner "root"
    group "root"
    mode 00644
    notifies :restart, 'service[httpd]'
  end
end

