## Inspiration

Raspberry Pi is a wonderful piece of technology, used for a variety of projects. One of which is smart home management and automation. I personally love to tinker with it, trying out new stuff and constantly changing things. 
This means an ocassional need for a fresh OS install will arise. My process there was totally manual, including a bunch of documents with all the steps needed to setup things like networking, display, favourite tools, etc.

## What it does

This project aims to ease the pain of a Raspberry Pi setup and automate as much of the installation process as possible - by leveraging Chef Infra. It provides a repeatable way to start over, so you can experiment without the fear of losing existing work.

## How we built it

1. Build chef-client for Raspberry Pi
2. Prepare a cookbook with recipes for initial OS setup and essential tooling.
3. Install azure DevOps agent on raspberry Pi - enabling running pipelines directly in the Pi, thus eliminating the need for direct connection.
4. Prepare a cookbook for Home Assistant setup. Use a git repository for storing HA config files and automatically sync any changes.

## Challenges we ran into

Compiling and running chef on raspberry Pi was quite a challenge. 
There are people who already did it and by compiling their experience from a few blog posts, I was able to successfuly run chef-client on raspberry.

## Accomplishments that we're proud of

* Installing azure DevOps agent on the raspberry Pi means that I can use the same process as I usually do for my day to day job: Make a change, commit & push and the pipeline takes care of the rest.
No need to ssh into the host, using tmux to make sure I don't loose the session, etc. I'm also notified about the result once the pipeline is finished, so I can focus on other things, while it's doing its stuff.

* running InSpec on raspberry - I haven't seen anybody doing that and it seems like a natural extension of running Chef Infra. I can specify my expectations as to what ports are open, what services are running, etc. I can also use pre-existing configuration for OS hardening and bullet proofing. This is important, because whe you're allowing software to control whole your house, you want to make it as secure as possible - a thing that is still frequently ommited by IoT enthusiasts.

## What we learned



## What's next for PiChef

* extract cookbooks that can be published to chef marketplace
* streamline ARM client compilation with omnibus
* add recipes for more services