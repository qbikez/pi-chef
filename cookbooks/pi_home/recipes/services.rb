
docker_compose_application 'grafana' do
    action :up
    compose_files [ '/home/pi/docker/grafana/docker-compose.yaml' ]
    user 'pi'
    group 'pi'
  end