# Linode-Caddy repository

## Introductory explanation

This repository contains the [Ansible](https://www.ansible.com/) code that Maximum Ethics uses to create our web servers. This code creates a Linode virtual server running Arch Linux, and installs all of the software and content necessary to serve the websites we host. It also acts as documentation for how our web servers are configured, should we ever need to recreate them or move to a different hosting option. This is currently written for the specific websites we host, and will have to be generalized later.

This might be useful to you if:

- You want to host one or more websites in an ethical and sustainable manner, on your own servers. Perhaps you can study our approach to inform your own.
- You want us to host your websites, and you're a techie who wants to help set up your desired configuration.
- You are currently hosting a website with us as a client, and
	- have noticed something you want to change about your hosting.
	- instead want to host it yourself.
- You are employed with us, and
	- wish to go your own way.
	- want to host websites elsewhere using our familiar tech stack.
- You have knowledge or expertise in ethical web hosting and you'd like to contribute to our goals, with no direct benefit to yourself.

## Why does this matter?

There are plenty of businesses that put profit first. Maximum Ethics is a place for employees and customers who prioritize their values.

- **Transparency + Accountability** - We use open source software. We want it to be clear what we are using, and how.
- **Avoiding lock-in** - People should host their websites with us because it's a pleasant experience, not because they are trapped. We want it to be easy for customers or workers to take their business elsewhere. Providing the code that sets up our web server makes it easy to create your own copy of websites hosted on our infrastructure.
- **Sharing knowledge** - We want to contribute our code back to the community, to help others as we were helped.

## Resulting Webserver's capabilities

- create virtual server on [Linode](https://www.linode.com/) web hosting
- install [Arch Linux](https://archlinux.org/), [Ubuntu Linux](https://ubuntu.com/), or (eventually) [Alpine Linux](https://www.alpinelinux.org/) (should be easy to change distros)
- set up users
- configure [Uncomplicated Firewall](https://en.wikipedia.org/wiki/Uncomplicated_Firewall)
- use [Caddy web server](https://caddyserver.com/) to publish web pages
- host hand-coded [PHP](https://en.wikipedia.org/wiki/PHP) websites
- use [Hugo static site generator](https://gohugo.io/) to create web content

## Options/Configurations

Creating a linode

- [Options for configuring the Linode server](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_create/vars/main.yml) that will be created to host the websites.  Many of these are configured in the comments on or above the line with the variable.
    - hosts_group - configures what host group the newly created linode will be entered under in your Ansible hosts file
    - linode_label - the name of the Linode server created
- [Default web server password](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_harden/vars/main.yml) that will be used for all users until they log in for the first time and are forced to change their passwords
- [Web server user configurations](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/new-linode_initiate-users/vars/main.yml)
    - Users are specified with a username, the default password, their preferred shell, and their sshkey.
    - users var can contain multiple users, though the user who is creating the linode with this script **MUST** be the last user in the list.
    - Multiple sshkeys can be specified if desired
    - Only the user creating the linode needs to be specified, but until server setup is completed, only users in this vars file will be created and thus able to log on.

Server Setup

- [Server setup variables](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/main.yml) that are always used, but can be overridden by the other vars files.
    - Variables that are always used, but can be overridden by the other vars files.
- [https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/local_tls.yml](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/local_tls.yml)
    - When you set local_tls, this switches you to use the local Caddyfile configuration so Caddy creates its own local certificates rather than bothering Let's Encrypt. This means that in order to view a website hosted on that server, you must accept our local HTTPS cert. Clearly this is only for testing purposes, not for production websites.
    - Currently all servers default to local_tls, to avoid accidentally making things public. The only public server is america, and if you use [our inventory](https://github.com/maximum-ethics/linode-caddy/tree/master/inventory), it will set local_tls to false. If you're working on america and accidentally set local_tls to true or fail to specify, you'll take our production server offline, so don't do that.
- [vars used when the host is detected as Ubuntu](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/Ubuntu.yml)
- [Arch Linux specific](https://github.com/maximum-ethics/linode-caddy/blob/master/roles/sunrise/vars/Archlinux.yml) variables
    - runs when the host is detected as Arch Linux

## Technical procedures of use
Dependencies:
- ansible
- git

### Clone this git repo
First, [install git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

Then clone [this repo](https://github.com/maximum-ethics/linode-caddy) to your local machine:

`git clone https://github.com/maximum-ethics/linode-caddy.git`

If you have push privileges on this repo, we recommend instead using SSH. First, you'll have to add an SSH key (that exists on your local machine) to GitHub. https://docs.github.com/en/authentication/connecting-to-github-with-ssh 

Then:

`git clone git@github.com:maximum-ethics/linode-caddy.git`

### Install Ansible and other useful software

First, [install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). On macOS we recommend first installing the [Homebrew package manager](https://brew.sh/), and then using that to install Ansible.

We are working on a set of installation scripts to bootstrap your local system using [chezmoi](https://www.chezmoi.io/), which would install Ansible as well, but they are not yet ready for public consumption.

Once you've installed Ansible, you may be able to install our server software onto your local machine by running commands like this from the git repo:

`ansible-playbook local-machine.yml --tags local --ask-become-pass`

`ansible-playbook fish-local.yml --ask-become-pass`

Or you might not, those are experimental works in progress.

### Create Personal Access Token on Linode
https://www.linode.com/docs/products/tools/linode-api/guides/get-access-token/

### Create SSH pub key

We recommend using ED25519 SSH keys. Mozilla has some [guidance for key generation](https://infosec.mozilla.org/guidelines/openssh#key-generation).

### Create localhost vars file

at e.g. /etc/ansible/host_vars/localhost/vars.yml (or /usr/local/etc/ansible/hosts if you use homebrew on Mac to install Ansible)

```
inventory_directory: [e.g. /etc/ansible]
ansible_connection: local
maximum_ethics_linode_token: [insert yours]
ssh_pub_key: [insert yours]
```

### Update variables

modify roles/new-linode_create/vars/main.yml if you are changing the linode label or whatever

add your ssh key to `roles/new-linode_initiate-users/vars/main.yml` and `roles/sunrise/vars/main.yml`

### Create the Linode server from your computer by connecting to the Linode web API

`ansible-playbook new-linode.yml --ask-become-pass`

### Change your password from our default, so you can log in as yourself (not root)

e.g. `ssh america`

Change your password when prompted, and then you will be automatically logged out. Then you can log in again.

### Set up the server

If you are working on our existing servers, and not creating a new Linode, you may be able to use the inventory file included in the repo, like so:

`ansible-playbook sunrise.yml --ask-become-pass -i inventory`

If you're working on your own servers, you'll need your own local inventory file.

This includes setting up the [Caddy v2 web server](https://caddyserver.com/), serving some hand-coded PHP websites and Hugo-generated websites.

**WAIT!** If you are changing the IP address for an existing domain name, consider the TTL! [Linode's default TTL is 24 hours](https://www.linode.com/docs/platform/manager/dns-manager/#troubleshoot-dns-records).

If you power up your new Caddy webserver before DNS resolves correctly, it won't be able to get certificates from Let's Encrypt, and won't serve your websites. Worse, you may annoy Let's Encrypt by exceeding their rate limits (requesting certs you can't get) and then you'll have to wait even longer!

Rather than testing changes publicly on the open web, set up a dev environment so that you can test this playbook without requesting certs from Let's Encrypt. If you use the local_tls option, Caddy will create its own local certificates on the server, and you can manually install the certs on your personal computer and point your /etc/hosts file at the correct IP address to preview what the site will look like.

Make sure all domains resolve to the correct IP addresses before using the public production Caddy config.

### Push your code changes
If you cloned with SSH as we recommend, a simple `git push` should work.

If you used HTTPS to clone the repo (not recommended), Go to GitHub and sign in
Profile->Settings->Developer Settings->Personal access tokens->Generate new token `git config --global credential.helper store` that will save your credentials next time you run a command. Then use the token in place of your password when you: `git push`

## License

This project is licensed under the [GNU Affero General Public License](https://en.wikipedia.org/wiki/GNU_Affero_General_Public_License) version 3 or any later version at your choice. See the [LICENSE](LICENSE) file for details.
