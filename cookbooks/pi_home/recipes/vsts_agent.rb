include_recipe 'vsts_agent::default'

vsts_agent "#{node['vsts_agent']['name']}" do
  install_dir '/home/pi/vsts-agent'
  user 'pi'
  group 'pi'
  path '/usr/local/bin/:/usr/bin:/opt/bin/'
  vsts_url node['vsts_agent']['url']
  vsts_pool node['vsts_agent']['pool']
  vsts_token node['vsts_agent']['PAT']
  # deploymentGroup true
  # deploymentGroupName 'raspberry'
  action :install
  sensitive false
  version '2.193.1'
end

vsts_agent 'pi-agent-01' do
  action :restart
end
