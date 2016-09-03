
# Linux

Linux is the most popular operating system and also the most powerful and flexible. During the module you will be working with servers running linux and be required to interact with them using the **shell**, there will be no graphical user interface! This first lab aims to bring you up to speed with the core skills you will need. If you are already familiar with the linux shell, feel free to jump straight to the 'Test Your Knowledge' sections. If you are new to the Linux shell, take time to read through the information carefully.

## 1 Creating a Virtual Machine (VM)

The first step is to build a server on which to practice your skills. The name 'Linux' refers only to the **Kernel**. This is is a piece of software that sits between the hardware and the _applications_ that you will be running. Strictly speaking this should be referred to as **GNU Linux**. GNU Linux is **Open Source** which means anyone can download and use the sourcecode and use it in their own projects.

When we install Linux we choose a **Distribution**, often abbreviated to **Distro**. This is an operating system consisting of the Linux Kernel plus the additional tools and libraries needed to make it useful. Because GNU Linux is open source, many individuals and groups have used it to create their own distros and as a result there are hundreds to choose from.

Linux distros tend to fall into two main categories, based on the **package manager** they use. Some, like Ubuntu, use the Debian package manager wilst others such as Fedora use the Red Hat Package Manager (RPM). In each of these categories you can find **Desktop** distros which come bundled with a GUI and lots of media and productivity applications and are designed to be installed on desktop and laptop computers. Some are designed for use on servers and dispense with a GUI but include the software useful for servers such as SSH Server tools.

During this module we will be working with **Ubuntu Server** which, at the time of writing was on version **16 LTS**. LTS stands for Long-Term Support and means the debian team will support it for 5 years.

### 1.1 Tasks

1. Download and install the latest version of [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads), this was 5.1.4 at the time of writing.
2. Locate the latest LTS release of the [Ubuntu Server Distro](http://www.ubuntu.com/download/server) and download the .iso file.
3. Create a new Virtual Machine XXXXXXXXXXXXXX

## 2 The Linux Shell

You will be interacting with your Linux server using the **Shell**. This is a piece of software that acts as an interface between the Kernel and the user (you). Specifically the Shell is a Command-Line Interpreter (CLI). It interprets the commands you type in and sends instructions to the Kernel.

### 2.1 Tasks

1. Log into your server VM using the username and password you chose. Notice the shell prompt which ends with a **$** symbol.
2. Enter the `ps` command and press the _return_ key to report on the currently running processes.
  - Notice that this returns a single row of data with 4 columns:

```
PID TTY      TIME    CMD
881 ttys000  0:00.12 -bash
```
- PID: The process ID. Each running process has a unique ID.
- TTY: Teletypewriter. A process that allows user interaction.
- TIME: How much CPU time the process has been running.
- CMD: The name of the command that launched the process (we are using the **bash** shell)

## 3 The Filesystem

Next we will examine the filesystem, looking at how files are organised in directories. All linux distributions have a very similar drectory structure.

Unlike Windows systems, there are no drive letters, all physical storage devices are mounted on subdirectories of `/`, called **root**.

lets start by navigating to the root directory and studying the top level directories. The `cd` (change directory) command takes a single argument, the directory we want to navigate to, in this case **root** `/`. The `ls` (list) command lists all the files and directories in the current, working, directory.
```
cd /
ls
  bin   etc         lib         media  proc  sbin  sys  var
  boot  home        lib64       mnt    root  snap  tmp  vmlinuz
  dev   initrd.img  lost+found  opt    run   srv   usr
```
Lets take a look at what is stored in some of the important directories:

- `/boot` is where the linux kernel and boot loader files are stored.
- `/etc` is where the system configuration files are stored.
- `/bin` contains the binaries (executables) for the essential system programs
- `/sbin` contains special binaries needed by the system adminstrator.
- `/opt` is where additional software ins installed
- `/var` contains the files that change such as log files and printer spools
- `/lib` contains shared libraries
- `/home` contains the home directories for the system users
- `/tmp` used for temporary files
- `/dev` contains the devices available on the system
- `/media` this is where removable media devices are mounted

Use the `cd` command to navigate to the `/bin` directory.
Use the `ls` command to list the contents.

### 3.1 Pipes

You may have noticed that there are a lot of files in this directory, including many of the most common commands you will be using. What if we want to search for a particular binary?

Its time to learn about Linux **pipes**. A pipe (indicated using the `|` character) allows Linux to send the output of one program to another program for processing.

when we run the `ls` command, its output is sent to stdout (which defaults to the shell TTY).

Lets learn about another command called `grep` which is a text filter. We can pipe the output of `ls` to `grep` and let `grep`
 send the results to stdout. This will only display files that contain `ls`.
```
ls | grep ls
  false
  ls
  lsblk
  lsmod
  ntfsls
```
You will be using pipes a lot.




1. disk partitions
2. network file systems, mounts.
3. logs, logcheck.
2. kernel
3. connecting using SSH
4. install packages
5. user accounts, password aging. disk quotas.
6. using sudo
7. file permissions
8. starting and stopping services, monitoring with top.
9. environment variables

Exercise: build and configure a system to an agreed specification. In the third lab this can be the basis for the Ansible script?

## More Advanced

Perhaps this needs to be in topic 2?

Networking and More Linux

1. pipes and redirection
1. the YAML file format
2. network IP addresses and ports. Domain names (student get a free domain).
3. Firewalls: local and remote port forwarding with IP Tables, policy chains.
4. SSL: concepts, certificates (self signed and third-party) students get free certificate.
5. shell scripting
6. Jinja2 templating
7. authentication options: Kerberos+LDAP/Active Directory.
8. intrusion detection systems (Network IDS, Snort/Suricata, Kismet, Tripwire)
9. penetration testing.
9. cron jobs
9. system backups with Rsync

Security?
