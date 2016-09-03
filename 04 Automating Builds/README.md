
Assumed knowledge by this stage:

1. the YAML file format
2. connecting using SSH
3. pipes and redirection
4. install packages
5. using sudo
6. file permissions
7. starting and stopping services
8. environment variables
9. shell scripting
10. Jinja2 templating

# Automating Server Builds

By now you will have learned the concepts, tools and techniques needed to build servers. This was achieved by completing a sequence of steps which needed to be done in a particular order. You may also have discovered that we as humans are slow at completing the tasks and often make mistakes.

You have only bee working on one server at a time but in real life you might need to configure 10 or even 100 servers!

In this worksheet you will learn how to use a range of tools that can automate this process and even carry it out in parallel!

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
