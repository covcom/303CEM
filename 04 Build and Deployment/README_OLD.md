
# Automating Server Builds

By now you will have learned the concepts, tools and techniques needed to build servers. This was achieved by completing a sequence of steps which needed to be done in a particular order. You may also have discovered that we as humans are slow at completing the tasks and often make mistakes.

You have only bee working on one server at a time but in real life you might need to configure 10 or even 100 servers!

In this worksheet you will learn how to use a range of tools that can automate this process and even carry it out in parallel!

There are several important terms that need to be carried out when building servers:

1. Provisioning
2. Deployment
3. Orchestration
4. Configuration Management

# Provisioning

In this exercise you will use a number of tools to automatically provision servers. You will be covering:

1. xxx
2. xxx

# Deployment

In this exercise you will be using a number of tools to deploy code to a provisioned server. You will be covering:

1. RSync
2. Vagrant

## 1 Vagrant



Search for Vagrant boxes at https://atlas.hashicorp.com/boxes/search enter a search term. Ubuntu 16 is called xenial

```
vagrant init ubuntu/trusty64
vagrant up
```

Vagrant includes a SSH client that can be used to connect to the VM.
```
vagrant ssh
```

Sometimes (for example when we want to automate our deployment using Ansible) we need to be able to connect using a standard SSH client. To do this we need to find the SSH connection details. This will print out a lot of information, only the relevent lines are reproduced below:
```
vagrant ssh-config
  HostName 127.0.0.1
  User vagrant
  Port 2222
  IdentityFile "/path/to/private_key"
```
We can now use this information to connect using an SSH client.
```
ssh vagrant@127.0.0.1 -p 2222 -i "/path/to/private_key"
```

Synced folders

```
config.vm.synced_folder "./src", "/home/vagrant/src", create: true
```



### 1.1 Provisioning

Instead of manually installing software, Vagrant has support for **provisioning** which enables it to automatically install the correct software when the server is created. In this example we will be creating a simple Apache web server. Open the `ftp/` directory and study the directory structure and files.
```
.
├── Vagrantfile
├── bootstrap.sh
└── src
    └── html
        └── index.html
```



```
# USEFUL BASH COMMANDS

service --status-all
service apache2 status
hostname -I (gets the IP address)

# USEFUL VAGRANT COMMANDS

# power up the server and run the Vagrantfile script.
vagrant up 

# check status of vagrant box
vagrant status
vagrant ssh-config

# SSH into the server using vagrant
vagrant ssh

# find the SSH connection details
vagrant ssh-config

# SSH into the server using terminal
ssh vagrant@127.0.0.1 -p 2222 -i ".vagrant/machines/default/virtualbox/private_key"

# stop the vagrant box
vagrant halt

# terminate virtual machine
vagrant destroy

# if the guest machine is already running, the provision step can be run without needing to rebuild.
vagrant reload --provision

# upgrade to latest version of Ubuntu server
do-release-upgrade
```