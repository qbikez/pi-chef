['/root', '/home/pi'].each do |home|
  template "#{home}/.gitconfig" do
    source '.gitconfig'
    sensitive true
    variables(
      username: 'pi-bot',
      email: 'pi-bot@example.org'
    )
  end

  template "#{home}/.git-credentials" do
    source '.git-credentials.erb'
    sensitive true
    variables repos: node['git']
  end
end
