
# Networking Fundamentals - 303CEM Week 2 lab tasks

## Building virtual networks with a gateway

You will be creating a virtual network of at least three virtual machines (VMs). One VM should be identified as a gateway and another should be identified as a web server.

###1. Clone your existing ubuntu VM in VirtualBox:
1. highlight your Ubuntu VM and select machine… clone…
2. provide a name for the VM then select “reinitialize the mac address of all network cards” and select the “next” button
3. make sure that “full clone” is selected
4. select the “clone” button and wait.
5. A new VM will appear in the list.

###2. Make sure that your machine identified as web server has a web server installed and running (You will be able to browse or curl successfully to the web server’s internal IP address from another internal VM). If this does not work then a web server will have to be installed on the web server computer. If there is no active web server then install “nginx”:

		sudo apt-get install nginx

###3. Configuring network adapters and static IP addresses

1. Ensure that all of your VMs are manually assigned ip addresses within the local network. Also, make sure that only the VM identified as the gateway has two ethernet interfaces and the remaining VMs should be “host-only” or "internal net" adapters. You may find that the gateway is only indicating one network adapter (ifconfig to confirm). To add the second adapter with its static IP address to the gateway VM edit the "interfaces" file as follows:

		sudo nano /etc/network/interfaces

and add the following text:

		#The secondary network interface
		auto enp0s8
		iface enp0s8 inet static
		address 192.168.56.103		#this will be your internal gateway address so
		netmask 255.255.255.0		#make sure that it is in your IP address range
		network 192.168.56.0		#and remember it for configuring the other computerss
		broadcast 192.168.56.255
		gateway 192.168.56.103
	
Write out to file (save file) then restart the network service (it's probably just as easy to reboot the server). For the remaining VMs we can edit the "interfaces" file in a similar way to the above but we require only one network adapter on each of these machines (likely to be identified as "enp0s8"). So on each machine enter the following and make sure that you have different IP addresses on each machine within the network address range (192.168.56.101, 192.168.56.102, 192.168.56.103 etc.):

		sudo nano /etc/network/interfaces
		
and alter the text to the following:

		#The primary network interface
		auto enp0s8
		iface enp0s8 inet static
		address 192.168.56.xxx		#replace xxx with appropriate numbers such as 101, 102 etc.
		network 192.168.56.0
		broadcast 192.168.56.255
		gateway 192.168.56.103
		
Restart the network service (or reboot) and make sure that you can see your internal network by pinging the internal machines (VMs) from each other. 

###4. Building the gateway 

Routers and firewalls are basically hardened computers with network adapters. Linux has the tools to enable a Linux computer to act as a firewall and router which we refer to as a gateway for this session. Now set up one ubuntu VM as a gateway:

1. For the gateway VM highlight and select “settings”, then "network" within VirtualBox
2. Ensure that you have two network adapters, one should be identified as host-only and the second adapter can be NAT (bridged mode should work too).
3. Confirm the network interfaces within the VM by typing:

		ip -4 addr show scope global
		
4. There should be two interfaces with network address ranges so identify the public routing interface by typing:

		ip route show | grep default
		
5. Turn on port forwarding for this session on the gateway machine:

		echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

6. Then we set up the firewall using “iptables” on the gateway machine:

###5. “iptables” is in essence a firewall that is normally an integral part of a linux distro.

1. We create a forward chain rule which accepts port 80 connections on the public interface and passes them to the private interface (where enp0s3 and enp0s8 should be substituted with your own network adapters as appropriate). This first rule allows the first packet of a connection request:

		sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT

2. Next we allow subsequent packet exchanges subsequent to the initial connection request:

		sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

and:

		sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

3. Now we have to set-up the routing rules for NAT so that the port 80 requests are mapped to one of the private VMs which will act as a web server (substitute the IP address for 192.168.56.102 below):

		sudo iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to-destination 192.168.56.102

4. The return communication from the private VM/web server needs to be pointed back to the gateway internal address as the inward communication packets currently have a return address outside of our local network (substitute your gateway internal address for 192.168.56.103 in the following):

		sudo iptables -t nat -A POSTROUTING -o enp0s8 -p tcp --dport 80 -d 192.168.56.102 -j SNAT --to-source 192.168.56.103

5. Additionally you will want to allow for outbound browsing from the network so add these rules too:

		iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
		iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
		iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

6. If you want to save these iptables rules so that they will be run on restart of the gateway VM then install iptables-persistent:

		sudo apt-get install iptables-persistent
		
and save the rules when prompted to do so.

###6. Now, if we have set-up a web server on our local VM/web-server machine then we should be able to curl to the external gateway address from outside of your internal private virtual network e.g. from a neighbour’s computer and you should successfully connect to the web server. CONGRATULATIONS! You have now configured a network with a gateway and port forwarding. Think about the arguments provided to “iptables”. Can you identify what they do? Have fun :-)
