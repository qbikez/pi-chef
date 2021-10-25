# This is a Chef Infra Client attributes file. It can be used to specify default
# and override attributes to be applied to nodes that run this cookbook.

default['vsts_agent']['PAT'] = ''
default['vsts_agent']['name'] = 'pi-agent-01'
default['vsts_agent']['pool'] = 'pi'
default['vsts_agent']['url'] = 'https://dev.azure.com/_your_org_name_here'
default['vsts_agent']['binary']['url'] = 'https://vstsagentpackage.azureedge.net/agent/%s/vsts-agent-linux-arm-%s.tar.gz'

# go to https://login.tailscale.com/admin/settings/authkeys and create an auth key
default['tailscale']['authkey'] = ''

default['home_assistant']['directory'] = '/home/pi/docker/homeassistant'
default['home_assistant']['repo'] = 'https://github.com/qbikez/home_assistant_stub.git'