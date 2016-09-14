
Expected Skills

1. SSH keys.
2. Environment variables

# Clustering

## Beowulf Cluster

Get students to pool their servers and build a 4-6 node cluster (based on lab desk). Need to provide switches and network cables.

https://www.linux.com/community/blogs/133-general-linux/9401


Expected Skills

1. SSH keys.
2. Environment variables

# Clustering

## Beowulf Cluster

Get students to pool their servers and build a 4-6 node cluster (based on lab desk). Need to provide switches and network cables.

Load testing with ApacheBench

https://www.linux.com/community/blogs/133-general-linux/9401

# Load Balancing

## NGINX Load Balancer

Students create a simple load-balanced system with a single node. Then add additional nodes. Run a script that also returns the name of the server that handled the request. Use ApacheBench to run tests?


## Ansible

Push-based solution. Ships with modules to automate most typical tasks. Uses the normal system modules (apt on Ubuntu/Debian). Modules are the primary unit of reuse.

Demonstration, get students to install base system and share public keys. Push a build out to every server in the lab...

Ansible scripts are yaml files and are called playbooks.

Servers must have SSH and Python (3.4?) installed. The control machine needs Python installed.

Only need to install Ansible on the _control machine_.

### Installing Ansible

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-ubuntu-14-04

Install package to simplify working with PPAs. Then we can add the Ansible PPA.
```
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

### Exchange SSH keys.

Create a user account on each server and generate SSH keys. Use the `ssh-copy-id` command to copy keys.
```
ssh-copy-id -i ~/.ssh/id_rsa.pub cloud9@cloud9
```

### Configuring Ansible Hosts

Open the `/etc/ansible/hosts` file with root privileges.
```
[live_servers]
host1 ansible_ssh_host=192.0.2.1
host2 ansible_ssh_host=192.0.2.2
host3 ansible_ssh_host=192.0.2.3
```

## Grunt
