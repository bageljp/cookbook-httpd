#
# Cookbook Name:: httpd
# Recipe:: conf
#
# Copyright 2013, bageljp
#
# All rights reserved - Do Not Redistribute
#

case node['httpd']['conf']['template_dir']
when nil
  template "/etc/httpd/conf/httpd.conf" do
    owner "root"
    group "root"
    mode 00644
    source "httpd.conf-#{node['httpd']['version']['major']}.erb"
    notifies :restart, "service[httpd]"
  end
else
  Chef::Config[:cookbook_path].each{|elem|
    if File.exists?(File.join(elem, "/httpd/templates/default/", node['httpd']['conf']['template_dir']))
      conf_dir = File.join(elem, "/httpd/templates/default/", node['httpd']['conf']['template_dir'])
      Dir.chdir conf_dir
      confs = Dir::glob("**/*")

      confs.each do |t|
        if File::ftype("#{conf_dir}/#{t}") == "file"
          template "/etc/httpd/#{t}" do
            owner "root"
            group "root"
            mode 00644
            source "#{node['httpd']['conf']['template_dir']}/#{t}"
            notifies :restart, "service[httpd]"
          end
        else
          directory "/etc/httpd/#{t}" do
            owner "root"
            group "root"
            mode 00755
          end
        end
      end
    end
  }
end

