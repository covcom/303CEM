
# Software Deployment

In this lab you will learn a variety of techniques that can be used to deploy software to live servers. This is an important skill and if correctly configured will allow your development team to deploy software updates with a minimum of fuss. In these examples you will be deploying a simple API that implements a to do list.

You already have a working virtual network which you created in the second lab. If this is no longer available or no longer working you can [download](http://computing.coventry.ac.uk/~mtyers/Servers.zip) a fresh version and use it in this tutorial, you should log in as `root` with a password of `raspberry`. To simulate deploying software from within the _internal network_ you will also need to download a virtualised desktop Linux operating system and run this as a VM inside the internal network. You can download a configured version of Peppermint Linux.

Boot up your Gateway server and make sure both the gateway tools and the dhcp server are running.
```
sh startGateway
dhcp -4 -f -d -cf ./dhcpd.conf --no-pid eth0
```
In this lab you will be running debian servers, these use the same package manager as Ubuntu but the server takes up a much smaller footprint. You can download the base VirtualBox Ubuntu image from: http://computing.coventry.ac.uk/~mtyers/Debian_Server.zip.

You will also need a virtualised linux desktop OS which will be used as the development machine. You can download a VirtualBox image for a basic Debian Desktop OS from http://computing.coventry.ac.uk/~mtyers/Debian_Desktop.zip.

You have the opportunity to use these private servers to try out the concepts covered in the lecture:

1. Mounting File Systems
2. File Transfer Protocol (FTP)
3. Secure Shell
4. Rsync
5. Environment Variables
6. Shell Scripts
7. Cron

## Configuring Git

In these exercises it is assumed that the development team is managing their codebase using the Git version control system so the first task is to configure the _development machine_. Install `git` tools. Once these are installed you need to clone the repository that contains the API.
```
sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/covcom/todo.git
ls
```
This will clone the API code into a new directory called `todo`. Open the todo directory in Visual Studio Code (File > Open, then select the Developer Home directory.) Take a moment to look at the files you have cloned. In the next sections you will learn how to deploy this code using three different techniques:


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
    /home/backup *(rw,sync)
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

It looks like all internal servers have access to the remote directory. To fix this you will need to modify the configuration `/etc/exports` file on the **fileserver**. Here we restrict access to server `10.5.5.10`.
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

## SFTP

Create a linked clone of the master Alpine server. Make sure you reset the MAC address and call the server SFTP Server. This should be on the internal network. Check the connectivity as before.

Install the `vsftpd` package and open the `/etc/vsftpd.conf` configuration file in `nano`. Use the following typical settings.
```
anonymous_enable=NO
local_enable=YES
write_enable=YES
file_open_mode=750
local_umask=022
chroot_local_user=YES
user_sub_token=$USER
local_root=/home/$USER/public_html
listen=YES
```
File permissions are controlled using two configuration values

- file_open_mode: the permissions applied to the file
- local_unmask: the permissions removed from the file

Note that the user won't be able to save files in their home folder which is a security feature implemented by vsftpd. This is why we have specified a directory called `public_html`, notice the use of an **environment variable** to create the correct path based on the username.

After updating the configuration file you will need to restart the service using one of the following commands.
```
service nfs-kernel-server restart
/etc/init.d/vsftpd restart
```