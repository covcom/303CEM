
# Software Deployment

In this lab you will learn a variety of techniques that can be used to deploy software to live servers. This is an important skill and if correctly configured will allow your development team to deploy software updates with a minimum of fuss. In these examples you will be deploying a simple API that implements a to do list.

You already have a working virtual network which you created in the second lab. If this is no longer available or no longer working you can [download](http://computing.coventry.ac.uk/~mtyers/Servers.zip) a fresh version and use it in this tutorial, you should log in as `root` with a password of `raspberry`. To simulate deploying software from within the _internal network_ you will also need to download a virtualised desktop Linux operating system and run this as a VM inside the internal network. You can download a configured version of Peppermint Linux.

Boot up your Gateway server and make sure both the gateway tools and the dhcp server are running.
```
sh startGateway
dhcp -4 -f -d -cf ./dhcpd.conf --no-pid eth0
```
In this lab you will be running debian servers, these use the same package manager as Ubuntu but the server takes up a much smaller footprint. You can download the base VirtualBox Ubuntu image from: xxxxxx.

You will also need a virtualised linux desktop OS which will be used as the development machine. You can download a VirtualBox image for a basic Debian Desktop OS from xxxxxx.

## Mounting File Systems

The first exercise you will do is to mount the filesystem from one server on a different server. This works in a similar way to your network storage drive on the University computers.

Start by creating a _linked clone_ of the **Debian Server** and call it **File Server**. Make sure you reinitialise the MAC address. Make sure it is on the Internal Network and boot it up. It should pick up an IP address from the gateway and be able to ping `bbc.co.uk`. Make a not of its IP address.

Change the hostname of the server, it is current set to `debian`. You will need to edit two config files, replacing instances of `debian` with `fileserver` then you will need to reboot the server.
```
nano /etc/hostname
nano /etc/hosts
reboot
```
Now you will need to log in and install  `nfs`. Then create a directory you want to share and register it. Finally we create a simple readme file.
```
apt-get update
apt-get upgrade
apt-get install nfs-kernel-server nfs-common -y
mkdir /home/backup
chown nobody:nogroup /home/backup
chmod 755 /home/backup
echo "# Hello World" >> /home/backup/readme.md

nano /etc/exports
```
We need to edit this file to tell the `nfs` tool which directories to share.
```
/home/backup
```
Then restart the `nfs` server.
```
service --status-all | grep nfs
service nfs-kernel-server restart
```

### Connecting to a Mount

Now we will connect to this mount from our Ubuntu Desktop. Check it's network interface points to the internal network then boot up, the username is `newuser` with the password of `raspberry`. Launch the Terminal tool, check it picks up an IP address and that it can ping `bbc.co.uk`.

Switch to the `root` account using `su root`, the password is `raspberry`. As root you can search for all the mount points on a specified server. The example assumes the `fileserver` IP address is `10.5.5.9`.
```
showmount -e 10.5.5.9
  Export list for 10.5.5.9:
    /home/backup *
```
The share we created is listed. Now we can mount this.
```
mkdir /mnt/backup
mount 10.5.5.9:/home/backup /mnt/backup
cd /mnt/backup
ls
  readme.md
echo "\nAdded note to the file." >> readme.md
  bash: readme.md: Read-only file system
```
It is possible to see what processes are currently accessing a mount (useful if you need to unmount it).
```
fuser -vm /mnt/backup
umount /mnt/backup
```

It looks like the client only has read-access to the remote directory. To fix this you will need to modify the configuration `/etc/exports` file on the **fileserver**.
```
/home/backup     10.5.5.10(rw,sync)
```
Then restart the service.
```
service nfs-kernel-server restart
```
On the client you need to mount the share again.
```
mount 10.5.5.9:/home/backup /mnt/backup
cd /mnt/backup
```

Boot up your Client machine and check it gets an IP address and can ping the Gateway, the DNS server (`8.8.8.8`) and the `bbc.co.uk` server.

Boot up the Developer computer, this should be connecting to your internal network and therefore should pick up an IP address from the DHCP server running on your gateway. Open the Terminal and use ping to chck you are configured.

Download Visual Studio Code and install.
```
wget https://goo.gl/jGjALA
ls
mv jGjALA vscode.deb
sudo dpkg -i vscode.deb
rm vscode.deb
```
This will install Visual Studio Code. You can launch it by clicking on the menu and searching for _Visual Studio Code_.

## Configuring Git

In these exercises it is assumed that the development team is managing their codebase using the Git version control system so the first task is to configure the development machine. Install `git` tools. Once these are installed you need to clone the repository that contains the API.
```
sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/covcom/todo.git
ls
```
This will clone the API code into a new directory called `todo`. Open the todo directory in Visual Studio Code (File > Open, then select the Developer Home directory.) Take a moment to look at the files you have cloned. In the next sections you will learn how to deploy this code using three different techniques:

1. Secure file transfer protocol (SFTP).
2. RSync
3. Git push.

## SFTP

Create a linked clone of the master Alpine server. Make sure you reset the MAC address and call the server SFTP Server. This should be on the internal network. Check the connectivity as before.


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