
# Linux

Linux is the most popular operating system and also the most powerful and flexible. During the module you will be working with servers running linux and be required to interact with them using the **shell**, there will be no graphical user interface! This first lab aims to bring you up to speed with the core skills you will need. If you are already familiar with the linux shell, feel free to jump straight to the 'Test Your Knowledge' sections. If you are new to the Linux shell, take time to read through the information carefully.

## 1 Creating a Virtual Machine (VM)

The first step is to build a server on which to practice your skills. The name 'Linux' refers only to the **Kernel**. This is is a piece of software that sits between the hardware and the _applications_ that you will be running. Strictly speaking this should be referred to as **GNU Linux**. GNU Linux is **Open Source** which means anyone can download and use the sourcecode and use it in their own projects.

When we install Linux we choose a **Distribution**, often abbreviated to **Distro**. This is an operating system consisting of the Linux Kernel plus the additional tools and libraries needed to make it useful. Because GNU Linux is open source, many individuals and groups have used it to create their own distros and as a result there are hundreds to choose from.

Linux distros tend to fall into two main categories, based on the **package manager** they use. Some, like Ubuntu, use the Debian package manager wilst others such as Fedora use the Red Hat Package Manager (RPM). In each of these categories you can find **Desktop** distros which come bundled with a GUI and lots of media and productivity applications and are designed to be installed on desktop and laptop computers. Some are designed for use on servers and dispense with a GUI but include the software useful for servers such as SSH Server tools.

During this module we will be working with **Ubuntu Server** which, at the time of writing was on version **16 LTS**. LTS stands for Long-Term Support and means the debian team will support it for 5 years.

### 1.1 Tasks

1. Download and install the latest version of [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads), this was 5.1.4 at the time of writing. If you are working on the lab machines you will not need to complete this step as it is already installed.
2. Locate the latest LTS release of the [Ubuntu Server Distro](http://www.ubuntu.com/download/server) and download the .iso file.
3. Create a new Virtual Machine following the instructions given.
4. Install Ubuntu Server 16 LTS keeping a note of the installation choices you made.

### 1.2 Alternative Instructions

If you are having difficulties manually installing Ubuntu in a VirtualBox try these alternative instructions.

1. Open Terminal/Command Line on your host computer.
2. Create a directory and navigate to it.
3. Create a VM using Vagrant (you may need to install this first).
4. Log in using Vagrant SSH.

```
vagrant init ubuntu/trusty64
vagrant up
vagrant ssh
```


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

### 3.2 User Accounts

By default, Linux is a multi-user system. In this section you will learn how to create new user accounts. This is done using the `useradd` command. Here is the command to add a new user, notice the use of **flags** such as `-s` to specify different options. Flags come in two styles, long and short. Short flags have a single `-` and comprise a single character whilst long flags start with `--` and are multi-character. The two examples below are functionally the same.

```
useradd -s /bin/bash -m -d /home/git -c "Running Node" git
useradd --shell /bin/bash -m -d /home/git -c "Running Node" git
```

We need to learn how this works. Every tool installed includes its own _Manual_ which can be accessed using the `man` command.

Open the documentation for the `useradd` command by running `man useradd`. This will open the help page. Now use the **pg up** and **pg dn** keys to page up and down the documentation page.

Searching can be carried out using the `/` (forward slash) key followed by the search term. Lets find out the purpose of each of the _flags_ used. Type the following:
```
/-s
```
Notice how the first match is highlighted. There are several matches so we need to cycle through these. There are two ways, either press the **N** key (**shift-N** to move backwards) or type `/` to cycle through. Keep cycling through until you find the entry for the `-s` flag.

### 3.3.1 Test Your Knowledge

1. Use the useradd documentation to learn the purpose of all the flags used. Now replace all the short flags with their long equivalent.
2. Use this knowledge to create yourself a new account.
3. Now use the `passwd` tool to assign a suitable password (you will need to use the manual!
4. Log out and then try out your new account to make sure it works.

TODO: SUDO

## 4 Package Management

Ubuntu comes with a powerful package management system for installing, configuring, upgrading and removing software called **APT**, the same system used on Debian systems. if you were to work with a Red Hat server you would need to use a different system.

Each package contains all the necessary files and instructions needed for the required software to work. Packages can be installed in two ways:

1. Downloading the package (this has a `.deb` extension) and installing it using the `dpkg` command
2. Connecting to a repository that contains lots of packages and installing directly from there.

Of the two approaches, the second is best however if the package you want is not hosted in a repository you will need to directly download and install the `.deb` file.

### 4.1 Installing from a Repository

You will be taken through the process of installing and configuring an Apache web server. Through this you will learn all about repositories and packages.

lets start by looking at the list of repositories we are using. This is stored in a configuration file which, based on your previous knowledge, you would expect to find in the `/etc` directory:
```
less /etc/apt/sources/list
  deb http://archive.ubuntu.com/ubuntu trusty main restricted
  deb-src http://archive.ubuntu.com/ubuntu trusty main restricted
  deb http://archive.ubuntu.com/ubuntu trusty-updates main restricted
  deb-src http://archive.ubuntu.com/ubuntu trusty-updates main restricted
  deb http://archive.ubuntu.com/ubuntu trusty universe
```
The `less` command opens up a file for reading. When you have finished viewing, press `q` to quit. Notice that each repository comprises a URL followed by keywords. In the example above, `trusty` refers to the version of Ubuntu, the meaning of the other keywords is: 

- `Main` - Canonical-supported free and open-source software.
- `Universe` - Community-maintained free and open-source software.
- `Restricted` - Proprietary drivers for devices.
- `Multiverse` - Software restricted by copyright or legal issues.

Before we can install our software we need to download a list of the available packages. You will need to run this with root privileges using the `sudo` command.
```
sudo apt-get update
```
This will pull a list of the packages down onto your server. Now we can search for the package we need.
```
apt-cache search apache
```
This will display a long list of result however many of the package names and descriptions don't directly include the string `apache` so we can pipe the output through `grep` to only display lines with this string.
```
apt-cache search apache | grep apache
```
This output looks better! Unfortunately the list scrolls past the end of the screen. We have already used the `less` command to display a file with the option to page up and down. In typical UNIX fashion we can pipe the output we have through this command.
```
apt-cache search apache | grep apache | less
```
Now you can use `pg up` and `pg dn` to page up and down the list of packages, press `q` when finished. Using pipes allows you to chain multiple commands together to achieve the required results.

Looking through the packages you should see a one called `apache2`, this looks promising. Before we install we should check the package description and version.
```
apt-cache show apache2
```
You will need to pagenate the results through `less`, See if you can figure out how to do this on your own.

Installing the package is done using the `apt-get` command. If the `-y` flag is omitted you will be told how much space will be used and asked to confirm installation.
```
sudo apt-get install -y apache2
```
The Apache Server package is now installed.

## 5 Groups

In this section you will learn about configuring groups in Linux.

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
