
# System Security - Metasploitable 2

## In this lab we will perform port scanning and enumeration over the metasploitable 2.
## based upon the Metasploit hacking tutorials (http://www.hackingtutorials.org/metasploit-tutorials)

Download the metasploitable2 iso from https://sourceforge.net/projects/metasploitable/ and setup a VM with Virtualbox using NAT. Set up an alpine VM also using NAT. **Note that Metasploitable is a vulnerable distro so do not use it as anything other than a target machine.**

Run the alpine VM and install nano, nmap and samba using apk.

Start up the metasploitable VM. you should have only two VMs running.

Now return to your alpine VM.

Check your IP address and identify the network address (probably 10.0.2.1). 

We will perform some investigations over the metasploitable2 VM to identify open ports and services and user accounts on the metasploitable distro.

##Nmap

First we check the network and identify the hosts attached to the network:

We ping the network address range using nmap (-sP indicates use an ICMP ping and -R targets an address range).

...
nmap -sP -R 10.0.2.1-254
...

(assuming network is 10.0.2.0).

Can you identify target any VMs on the network? (they will be identified as Oracle VirtualBox virtual NIC).


Nmap is a powerful tool for port scanning, enumerating and fingerprinting. Normally for this exercise we use a SYN scan (check the lecture slides). This is called a stealthy scan type because the port scan does not attempt to make a full connection with the target computer (a TCP scan would attempt make a full connection to the destination address. Why is this not stealthy?). For our example we will use a non-stealthy TCP scan

Nmap takes numerous arguments at the command line. We want it to use the TCP scan method (-sT) and to scan all 65,535 ports (-p-) whereas by default nmap only scans the first 1,024 ports.

...
nmap -sT -p- 10.0.2.7
...

(your target address might be slightly different)

This might take a little while so be patient. What information can we gather from this scan? Can you identify any of the listed ports (search for some on google)?

Open ports are a potential route into a system (however a SYN scan takes **much longer**) for a hacker but it is not the case that all open ports are necessarily exploitable. We need to identify the version of the OS and services behind these ports and this will help to match against vulnerabilities.

...
nmap -sT -sV -O 10.0.2.7
...

What do the -sV and -O options do? Again, it would be stealthy to use -sS but this might take a long time.

Look at the list of services. You will see a lot of information concerning the services and their version numbers. This information enables us to check the services against known vulnerabilities. We can redirect this information to a text file so that we can peruse the list at our leisure:

...
nmap -sT -sV -O 10.0.2.7>nmap_scan.txt
...

Search google for vulnerabilities that map to any of these services. Can you find any exploits for these services (there will be a lot as metasploitable is a vulnerable server by design)? There are plenty of tools that automate this vulnerability analysis. We will return to these later. These tests have looked for possible vulnerabilities using TCP. How might you perform the same tests using UDP? Try it and save your results.

## User Enumeration

User enumeration refers to the process of discovering what users are present on the network and have access to server resources. We can use nmap to do this (try to find out for yourself how to do this). We will use **rpcclient** to investigate this (it is part of the samba package). We will use a null user:

...
rpcclient -U "" 10.0.2.7
...

There is no password.

You will notice that the command prompt has changed. Now we obtain network domain information. How many users are there on the target VM?

...
rpcclient $>querydominfo
...

Now let us extract some more detailed information:

...
rpcclient $>enumdomusers
...

queryqueryuser msfadmin
Now you can query the individual users for more information:

...
rpcclient $>queryuser [username]
...

Note that we have not needed to login as root to the target VM to retrieve this information. The next stage would be to try and use this information to  attempt to connect to the target VM.



