group 'docker' do
  append true
  members ['pi']
end

include_recipe 'docker_compose::installation'

docker_network 'pinet' do
  subnet '10.9.8.0/24'
  gateway '10.9.8.1'
end
