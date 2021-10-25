git '/home/pi/docker/homeassistant2' do
  repository node['home_assistant']['repo']
  revision 'main'
  action :checkout
  user 'pi'
  group 'pi'

  notifies :restart, 'docker_compose_application[homeassistant2]', :delayed
end

script 'git_pull' do
  interpreter 'bash'
  cwd node['home_assistant']['directory']
  code <<~EOH
    git pull
  EOH
  # user 'pi'
  # group 'pi'
end 

script 'git_sync' do
  interpreter 'bash'
  cwd node['home_assistant']['directory']
  code <<~EOH
    git add .
    git commit -m "autocommit"
    # git push
  EOH
  only_if <<~EOH
    cd #{node['home_assistant']['directory']}
    git status --porcelain
    [ -n "$(git status --porcelain)" ]
  EOH
  # user 'pi'
  # group 'pi'
end

docker_compose_application 'homeassistant2' do
  action :up
  compose_files [ "#{node['home_assistant']['directory']}/docker-compose.yml" ]
  user 'pi'
  group 'pi'
end
