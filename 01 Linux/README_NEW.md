
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
3. Create a new Virtual Machine following the instructions given in the worksheet on Moodle. Make sure you select the **OpenSSH-Server** package from the list.
4. Install Ubuntu Server 16 LTS keeping a note of the installation choices you made.
5. When the server reboots, log in using the account you created.
6. Locate the **IP Address** of your server (see note below) and make a note of it.

#### 1.1.1 Finding the IP Address

When you boot up your server, the bridged network adapter will connect to the network just like your host and request an IP address from a DHCP server (this will be explained in more detail next week). To connect to your server using SSH you need to know the IP address it has been assigned.

To do this you need to log into the server directly and run the `ifconfig` command, this will show you the IP address used by your network adapter. Look for the `enp0s3` adapter and locate the `inet addr` value. In this case it is `192.168.0.34`. Make a note of this.
```
ifconfig
  enp0s3    Link encap:Ethernet  HWaddr 08:00:27:78:2b:86  
            inet addr:192.168.0.34  Bcast:192.168.0.255  Mask:255.255.255.0
            inet6 addr: 2a02:c7d:761e:8b00:a00:27ff:fe78:2b86/64 Scope:Global
```

#### 1.1.2 Screen Blanking

You have probably noticed that if you leave the screen for a while it blanks out. This is a type of screensaver. To see the default timeout in seconds:
```
$ cat /sys/module/kernel/parameters/consoleblank
  600
```
As you can see, the default setting is 10 minutes but this can be changed. Assigning a value of 0 will disable the screen blanking.
```
$ setterm -blank 0
$ cat /sys/module/kernel/parameters/consoleblank
  0
```
NOTE: if you are running **Alpine Linux**, the `setterm` command is not installed so we will need to install it. Start by searching https://pkgs.alpinelinux.org/contents for `setterm`. Notice it is in the `util-linux` package so we need to install this:
```
apk add util-linux
```

## 2 The Linux Shell

You will be interacting with your Linux server using the **Shell**. This is a piece of software that acts as an interface between the Kernel and the user (you). Specifically the Shell is a Command-Line Interpreter (CLI). It interprets the commands you type in and sends instructions to the Kernel.

If the server is physically in front of you you could attach a keyboard, mouse and monitor and log in directly. Most servers are located in a remote location (a secure server room either on-site or perhaps in a different country). How can we log in?

### 2.1 Secure Shell

Secure Shell (SSH) is an encrypted protocol for operating a network service over an unsecured network (the Internet for example). The data is encrypted and decrypted using a public/private key pair (you will cover this in more detail in lab 3). This provides a remote command-line login which enables you to log into your server(s) from anywhere with a network connection.

To connect to your server you need to use a suitable **SSH Client**. If you are running a *NIX operating system such as Linux or Mac you can use the SSH command through your Terminal but for Windows users you will need to install a third-party tool such as puTTY.

There are two ways to use SSH.

#### 2.1.1 Encrypted Network Connection

The first way is to use automatically-generated key pairs to encrypt the network connectio.

To connect you need to know the server's IP address and the port it is running over (which defaults to port 22). For Mac and Linux clients you run:
```
ssh username@xx.xx.xx.xx
  The authenticity of host '192.168.0.33 (192.168.0.33)' can't be established.
  ECDSA key fingerprint is SHA256:A+RnpQ4cwTQUcePW+w6TI4f8o5YAbtOR2wzJciqRigM.
  Are you sure you want to continue connecting (yes/no)? 
```
Subsitute the correct username and IP address. The second example is if you need to connect over a non-standard port. 

#### 2.1.2 SSH Authentication

An alternative is to use the key pair to perform authentication instead of typing in a password. The first step it to make sure there is a public and private key generated on the client machine.

On a *NIX machine its located in a hidden directory located in the home directory (`~/.ssh/`). There should be two files, `id_rsa`, the private key and `id_rsa.pub`, the public key.

Next you need to generate the key pair on the server by logging in and running the `ssh-keygen -t rsa` command. Accept the default options by pressing enter for each question.


Finally you need to copy the public key from your host machine to the server. If you are on *NIX there is a special command to achieve this.
```
ssh-copy-id username@xx.xx.xx.xx
```
This will add the client's public key to a list of authorised keys on the server. The list is stored in:
```
~/.ssh/authorized_keys
```
If this command is not available you may need to manually copy the public key, log on to the server and paste it into the `authorized_keys` file using the **nano** editor.

Once you have done this you should be able to SSH in as normal. the server will authorise using the shared public key and you won't be asked for a password.

#### 2.1.3 Changing the Shell Prompt

The terminal prompt displays useful information. For example here is a sample prompt from my laptop:
```
mark@mark-ThinkPad-T450s:~/Documents$
```
It includes the username, the computer name and the current filepath.

It is possible to customise this. The settings are stored in the `PS1` environment variable.
```
$ echo $PS1
\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
mark@mark-ThinkPad-T450
```
To change the prompt you simply set the `PS1` environment variable using special escape characters to insert certain data. For example to only display the current directory, see http://ezprompt.net/ for details:
```
$ PS1="\W$ "
~$ cd  
```

#### 2.1.4 Tasks

1. Log into your server VM over SSH using the username and password you chose. Notice the shell prompt which ends with a **$** symbol.
2. Log out by using the `exit` command.
3. Generate a public/private key pair if needed. 
4. Copy your client computer's public key into the `authorized_keys` file on the server.
5. SSH back into the server, you won't be prompted for your password.

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

## 4 Users and Groups

In this section you will learn abount how access control is managed through the use of users and groups.

### 4.1 User Accounts

By default, Linux is a multi-user system. In this section you will learn how to create new user accounts. This is done using the `useradd` command. Here is the command to add a new user, notice the use of **flags** such as `-s` to specify different options. Flags come in two styles, long and short. Short flags have a single `-` and comprise a single character whilst long flags start with `--` and are multi-character. The two examples below are functionally the same. Don't worry about the `sudo` command, you will learn more about this in the next section.

```
Alpine Linux
adduser newuser
passwd newuser
adduser newuser sudo

visudo
  add the following or uncomment then save
  %sudo ALL=(ALL) ALL
poweroff
  restart the server
```
Now we can SSH into the server. needs setting up as follows:

find the server IP address.

Settings > Networking > Adapter 1

NAT

Advanced settings > Port Forwarding > add new rule
```
Name  Protocol  Host IP    Host Port   Guest IP   Guest Port
SSH   TCP       127.0.0.1  2200        10.0.2.15  22
```
Now you can SSH into the server from the host.

```
sudo useradd -s /bin/bash -m -d /home/git -c "Running Node" git
sudo useradd --shell /bin/bash -m -d /home/git -c "Running Node" git
```

We need to learn how this works. Every tool installed includes its own _Manual_ which can be accessed using the `man` command.

Alpine Linux does not come with the man pages installed, you will have to install this before use. Some man pages will be installed automaticaly but others need to be installed before use (to save space). In this example we install the documentation for `curl`.
```
apk add man man-pages mdocml-apropos
apk add curl-doc
```

Open the documentation for the `useradd` command by running `man useradd`. This will open the help page. Now use the **pg up** and **pg dn** keys to page up and down the documentation page.

Searching can be carried out using the `/` (forward slash) key followed by the search term. Lets find out the purpose of each of the _flags_ used. Type the following:
```
/-s
```
Notice how the first match is highlighted. There are several matches so we need to cycle through these. There are two ways, either press the **N** key (**shift-N** to move backwards) or type `/` to cycle through. Keep cycling through until you find the entry for the `-s` flag.

#### 4.1.1 Test Your Knowledge

1. Use the useradd documentation to learn the purpose of all the flags used. Now replace all the short flags with their long equivalent.
2. Use this knowledge to create yourself a new account.
3. Now use the `passwd` tool to assign a suitable password (you will need to use the manual!
4. Log out and then try out your new account to make sure it works.

### 4.2 Groups

In this section you will learn about configuring groups in Linux. Groups are used to organise collections of users for the purposes of security and access. All files and directories have a user and a group owner. Every user has a group of their own, you will see why in the next section.

We will start by creating a group called **coventry** to which we will add our three users. 
```
groupadd coventry
usermod -a -G coventry newuser
members coventry
```

### 4.3 File Permissions

Access control on a Linux system mirrors that of a UNIX system with each file and directory assigned access rights for:

1. The owner of the file/directory
2. The group to whom the file/directory belongs
3. Everybody else

For each of these, there are three possible permissions:

1. Read
2. Write
3. Execute

If we combine these we get 9 flags that can be set. if we view a directory using the long listing format flag we can see this information. Here we only show the first file.
```
cd /bin
ls -l
  -rwxr-xr-x 1 root root 1037528 Jun 24 16:44 bash
```
Reading left to right:

1. The first character represents the type, this is either a file (-), a directory (d) or a symbolic link (l).
2. The next three characters are the owner permissions, read (r), write (w) and execute (x). In this example the owner has all three permissions (`rwx`).
3. The next three characters are the group permissions that follow the same format as the owner permissions. In this example the group has read and execute permissions (`r-x`).
4. The last three characters in the block represent the permissions for all other users. In this example all users can read and execute (`r-x`).
5. Next the username of the owner and group are shown. In this example, because the owner and group are `root`, the file is fully owned by the root account.
6. The number to the right is the file size in bytes. By using the `-h` flag, these will be displayed in a _human readable format_ such as KB and MB.
7. After this there is the last modified date and time with the file/directory/symlink name at the end.

#### 4.3.1 Changing Permissions

The owner of the file can change the permissions of any directory/file/symlink they own using the `chmod` command. There are two ways to use this command.

The entire permission set can be assigned:
```
chmod 750 myfile
```
1. The first digit describes the owner permissions (convert to binary!) as `11` which assigns `rwx`
2. The second digit describes the group permissions as `101` or `r-x`
3. The third digit describes the permissions for all other users, in this case `000` or `---`

The alternative is to describe the _change_ you want to make.
```
chmod u+x myfle
```
1. The first character is the class (u=owner, g=group, o=others, a=all)
2. The second character is the operator(+ means add and - means remove)
3. The third character is the mode affected (r=read, w=write, x=execute)

#### 4.3.2 Test Your Knowledge

In these tasks you will be introduced to a number of new commands. before using them make sure you read the `man` pages.

1. As root, create a directory `/home/coventry`.
2. Set the group of this new directory to your new `coventry` group using the `chgrp` command.
3. Give your new group read and write permissions but not execute. Make sure this directory is not accessible by anyone not in the group.
4. Create an empty text file inside this called `readme.md` using the `touch` command.
5. What are the default permissions on this new file?
6. Log in as your new user and make sure you can see the directory and file and can edit the file using `nano`.
7. Create a new user but don't add them to your `coventry` group.
8. Make sure they can't see the `coventry/` directory.

### 4.4 Sudo

There are two types of user account, normal and root. Normal accounts can only access specific directories and commands (the standard commands are in the `/bin` directory). These accounts can't cause damage to the overall system and are used for most activities. By default all new accounts are of this type.

There is also a special **root** account which has full system privileges and can be used to damage a system. There are additional commands that only the root user can use, these are located in the `/sbin` directory.

You should _never_ log in as root! But if you can't log in as root how can you install software which requires root privileges? The answer is **sudo**. This is a special group created when Ubuntu was installed. Every user who is a member of the sudo group has special powers! The original account you created when you installed Ubuntu Server has already been added, which is why you were able to create additional user accounts (see previous section).

There are two ways to use sudo. The first is to preceed the command with sudo which will execute that command as root and then return you to ordinary privileges. When you try to run a command using sudo you will be asked for your password. If you don't use it for over 10min it will ask you for your password again.

The second way is to switch to a root account then run the commands without prefixing with sudo by typing `sudo -s`. You will notice that the system prompt switches from a `$` to a `#`. This reminds you that you are logged in as root and should be cautious when running commands. To return to the non-root account you use the `exit` command just like you were trying to log out.

#### 4.4.1 Test Your Knowledge

1. Log in using your new account and try to add a new user. What error do you get?
2. Log out and then log in using the original account you created when installing the operating system.
3. Add your new user to the _sudoers_ group using `sudo adduser newusername sudo` remembering to substitute your new username. Because you needed root privileges to do this you needed to add the `sudo` command.
4. Log out and back in as your new user. Now try to create another user account.
5. Switch to the root account using `sudo -su` and create another account.

## 5 Package Management

Ubuntu comes with a powerful package management system for installing, configuring, upgrading and removing software called **APT**, the same system used on Debian systems. if you were to work with a Red Hat server you would need to use a different system.

Each package contains all the necessary files and instructions needed for the required software to work. Packages can be installed in two ways:

1. Downloading the package (this has a `.deb` extension) and installing it using the `dpkg` command
2. Connecting to a repository that contains lots of packages and installing directly from there.

Of the two approaches, the second is best however if the package you want is not hosted in a repository you will need to directly download and install the `.deb` file.

### 5.1 Installing from a Repository

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

- `main` - Canonical-supported free and open-source software.
- `universe` - Community-maintained free and open-source software.
- `restricted` - Proprietary drivers for devices.
- `multiverse` - Software restricted by copyright or legal issues.

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

### 5.2 Services

A Linux **service** is an application that runs in the background waiting to be used. Examples of this are the SSH server (handles client SSH connections) and the Apache web server you have just installed. 

Each service can be started and stopped and it is easy to see a list of all the currently installed services and whether they are running or not.
```
sudo service -- status-all
  [ + ]  apache2
  [ - ]  sudo
  [ + ]  ssh
  [ ? ]  networking
```
There are three possible states:
- `[ + ]`: the service is running
- `[ - ]`: the service is stopped
- `[ ? ]`: the service status is undetermined and is not being controlled by the `service` tool.

You can check for the status of one service:
```
sudo service apache2 status
  * apache2 is running
```
The `service` command can be used to start, stop and restart a named service assuming the service is not controlled through a different tool (`[ ? ]`).
```
sudo service apache stop
sudo service apache start
sudo service apache restart
```

### 5.3 Service Configuration

Each installed service can be configured. On Linux systems configuration is handled through text files. All configuration files are typically stored in a directory matching the service name in the `/etc/` directory. So for example the apache configuration files are in the directory `/etc/apache2/`.

If you open up this directory you will see several files. The configuration file is called `apache2.conf` and can be viewed using a _terminal pager program_ such as `less` or edited using a _command-line text editor_ such as `nano`. Service configuration files are only writable by users with root privileges.
```
less /etc/apache2/apache2.conf
sudo nano /etc/apache2/apache2.conf
```
A service needs to be restarted for any configuration changes to be loaded.

### 5.4 Test Your Knowledge

Your challenge is to install and configure ????????


# Extra Stuff

You now have some understanding of the Linux command line however there are a lot more topics to learn. Spend the rest of your lab time investigating the topics listed below, they will help you with future labs.

1. system performance with `top`
2. environment variables
3. logs
4. processes with `ps`
5. mounting filesystems / network file systems
6. symlinks
7. navigation shortcuts (history, home, current, up)
8. directories and files (create, delete, touch, edit)

## Processes

Enter the `ps` command and press the _return_ key to report on the currently running processes.
  - Notice that this returns a single row of data with 4 columns:

```
PID TTY      TIME    CMD
881 ttys000  0:00.12 -bash
```
- PID: The process ID. Each running process has a unique ID.
- TTY: Teletypewriter. A process that allows user interaction.
- TIME: How much CPU time the process has been running.
- CMD: The name of the command that launched the process (we are using the **bash** shell)

### Logs

`/var/logs/`
