package 'openvpn'

service 'openvpn' do
  action [:enable, :start]
end

node['openvpn'].each do |profile|
  remote_file "/etc/openvpn/#{profile}" do
    source "file:///boot/chef/openvpn/#{profile}"
    sensitive true
  end
end

# uncomment lines in openvpn config
# https://stackoverflow.com/questions/14848110/how-can-i-change-a-file-with-chef
openvpn_config = '/etc/default/openvpn'
commented_autostart = /^#\s+(AUTOSTART\s*=\s*"all")/

ruby_block 'openvpn_autostart' do
  block do
    sed = Chef::Util::FileEdit.new(openvpn_config)
    sed.search_file_replace(commented_limits, '\1')
    sed.write_file
  end

  only_if { ::File.readlines(openvpn_config).grep(commented_autostart).any? }

  notifies :reload, 'service[openvpn]', :immediately
  notifies :restart, 'service[openvpn]', :delayed
end


# script 'enable_openvpn' do
#   interpreter "bash"
#   code <<-EOH
#     systemctl daemon-reload
#     systemctl enable openvpn
#   EOH
#   not_if 'systemclt status openvpn'
# end