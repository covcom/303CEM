
# Linux (Alpine)

## Building a Gateway Server

In this task you will use the Alpine Linux image to build a gateway server which will have two network interfaces. The first (eth0) will be connected to the internal network whilst the other (eth1) will connect to the outside world. It will hand out IP addresses and other settings to the hosts on the internal network and will pass traffic from the internal network to the external one using Network Address Translation (NAT).

First, download the VirtualBox software, choose one that supports 64 bit systems. Next download the 64 bit version of (Alpine Linux)[https://www.alpinelinux.org/downloads/] that has a kernel optimised for virtual machines, the file was called `alpine-virt-3.4.4-x86_64.iso` at the time of writing, this is around 30MB.

Launch VirtualBox and click on the **New** button to create a new virtual machine.

![Naming the VM](.images/step01.png)

On the next screen assign 512MB memory.

![Allocating Memory](.images/step02.png)

Now create a virtual hard disk. The type should be **VDI** and it should be dynamically allocated. 8GB should be sufficient. The disk will grow as needed so we will end up with a total image size of no more than 150MB.

![Creating a Hard Drive](.images/step03.png)

Select the image and click on the **Settings** button. Select the **Storage** tab. Choose the empty IDE controller (with the CD icon) and click on the CD icon in the attributes section to select the .iso image you downloaded earlier.

![Selecting the installation image](.images/step04.png)

Now the CD has been inserted we can close the settings screen and click on the **Start** button to boot the server from the installtion media. You will be presented with a login prompt, enter the username of `root` and press enter.
```
Welcome to Alpine Linux 3.4
Kernel 4.4.22-0-virtgrsec on an x86_64 (/dev/tty1)
localhost login: _
```
Once logged in you will need to go through the setup script using the `setup-alpine` command.
```
localhost:~# setup-alpine
```

1. Choose the `uk` keyboard.
2. The system hostname should be set to `gateway`
3. Choose to initialize the `eth0` interface (default option)
4. Set the address as `dhcp` (the default option)
5. You don't want to carry out any additional network configuration (`no`)
6. Now you will be prompted to change the root password.
7. Choose the `UTC` timezone
8. Choose `none` for proxies
9. Choose proxy number `13` (the UK based one)
10. Choose the default `openssh` option
11. Choose the default `chrony` as your NTP client

The next step is _really important_, we need to install the OS to `sda` which is the linux name for hard disk 1, its our virtual hard drive. We need to then choose the `sys` option. You will be prompted to erase the disk and continue, you need to choose `y`.

Linux is now installed and we need to shut the system down using the `poweroff` command so we can remove the CD and check the network settings.

Open the Settings again, choose the **Storage** tab and click on the CD in the Attributes section, selecting the _Remove Disk from Virtual Drive_ option. If you don't eject, the next time you power up the server it will boot from the CD instead of the hard drive!

![Ejecting the CD](.images/step05.png)

### networking

Select the **Network** tab and make sure the first network adaptor is set to **NAT**. This means that all network traffic from the virtual machine will be handled by the _Host Computer_ (your laptop/desktop).

![Network Adapter 1](.images/step06.png)

Now we can boot the server again by clicking on the **Start** button.

Once booted up you should log in as `root` using the password you specified. To check your connectivity try pinging the Google server.
```
ping google.com
```
There are some useful tools we should install.
```
apk add nano
```
Finally power down the server so we can clone it.

## Cloning the Server

Right-click the stopped server and choose the **Clone** option as shown.

![Cloning the Server](.images/step07.png)

Change its name to **Gateway** and make sure the box is checked to Reinitialise the MAC address otherwise all your servers will share the same one! Choose to make a **Linked Clone**, this takes up less space than a full clone.

![Cloning the Server](.images/step08.png)

The gateway server will need a second network card to communicate with the internal network. Select this cloned server and open the **Settings**. Select the **Network** tab and choose the **Adapter 2** tab. Enable the adapter and choose the **NAT** option. Linux will detect this interface as `eth1`.

Return to the first Interface and change it to **Internal**.

![Cloning the Server](.images/step09.png)

Boot up the Gateway server and log in. Network configuration is stored in the `/etc/network/interfaces` file so this needs to be loaded in the `nano` editor.
```
nano /etc/network/interfaces
```
The first network interface `eth0` is currently using DHCP to pick up an IP address but this will be changed for a static address. This means we need to replace `dhcp` with `static`.
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.5.5.1
netmask 255.255.255.0
    hostname gatewayInternal

auto eth1
iface eth1 inet dhcp
    hostname gatewayOut
```
Save and exit `nano` then we restart the networking and check the interface settings.
```
/etc/init.d/networking restart
ifconfig
```
You will see that both network interfaces have IP addresses!

## DHCP Server

Now we will install the `dhcp server` and `iptables`.
```
apk add dhcp
apk add iptables
```
Create a simple configuration file in the current directory called `dhcpd.conf`. We use Google's DNS server `8.8.8.8`.
```
default-lease-time 600;
max-lease-time 7200;
authoritative;
log-facility local7;

subnet 10.5.5.0 netmask 255.255.255.0 {
  range 10.5.5.2 10.5.5.254;
  option domain-name-servers 8.8.8.8;
  option routers 10.5.5.1;
  option broadcast-address 10.5.5.255;
  default-lease-time 600;
  max-lease-time 7200;
}
```

Now we can set up the NAT IPTables rule. This allows traffic from the internal network to be sent out through our gateway. Create a file called `startGateway`.
```
# Allow traffic forwarding
sysctl -w net.ipv4.ip_forward=1

# Set up the IPTABLES rule
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```
Now we can run it to make sure it works `sh startGateway`.

FInally we start the DHCP server. Before doing so we need an empty lease file.
```
touch /var/lib/dhcp/dhcpd.leases
dhcpd -4 -f -d -cf ./dhcpd.conf --no-pid eth0
```
We now have a functioning gateway server.

## Creating an Internal Server

To test it we need to make a new clone of our Alpine image. This one will only have internal networking. When it boots up we should see it ask the gateway for an IP address.

Clone the Alpine server and call it `Client`. Remember to reinitialise the MAC address and make it a Linked Clone.

Open the **Settings** and, in the **Network** tab configure Interface 1 as **Internal**. If we now boot up the server we can see it picks ip an IP address from the gateway server. If we check the route you will see it sends its requests through the gateway. Log into the client. We can check that the inteface has an IP address and that the requests get routed through the gateway server.
```
ifconfig
ip route show
```
Notice is passes traffic through `10.5.5.1` which is the internal interface of our gateway. Can we ping:

1. the gateway?
2. an IP address on the Internet?
3. an address that requires a DNS lookup?
```
ping 10.5.5.1
ping 8.8.8.8
ping bbc.co.uk
```

## Additional Instructions (Not Verified)

Confirm the network interfaces within the VM by typing:

`ip -4 addr show scope global`.
		
There should be two interfaces with network address ranges so identify the public routing interface by typing:

`ip route show | grep default`
		
Turn on port forwarding for this session on the gateway machine:

`echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward`

## 5. Setting up the Firewall

“iptables” is in essence a firewall that is normally an integral part of a linux distro, this will need to be configured on the **gateway server**.

We create a forward chain rule which _accepts port 80 connections on the public interface_ `enp0s3` and passes them to the private interface `enp0s8`. This first rule allows the first packet of a connection request:

`sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT`

Next we allow subsequent packet exchanges subsequent to the initial connection request:

`sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT`

and:

`sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT`

Now we have to set-up the routing rules for NAT so that the port 80 requests are mapped to one of the private VMs which will act as a web server (substitute the IP address for 192.168.56.102 below):

`sudo iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to-destination 192.168.56.102`

The return communication from the private VM/web server needs to be pointed back to the gateway internal address as the inward communication packets currently have a return address outside of our local network (substitute your gateway internal address for 192.168.56.103 in the following):

`sudo iptables -t nat -A POSTROUTING -o enp0s8 -p tcp --dport 80 -d 192.168.56.102 -j SNAT --to-source 192.168.56.103`

Additionally you will want to allow for outbound browsing from the network so add these rules too:

```
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
```

If you want to save these iptables rules so that they will be run on restart of the gateway VM then install iptables-persistent:

`sudo apt-get install iptables-persistent`

and save the rules when prompted to do so.

## 6 Check the Connectivity

Now, if we have set-up a web server on our local VM/web-server machine then we should be able to `curl` to the external gateway address from outside of your internal private virtual network e.g. from a neighbour’s computer and you should successfully connect to the web server.

CONGRATULATIONS! You have now configured a network with a gateway and port forwarding. Think about the arguments provided to `iptables`. Can you identify what they do?

Have fun :-)
