Ansible role that automatically sets up a web server running Caddy, using a virtual server on [Linode](https://www.linode.com/). This is currently written for the specific websites Maximum Ethics is hosting, and will have to be generalized later.

## Steps to set up server on Linode
First, ask Nelson for an account on Linode, so that you can create an API token. Then:

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
at e.g. /etc/ansible/host_vars/localhost/vars.yml (or /usr/local/etc/ansible/hosts if you use homebrew on Mac to install Ansible)

```
inventory_directory: [e.g. /etc/ansible]
ansible_connection: local
maximum_ethics_linode_token: [insert yours]
ssh_pub_key: [insert yours]
```

### Clone this git repo
https://github.com/maximum-ethics/linode-caddy

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

This includes setting up the [Caddy v2 web server](https://caddyserver.com/), serving some hand-coded hub websites.

**WAIT!** If you are changing the IP address for an existing domain name, consider the TTL! [Linode's default TTL is 24 hours](https://www.linode.com/docs/platform/manager/dns-manager/#troubleshoot-dns-records). Many of our Godaddy subdomains currently have the TTL set to 1 hour.

If you power up your new Caddy webserver before DNS resolves correctly, it won't be able to get certificates from Let's Encrypt, and won't serve your websites. Worse, you may annoy Let's Encrypt by exceeding their rate limits (requesting certs you can't get) and then you'll have to wait even longer! (In the future we'll set up a dev environment so that you can test this playbook without requesting certs from Let's Encrypt.)

Make sure the domain resolves to the correct IP address before setting up Caddy.

To set up the server but avoid setting up Caddy, try:

`ansible-playbook sunrise.yml --skip-tags "caddy_v2,new_handcoded"`

### Push your code changes
Go to GitHub and sign in
Profile->Settings->Developer Settings->Personal access tokens->Generate new token
`git config --global credential.helper store`
that will save your credentials next time you run a command. Then use the token in place of your password when you:
`git push`
