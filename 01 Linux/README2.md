# Linux Servers

## Resizing the Partition

The disk image is very small and, when you install it on your SD card it will create a small partition for itself which means most of the space on the SD card will be unused. We can see this if we use the df command.
```
df -h
Filesystem      Size  Used Avail  Use% Mounted on
rootfs          783M  767M     0  100% /
/dev/root       783M  767M     0  100% /
devtmpfs        108M     0  108M    0% /dev
tmpfs            24M  336K   23M    2% /run
tmpfs           5.0M     0  5.0M    0% /run/lock
tmpfs            47M     0   47M    0% /run/shm
/dev/mmcblk0p1   75M   20M   56M   26% /boot
```
If you look at the line in red you can see that the root file system has no space left! The problem is that the boot partition (last line) only has a capacity of 75MB even though the card itself may be a lot bigger. To fix this we will expand this boot partition to fill the SD card.

Lets run the fdisk command on this boot partition  fdisk /dev/mmcblk0 . The steps we will take are to delete the current partition and create a new one that uses all the available space on the SD card.
This is an interactive tool and at any point you can use the m command to see all the available options. These are the steps you need to carry out, the letter in brackets is the command you enter:

1. view the current partition table so we know which partition to resize (p). Make a careful note of the start of partition 2!
2. delete the linux partition (d) (2)
3. create a new primary partition 2 (n) (p) (2)  enter 125056 (the value you noted in step 2) as the start and accept the default value for the end.
4. write the new table to disk and exit (w)

To apply these change we need to run the resize2fs command on our resized partition. This will resize the partition and restart the server  reboot  . You can then check the new partition size to make sure it has indeed changed.
```
resize2fs /dev/mmcblk0p2
df -h
```

## Assigning a Static IP Address

Most servers are locked away in a server room and we have to connect to them remotely. To learn this we will be connecting remotely to our RPi. To do this we need to know its IP address. The NIC will auto-configure when it finds a network and it will be automatically assigned an IP address by the DHCP server. We need to know what this is. Connect it to a network socket and boot up. Log in and type in:
```
ifconfig
eth0      Link encap:Ethernet  HWaddr b8:27:eb:67:60:57  
          inet addr:192.168.1.63  Bcast:192.168.1.255  Mask:255.255.255.0
```
The current IP address is labelled as the **inet address**. (yours will be different). Make a note of this as well as the **Bcast** and **Mask** addresses.

Next run the netstat command and note the Destination and Gateway IP addresses:
```
netstat -nr
Kernel IP routing table
Destination  Gateway        Genmask         Flags   MSS Window  irtt Iface
0.0.0.0      192.168.1.254  0.0.0.0         UG        0 0          0 eth0
192.168.1.0  0.0.0.0        255.255.255.0   U         0 0          0 eth0
```
You should now have five addresses noted down.

The next step is to assign your RPi static address, your network team will provide the IP address to use. Log in and edit the interfaces file:
```
nano /etc/network/interfaces
```
You need to change the contents of the file to the following (substitute your values).
network is where you enter your destination address.
```
# The primary network interface
auto eth0
iface eth0 inet static
address 192.168.1.63
netmask 255.255.255.0
network 192.168.1.0
broadcast 192.168.1.255
gateway 192.168.1.254
```
Save and close the file `ctrl+O`, `ctrl+X` then restart the server using `shutdown -r now` to load the new network settings.
You can now log in using this new IP address.

## User Accounts

We now need to create a new user called git. We will also create a home folder for them which is where we will create both the repository and the working directory. Next we will assign a password and finally add them to the sudoers group.
```
useradd -s /bin/bash -m -d /home/git -c "Running Node" git
passwd git
sudo usermod -a -G sudo git
```

## Generating a Key Pair

You need to be logged in as the correct user. Choose the default options. The second command copies the public key to the clipboard. The final command displays the public key in the terminal window.
```
ssh-keygen
xclip -sel clip < ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub
```
### Sharing the Public Key

There is a simple way to exchange public keys with your server. Run the following on your dev machine.
```
ssh-copy-id -i $HOME/.ssh/id_rsa.pub git@90.244.88.01
```
This copies the public keys into the `~/.ssh/authorized_keys` file on both machines. Once this is done you will be able to ssh to the server without requiring your username and password.

## Changing the hostname.

Need to update two files. The default raspberry pi hostname if you have installed minibian is `minibian`. It is recommended that you use your university username to ensure your hostname is unique.

1. `/etc/hostname`
2. `etc/hosts`

Once changed you can apply the changes without restarting the server. or you can restart the server using the `reboot` command.
```
/etc/init.d/hostname.sh start
```

## Installing packages

Sometimes need to clean up the local caches before updating.
```
rm /var/lib/apt/lists/partial/*
apt-get update -y
apt-get upgrade -y
```
Installing useful packages. Only install the `rpi-update` package (firmware update for the Raspberry Pi) if you are working with a Raspberry Pi!
```
apt-get install -y curl git tree xclip nano git-core sudo aptitude apt-utils apt-transport-https rpi-update
```

List of installed packages with the `dpkg --get-selections | grep -v deinstall` command.
```
dpkg --get-selections | grep packagename    # searching for particular packages
dpkg -l
apt --installed list
aptitude search '~i!~M'                     # list of packages that were expressly installed.
apt-get remove --auto-remove packagename    # uninstall a package and remove all dependencies no longer required.
apt-get autoremove                          # uninstall packages no longer required as dependencies
```

## Installing NodeJS

If you are planning on developing server-side apps using NodeJS you will need to install it and update to the latest version. You will also need to make sure the package manager is installed and configured.

```
apt-get install nodejs
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash
nvm list-remote
nvm install 5.9.1
nvm alias default 5.9.1
node -v
```

## Change Terminal Prompt

```
  nano ~/.bashrc
# locate PS1 line and edit. note upper-case 'W'. Log out and in to see changes.
  PS1='${debian_chroot:+($debian_chroot)}\u:\W\$ '
# you can also force a colour prompt, change the PS1 option appropriately.
```

## Installing Docker
```
sudo apt-get install -y apt-transport-https
wget -q https://packagecloud.io/gpg.key -O - | sudo apt-key add -
echo 'deb https://packagecloud.io/Hypriot/Schatzkiste/debian/ wheezy main' | sudo tee /etc/apt/sources.list.d/hypriot.list
sudo apt-get update
sudo apt-get install -y docker-hypriot
sudo systemctl enable docker
```

## Installing Jenkins

To install Jenkins you need to add a new repository `deb http://pkg.jenkins-ci.org/debian-stable binary/` to the `/etc/apt/sources.list` file. We then add the repository public key. Finally update the local package index and install Jenkins.
```
wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install jenkins
```

## References

http://blog.hypriot.com/post/run-docker-rpi3-with-wifi/

http://blog.hypriot.com/post/how-to-setup-rpi-docker-swarm/

http://davidcozenssoftware.blogspot.co.uk/2015/06/installing-jenkins-on-raspberry-pi.html
