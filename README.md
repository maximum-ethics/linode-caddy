# Linode-Caddy repository

## Introductory explanation

This repository contains the [Ansible](https://www.ansible.com/) code that we use to create our web servers that we use at Maximum Ethics to host websites (static and dynamic). Essentially this contains a package of code for Ansible that is capable of configuring a fresh installation of Arch Linux into a functioning web server that can host our websites.  It also acts as documentation for how our web servers are configured should we ever need to recreate them or move to a different hosting option. This is currently written for the specific websites Maximum Ethics is hosting, and will have to be generalized later.

This might be useful to you if:

- You want to host one or more websites in an ethical and sustainable manner
- You are currently hosting a website with us as a client and want to host it yourself
- You are employed with us and wish to go your own way and/or need to host some of your clients' sites
- You have knowledge or expertise in ethical web hosting and you'd like to contribute to our goal

## Why this matters?

There are plenty of businesses that put profit first, Maximum Ethics is a place for employees and customers who prioritize their values.

- Transparency + Accountability - We use open source software and we want it to be very clear what we are using and how.
- Avoiding lock-in - We want it to be easy for customers or workers to take their business elsewhere. Providing the code that sets up our web server makes it easy to create your own copy of websites hosted on our infrastructure.
- We want to contribute our code back to the community, to help others as we were helped.

## Resulting Webserver's capabilities

- create virtual server on [Linode](https://www.linode.com/) web hosting
- install [Arch Linux](https://archlinux.org/) or [Ubuntu Linux](https://ubuntu.com/) (easy to switch back and forth)
- set up users
- configure [Uncomplicated Firewall](https://en.wikipedia.org/wiki/Uncomplicated_Firewall)
- use [Caddy web server](https://caddyserver.com/) to publish web pages
- host hand-coded [PHP](https://en.wikipedia.org/wiki/PHP) websites
- use [Hugo static site generator](https://gohugo.io/) to create web content

## Options/Configurations

Creating a Linode

- [Options for configuring the linode server](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_create/vars/main.yml) that will be created to host the websites.  Many of these are configured in the comments on or above the line with the variable.
    - hosts_group - configures what host group the newly created linode will be entered under in your /etc/hosts file
    - linode_label - the name of the linode server created
- [Default web server password](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_harden/vars/main.yml) that will be used for all users until they log in for the first time and are forced to change their passwords
- [Web server user configurations](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_initiate-users/vars/main.yml)
    - Users are specified with a username, the default password, their preferred shell, and their sshkey.
    - users var can contain multiple users, though the user who is creating the linode with this script **MUST** be the last user in the list.
    - Multiple sshkeys can be specified if desired
    - Only the user creating the Linode needs to be specified, but until server setup is completed, only users in this vars file will be created and thus able to log on.

Server Setup

- [Server setup variables](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/main.yml) that are always used, but can be overridden by the other vars files.
    - Variables that are always used, but can be overridden by the other vars files.
- [https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/local_tls.yml](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/local_tls.yml)
    - When you set local_tls, this switches you to use the local Caddyfile configuration so Caddy creates its own local certificates rather than bothering Let's Encrypt.
    - Currently local_tls is set to true in Ubuntu and false in Arch, because our production server is running Arch and we are testing things in Ubuntu. You could set this in the main vars file instead.
- [vars used when the host is detected as Ubuntu](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/Ubuntu.yml)
- [Arch Linux specific](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/Archlinux.yml) variables
    - runs when the host is detected as Arch Linux

## Technical procedures of use

### Install Ansible and other useful software

to install on fresh Arch:

- ansible
- fish
- micro
    - xclip
- exa
    - alias l "exa"
    - funcsave l
    - alias lt "exa --tree"
    - alias lg "exa -halgG --git"
- bat

### Create Personal Access Token on Linode

### Create SSH pub key

use ED25519

### Create localhost vars file

at e.g. /etc/ansible/host_vars/localhost/vars.yml (or 
/usr/local/etc/ansible/hosts if you use homebrew on Mac to install 
Ansible)

```
inventory_directory: [e.g. /etc/ansible]
ansible_connection: local
maximum_ethics_linode_token: [insert yours]
ssh_pub_key: [insert yours]

```

### Clone this git repo

[https://github.com/maximum-ethics/linode-caddy](https://github.com/maximum-ethics/linode-caddy)

### Update variables

modify roles/new-linode_create/vars/main.yml if you are changing the linode label or whatever

add your ssh key to roles/new-linode_initiate-users/vars/main.yml

### Create the Linode server from your computer by connecting to the Linode web API

`ansible-playbook new-linode.yml --ask-become-pass`

### Change your password from our default, so you can log in as yourself (not root)

e.g. `ssh america`

Change your password when prompted, and then you will be automatically logged out. Then you can log in again.

### Set up the server

`ansible-playbook sunrise.yml`

This includes setting up the [Caddy v2 web server](https://caddyserver.com/), serving some hand-coded PHP websites and Hugo-generated websites.

**WAIT!** If you are changing the IP address for an existing domain name, consider the TTL! [Linode's default TTL is 24 hours](https://www.linode.com/docs/platform/manager/dns-manager/#troubleshoot-dns-records). Many of our Godaddy subdomains currently have the TTL set to 1 hour.

If you power up your new Caddy webserver before DNS resolves correctly, it won't be able to get certificates from Let's Encrypt, and won't serve your websites. Worse, you may annoy Let's Encrypt by exceeding their rate limits (requesting certs you can't get) and then you'll have to wait even longer! 

Rather than testing changes publicly on the open web, set up a dev environment so that you can test this playbook without requesting certs from Let's Encrypt. If you use the local_tls option, Caddy will create its own local certificates on the server, and you can manually install the certs on your personal computer and point your /etc/hosts file at the correct IP address to preview what the site will look like.

Make sure all domains resolve to the correct IP addresses before using the public production Caddy config.

### Push your code changes

Go to GitHub and sign in
Profile->Settings->Developer Settings->Personal access tokens->Generate new token `git config --global credential.helper store` that will save your credentials next time you run a command. Then use the token in place of your password when you:`git push`

## License

This project is licensed under the [GNU Affero General Public License](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License) version 3 or any later version at your choice. See the [LICENSE](LICENSE) file for details.

