README

# Ansible management of Oxy Delegates
Use this if you want to build and manage a set of delegates using [Ansible](https://www.ansible.com/).
In my case I have a master node for the mainnet, a backup node for the mainnet master and a testnet node.

**Disclaimer: use at your own risk !**

## What will it do?
* Install necessary packages on your node
* Install oxy on your node
* Create and setup a swap file
* Create and install a self-signed certificate (for https use)
* Add a config file per node (with the secret passphrases)
* Setup a firewall
* Run the Oxy service

# Preparation
You will need to:
* Put your ssh keys on your nodes
* Update and upgrade all nodes
* Add a user (non-root) on every host and set a password for it. Also add the user to the sudoers.
* Create key and certificate files for the self-signed certificate, in `roles/node_setup/files` (you need a *.key, *.csr, *.crt file), instructions are found [here](https://serversforhackers.com/c/self-signed-ssl-certificates). Note: The files must all have the same name, but different extensions, the name must match the _keyfile_ variable in the inventory file.

Additionally you need to create a few files, that are personalized to your setup.
Namely:
* An inventory file
* The config files for your nodes (with the passphrases)
* Adapt the ansible.cfg file with your details

### Inventory file
Create an inventory file following [Ansible inventory conventions](http://docs.ansible.com/ansible/latest/intro_inventory.html) with your hosts in it in the root of your directory.
It should look something like this
```yaml
[testnet:children]
krypton-test

[testnet:vars]
git_repo='https://github.com/Oxycoin/oxy-node.git'
git_branch=testnet
oxy_base_dir=/opt/oxy-node
http_port=9998
https_port=9999
ssh_port=22
keyfile=<someName>

[mainnet:children]
krypton-main
krypton-main-bkp

[mainnet:vars]
git_repo='https://github.com/Oxycoin/oxy-node.git'
git_branch=master
oxy_base_dir=/opt/oxy-node
http_port=10000
https_port=10001
ssh_port=22
keyfile=<someName>

[krypton-main]
krypton-main ansible_host=123.123.123.123 ansible_ssh_user=<yourUser>
[krypton-main:vars]
server_name=krypton

[krypton-test]
krypton-test ansible_host=123.123.123.123 ansible_ssh_user=<yourUser>
[krypton-test:vars]
server_name=krypton-test
```

### Ansible config file
Adapt your ansible.cfg file with ssh key, inventory file and roles path (http://docs.ansible.com/ansible/latest/intro_configuration.html). Put it in the root of your directory.

### Oxy config files
You will need one config file per node (nodes in your inventory). Put them under `roles/node_stup/files`
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

**Note:** the "install oxy_manager" step takes a long time, if you want to keep an eye on it you can connect to your server and observe the logfile with:
`tail -f /opt/oxy-node/logs/oxy_manager.log`

# Additional hardening of your node
I suggest to add a few steps, that are not scripted here.
* Disable sudo login
* Disable login with password and instead only allow a keyfile login
* Possibly change your SSH port (adapt the firewall rules in the Ansible script in that case)
