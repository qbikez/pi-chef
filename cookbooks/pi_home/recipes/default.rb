# run all recipes.
include_recipe ::net_openvpn
include_recipe ::net_tailscale
include_recipe ::gitconfig
include_recipe ::vsts_agent
include_recipe ::svc_home_assistant
include_recipe ::svc_other
