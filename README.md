# Pi Chef

Managing Raspbery Pi(s) with chef. [About the project](About.md).

## Prerequisites

1. A raspberry Pi with raspbian (or similar) OS installed. Connected to a network, with SSH access.

## Getting started

Disclaimer: I assume you're using Azure DevOps to host your repository and run pipelines. I haven't tested the flow with other providers (i.e. Github), but I assume the steps would be similar.

1. On raspberry Pi:
    * [install chef-client and friends](InstallChef.md)
    * fork this repository and clone the fork
2. create node attributes file (i.e. at `/boot/chef/node.json`):

    ```json
    {
        "vsts_agent": {
            "PAT": "get PAT from azure portal",
            "pool": "pi"
        },
        "git": {
            "dev.azure.com/myusername": {
                "username": "myusername",
                "password": "use PAT"
            }
        },
        "tailscale": {
            "authkey": "generate auth key for tailscale"
        },
        "openvpn": [
            "myprofile.ovpn"
        ]
    }
    ```

    [Obtain a Personal Access Token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) from Azure DevOps and set it in `node.json` file (`['vsts_agent']['PAT']`).

5. Go to Azure DevOps portal and [create agent pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&tabs=yaml%2Cbrowser#creating-agent-pools). The cookbook expects pool named `pi` by default. If you decide to name it differently, put the name in attributes: `['vsts_agent']['pool']`.
4. Run `vsts_agent` recipe to instal Azure DevOps agent.

    ```shell
    rbenv sudo chef-client -z -j /boot/chef/node.json --runlist vsts_agent
    ```

    You should see a new agent coming up in the pool.
    From now on, you will be using Azure DevOps pipelines to run chef on your Raspberry.

5. Create a new pipeline in Azure DevOps. Point it to `.azurepipelines/chef.yaml`. If you used a name other than `pi` for the agent pool, configure the pipeline to use that pool.

    By default the pipeline will run `default.eb` recipe, but you can control it via `recipe` parameter. It's also configured to trigger automatically after chage to any recipe in `pi_home` cookbook.

6. Run the new pipeline and set `recipe` parameter to: `recipe[pi_home::hello_pi]`. This is a simple test pipeline to verify everything is working correctly. Hopefully it will :)

    The pipeline uses chef in local mode (`--zero`). You can configure the full-blown chef server if you wish.

## Services

Now that you have a pipeline that runs on the raspberry, it's time to configure some services! All the below are pick-and-choose as you wish. You can of course extend them or create your own recipes.

### Networking

#### `pi_home::net_openvpn`

Installs openvpn service and configures it to autostart all profiles. Put the profile files in `/boot/chef/openvpn` and add names to `node['openvpn']` array attribute.

#### `pi_home::net_tailscale`

Installs and configures [tailscale](https://tailscale.com/). Obtain [auth key](https://login.tailscale.com/admin/settings/authkeys) and put it onto `node['tailscale']['authkey']`.

### Services

#### `pi_home::svc_home_assistant`

Installs a [home assistant](https://www.home-assistant.io/) instance, running in a docker image. 
It needs a git repository with home assistant file structure - configured in `node['home_assistant']['repo']`. 
By default will use https://github.com/qbikez/home_assistant_stub.git, but it's best to fork this repo so you make adjustments. 
The checked out files will be located in `/home/pi/docker/homeassistant`. The recipe will attempt to sync any changes made in that repository back to git origin. If you configure the pipeline to run this recipe periodically, you will effectively have your HA config backed up. 

Note: The default settings exclude home assistant's .db files from the backup. Other config files (`*.yaml`, `.storage`, `custom_components`, etc.) should be enough to recreate HA instance. If you want to include database as well, modify `.gitignore` file and add `*.db` to git.

# InSpec


# Troubleshooting

- Pipeline checkout step fails due to file permission issues. 

    The git repository is checked out by the DevOps agent, which runs as `pi` user, whereas the `chef-client` binary runs as `root`. If `chef-client` create some files in the cookbook repo, checkout will try to delete them, but will fail due to permission issues. This will probably be a node file inside `nodes` directory. 
    Just add it to the repo, cleanup agent workspace (`sudo rm -rf /home/pi/vsts_agent/_work`) and run the pipeline again.