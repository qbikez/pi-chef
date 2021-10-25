include_recipe '::gitconfig'
include_recipe '::docker'

git "#{node['home_assistant']['directory']}" do
  repository node['home_assistant']['repo']
  revision 'main'
  action :checkout

  user 'pi'
  group 'pi'

  notifies :restart, 'docker_compose_application[home_assistant]', :delayed
end

script 'git_pull' do
  interpreter 'bash'
  cwd node['home_assistant']['directory']
  code <<~EOH
    git pull
  EOH
    # https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
  only_if <<~EOH
    cd #{node['home_assistant']['directory']}

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

  # user 'pi'
  # group 'pi'
  # flags '-l'
  # environment 'HOME' => '/home/pi'

  notifies :restart, 'docker_compose_application[home_assistant]', :delayed
end

if node['home_assistant']['auto_push']
  script 'git_commit' do
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
    # flags '-l'
    # environment 'HOME' => '/home/pi'
  end

  script 'git_push' do
    interpreter 'bash'
    cwd node['home_assistant']['directory']
    code <<~EOH
      git push
    EOH
    only_if <<~EOH
      cd #{node['home_assistant']['directory']}

      UPSTREAM=${1:-'@{u}'}
      LOCAL=$(git rev-parse @)
      REMOTE=$(git rev-parse "$UPSTREAM")
      BASE=$(git merge-base @ "$UPSTREAM")

      if [ $LOCAL = $REMOTE ]; then
          echo "Up-to-date"
          exit 1
      elif [ $LOCAL = $BASE ]; then
          echo "Need to pull"
          exit 1
      elif [ $REMOTE = $BASE ]; then
          echo "Need to push"
          exit 0
      else
          echo "Diverged"
          exit 0
      fi
    EOH

    # user 'pi'
    # group 'pi'
    # flags '-l'
    # environment 'HOME' => '/home/pi'
  end
end

docker_compose_application 'home_assistant' do
  action :up
  compose_files [ "#{node['home_assistant']['directory']}/docker-compose.yml" ]
  user 'pi'
  group 'pi'
  # only_if "[ $(docker-compose -f #{compose_files.join(' -f ')} ps -q | wc -l) -eq 0 ]"
  # https://serverfault.com/questions/789601/check-is-container-service-running-with-docker-compose
  not_if <<~EOH
    set -x
    [ -z `docker-compose -f #{compose_files.join(' -f ')} ps -q` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose -f #{compose_files.join(' -f ')} ps -q)` ]
  EOH
end
