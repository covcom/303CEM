
# System Security

In this lab we will perform port scanning and enumeration over the **metasploitable** which is a special server that exposes a number of serious security flaws. The lab is based on the Metasploit hacking tutorials (http://www.hackingtutorials.org/metasploit-tutorials) and you are encouraged to use these to further extend your knowledge.

## 1 Setup

1. Start the Alpine DHCP server and make sure it is running the _gateway_ and _DHCP_ services.
2. [Download](http://computing.coventry.ac.uk/~mtyers/Metasploitable.ova) the Metasploitable appliance file and import the appliance into VirtualBox. Open the settings and make sure you change the _network adapter 1_ to **Internal Network**. Start the server, log in (username and password are `msfadmin`). Make a note of the IP address (in our case it is 10.5.5.11)
3. Start the **Debian Desktop** computer (make sure this is connected to the _Internal Network_). Check it has an IP address.
4. Use Terminal to make sure you can ping both the outside world `bbc.co.uk` and the Metasploitable server.
5. Install `samba`.
  1. `sudo apt-get update`
  2. `sudo apt-get install samba -y`

We now have a server to test and a desktop environment from which to run our tests.

## 2 Testing

We will perform some investigations over the metasploitable2 VM to identify open ports and services and user accounts on the metasploitable distro.

### 2.1 Nmap

First we check the network and identify the hosts attached to the network:

We ping the network address range using nmap (-sP indicates use an ICMP ping and -R targets an address range). This assumes the network is 10.5.5.0.

```
nmap -sP -R 10.5.5.1-254
  Starting Nmap 6.47 ( http://nmap.org ) at 2016-11-14 19:32 GMT
  Nmap scan report for 10.5.5.1
  Host is up (0.00022s latency)
  Nmap scan report for 10.5.5.10
  Host is up (0.00095s latency)
  Nmap scan report for 10.5.5.11
  Host is up (0.00030s latency)
  Nmap done: 254 IP addresses (3 hosts up) scanned in 37.68 seconds
```

Can you identify the target VMs on the network?

Nmap is a powerful tool for port scanning, enumerating and fingerprinting. Normally for this exercise we use a SYN scan (check the lecture slides). This is called a stealthy scan type because the port scan does not attempt to make a full connection with the target computer (a TCP scan would attempt make a full connection to the destination address. Why is this not stealthy?). For our example we will use a non-stealthy TCP scan

Nmap takes numerous arguments at the command line. We want it to use the TCP scan method (-sT) and to scan all 65,535 ports (-p-) whereas by default nmap only scans the first 1,024 ports.

```
nmap -sT -p- 10.5.5.11
```

(your target address might be slightly different)

This might take a little while so be patient. What information can we gather from this scan? Can you identify any of the listed ports (search for some on google)?

Open ports are a potential route into a system (however a SYN scan takes **much longer**) for a hacker but it is not the case that all open ports are necessarily exploitable. We need to identify the version of the OS and services behind these ports and this will help to match against vulnerabilities.

```
nmap -sT -sV -O 10.5.5.11
```

What do the -sV and -O options do? Again, it would be stealthy to use -sS but this might take a long time.

Look at the list of services. You will see a lot of information concerning the services and their version numbers. This information enables us to check the services against known vulnerabilities. We can redirect this information to a text file so that we can peruse the list at our leisure:

```
nmap -sT -sV -O 10.0.2.7 > nmap_scan.txt
```

Search google for vulnerabilities that map to any of these services. Can you find any exploits for these services (there will be a lot as metasploitable is a vulnerable server by design)? There are plenty of tools that automate this vulnerability analysis. We will return to these later. These tests have looked for possible vulnerabilities using TCP. How might you perform the same tests using UDP? Try it and save your results.

## 2.2 User Enumeration

User enumeration refers to the process of discovering what users are present on the network and have access to server resources. We can use nmap to do this (try to find out for yourself how to do this). We will use `rpcclient` to investigate this (it is part of the samba package). We will use a null user:

```
rpcclient -U "" 10.0.2.7
```

There is no password.

You will notice that the command prompt has changed. Now we obtain network domain information. How many users are there on the target VM?

```
rpcclient $>querydominfo
```

Now let us extract some more detailed information:

```
rpcclient $>enumdomusers
```

queryqueryuser msfadmin
Now you can query the individual users for more information:

```
rpcclient $>queryuser [username]
```

Note that we have not needed to login as root to the target VM to retrieve this information. The next stage would be to try and use this information to  attempt to connect to the target VM.
