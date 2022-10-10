# tailscale

apt_repository 'tailscale' do
    uri        'https://pkgs.tailscale.com/stable/raspbian'
    key        'https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg'
    components ['main']
end
  
package 'tailscale'
  
  # script 'tailscale_install' do
  #   interpreter "bash"
  #   code <<-EOH
  #     apt-get install -y apt-transport-https
  #     curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.gpg | sudo apt-key add -
  #     curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.list | sudo tee /etc/apt/sources.list.d/tailscale.list
  
  #     apt-get update
  #     apt-get install -y tailscale
  #   EOH
  
  #   not_if 'which tailscale'
  # end
  
script 'tailscale_up' do
  interpreter "bash"
  # go to https://login.tailscale.com/admin/settings/authkeys and create an auth key, then put it in node attributes
  code <<-EOH
    tailscale up --authkey=#{node['tailscale']['authkey']}
    tailscale ip -4
  EOH

  not_if 'tailscale ip'
end
