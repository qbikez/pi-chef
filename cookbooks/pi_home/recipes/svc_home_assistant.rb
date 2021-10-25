include_recipe '::gitconfig'
include_recipe '::docker'

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
  user 'pi'
  group 'pi'
  flags '-l'
  only_if <<~EOH
    # https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        echo "Up-to-date"
        exit 1
    elif [ $LOCAL = $BASE ]; then
        echo "Need to pull"
        exit 0
    elif [ $REMOTE = $BASE ]; then
        echo "Need to push"
        exit 1
    else
        echo "Diverged"
        exit 0
    fi
  EOH
  notifies :restart, 'docker_compose_application[homeassistant2]', :delayed
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
  user 'pi'
  group 'pi'
  flags '-l'
end

docker_compose_application 'homeassistant2' do
  action :up
  compose_files [ "#{node['home_assistant']['directory']}/docker-compose.yml" ]
  user 'pi'
  group 'pi'
end
