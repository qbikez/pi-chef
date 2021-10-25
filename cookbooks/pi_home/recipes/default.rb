# run all recipes. The order matters
include_recipe '::system'
include_recipe '::net_openvpn'
include_recipe '::net_tailscale'
include_recipe '::docker'
include_recipe '::svc_home_assistant'
include_recipe '::services'
