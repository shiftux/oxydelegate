README

# Ansible management of Oxy Delegates
Use this if you want to build and manage a set of delegates using [Ansible](https://www.ansible.com/).
In my case I have a master node for the mainnet, a backup node for the mainnet master and a testnet node.

**Disclaimer: use at your own risk !**

## What will it do?
* Enable all users to become root without password (command sudo without password, this is necessary for oxy-snapshot to work)
* Install necessary packages on your node (from yum and pip)
* Install oxy on your nodes
* Install oxy-checker on your nodes
* Install oxy-snapshot on your nodes
* Create and setup a swap file
* Create and install a self-signed certificate (for https use)
* Add a config file per node (with the secret passphrases)
* Setup a firewall
* Run the Oxy service
* With oxy-checker enabled and installed on 2 servers you will have a HA (highly available) setup

# Preparation
You will need to:
* Put your ssh keys on your nodes
* Update and upgrade all nodes
* Add a user (non-root) on every host and set a password for it. Also add the user to the sudoers.
* Create key and certificate files for the self-signed certificate, in `roles/node_setup/files` (you need a * .key, *.csr, *.crt file), instructions are found [here](https://serversforhackers.com/c/self-signed-ssl-certificates). Note: The files must all have the same name, but different extensions, the name must match the _keyfile_ variable in the inventory file.

Additionally you need to create a few files, that are personalized to your setup.
Namely:
* An inventory file
* The config files for your nodes (with the passphrases) they go in roles/node_setup/files
* The config files for the oxy-checker (see https://github.com/Oxycoin/oxy-checker), they go in roles/node_setup/files/
* Adapt the ansible.cfg file with your details

### Inventory file
Create an inventory file following [Ansible inventory conventions](http://docs.ansible.com/ansible/latest/intro_inventory.html) with your hosts in it in the root of your directory.
It should look something like this
```yaml
[testnet:children]
shiftux-test

[testnet:vars]
git_repo='https://github.com/Oxycoin/oxy-node.git'
git_branch=testnet
oxy_base_dir=/opt/oxy-node
http_port=9998
https_port=9999
ssh_port=22
keyfile=<someName>

[mainnet:children]
shiftux-main
shiftux-main-bkp

[mainnet:vars]
git_repo='https://github.com/Oxycoin/oxy-node.git'
snapshot_git_repo='https://github.com/Oxycoin/oxy-snapshot'
checker_git_repo='https://github.com/Oxycoin/oxy-checker.git'
git_branch=master
oxy_base_dir=/opt/oxy-node
snapshot_base_dir=/opt/oxy-snapshot
checker_base_dir=/opt/oxy-checker
http_port=10000
https_port=10001
checker_port=7778
ssh_port=22
keyfile=<someName>

[shiftux-main]
shiftux-main ansible_host=123.123.123.123 ansible_ssh_user=<yourUser>
[shiftux-main:vars]
server_name=shiftux

[shiftux-test]
shiftux-test ansible_host=123.123.123.123 ansible_ssh_user=<yourUser>
[shiftux-test:vars]
server_name=shiftux-test
```

### Ansible config file
Adapt your ansible.cfg file with ssh key, inventory file and roles path (http://docs.ansible.com/ansible/latest/intro_configuration.html). Put it in the root of your directory.

### Oxy config files
You will need one config file per node (nodes in your inventory). Put them under `roles/node_stup/files/<server_name>_config.json`
Take the default config file that comes with Oxy and change the following in it:
* Under forging - secret: insert your secret passphrase (in quotes)
* In both sections called whiteList: Add your public IP (the one you use on your laptop to connect to your nodes, not the one from your node):
* Adapt the ssl section as follows:
```yaml
    "ssl": {
        "enabled": true,
        "options": {
            "port": 9999, # for the testnet or 10001 on the mainnet
            "address": "0.0.0.0",
            "key": "./ssl/<nameOfYourNode>.key", # same name as the server_name variable in the inventory file
            "cert": "./ssl/<nameOfYourNode>.crt" # same name as the server_name variable in the inventory file
        }
    },
```

### Oxy-checker config files, see https://github.com/Oxycoin/oxy-checker on how to set them up. The php files go in `roles/node_stup/files/<server_name>_config.php`

**Note:** the "install oxy_manager" step takes a long time, if you want to keep an eye on it you can connect to your server and observe the logfile with:
`tail -f /opt/oxy-node/logs/oxy_manager.log`

# Additional hardening of your node
I suggest to add a few steps, that are not scripted here.
* Disable sudo login
* Disable login with password and instead only allow a keyfile login
* Possibly change your SSH port (adapt the firewall rules in the Ansible script in that case)
