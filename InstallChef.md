# Install Chef on Raspberry Pi

0. Install tmux

The commands can take a while to execute. It would be a shame to interrupt them in case you lost ssh connection. I advise use of `tmux` or similar tool.

```shell
apt install -y tmux
```

1. Install ruby

Raspbian has ruby 2., but that's too old for chef, whick needs >=2.6. 
We'll use rbenv to install a newer version of ruby.

```shell
sudo apt update
sudo apt install -y rbenv git
echo 'eval "$(rbenv init -)"' >> .bashrc
source .bashrc

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# install required libraries
sudo apt install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev

# check the list of available ruby releases
git -C ~/.rbenv/plugins/ruby-build pull
rbenv install --list

# download and install desired version of ruby
rbenv install 3.0.2 -v
# go make yourself a coffee...
# ...
# ..
# .

# set installed version as the default
rbenv global 3.0.2
# verify
ruby -v
```

2. Install chef via gem (another coffee perhaps?)

```shell
# export RBENV_VERSION=2.3.1
gem install chef --verbose --debug
gem install chef-bin --verbose --debug
gem install berkshelf --verbose --debug
gem install inspec --verbose --debug
```

3. Fill the gaps

Chef gems don't install all the needed binaries, so we have to download them manually:

```shell
# download shims
sudo curl https://raw.githubusercontent.com/chef/chef/master/chef-bin/bin/chef-client -o /usr/bin/chef-client
sudo curl https://raw.githubusercontent.com/chef/chef/master/chef-bin/bin/chef-solo  -o /usr/bin/chef-solo
sudo curl https://raw.githubusercontent.com/berkshelf/berkshelf/main/bin/berks  -o /usr/bin/berks
sudo curl https://raw.githubusercontent.com/inspec/inspec/main/inspec-bin/bin/inspec -o /usr/bin/inspec
sudo chmod 0755 /usr/bin/chef*
sudo chmod 0755 /usr/bin/berks
sudo chmod 0755 /usr/bin/inspec

chef-client -v

# to run rbenv as superuser, we need rbenv-sudo
git clone https://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

# finally, accept chef license
rbenv sudo chef-solo --version --chef-license accept
```

4. License

 Create these files:

```bash
# /etc/chef/accepted_licenses/chef_infra_client
---
id: infra-client
name: Chef Infra Client
date_accepted: '2022-03-17T06:04:41+01:00'
accepting_product: infra-client
accepting_product_version: 17.9.52
user: pi
file_format: 1
```

```bash
# /etc/chef/accepted_licenses/inspec 
---
id: inspec
name: Chef InSpec
date_accepted: '2022-03-17T06:04:41+01:00'
accepting_product: infra-client
accepting_product_version: 17.9.52
user: pi
file_format: 1
```

5. Test

```shell
cd whatever_cookbook_you_have_lying_around

# chef zero needs all the dependencies to be installed inside `cookbooks` dir
berks vendor cookbooks 
rbenv sudo chef-client -z --runlist "default"
```

## References

* [Using Chef to provision Raspberry Pi’s](https://thuisapp.com/2016/06/12/using-chef-provision-raspberry-pis/)
* [raspbian_boostrap for knife](https://github.com/dayne/raspbian_bootstrap)
* [Installing the latest version of Ruby on Raspberry pi](https://dev.to/konyu/installing-the-latest-version-of-ruby-on-raspberry-pi-3ofk)
* [Installing Chef on a Pi with Raspbian OS](https://medium.com/@timcase/installing-chef-on-a-pi-with-raspbian-os-so-it-can-be-managed-as-a-node-6f0ccfdac32f)
* [Building a Chef Omnibus package for Raspbian / Raspberry Pi](https://www.saltwaterc.eu/building-a-chef-omnibus-package-for-raspbian-raspberry-pi.html)
* [chef-14-on-arm](https://mattray.github.io/2019/03/08/chef-14-on-arm.html)