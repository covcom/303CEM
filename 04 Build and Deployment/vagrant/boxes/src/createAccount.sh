
#!/bin/bash

# command line arguments are stored in $1, $2, etc.
# in Bash the primary expressions (primaries) are used to indicate the conditional test.
# [-z STRING] returns true if the string has a zero length.
if [ -z "$1" ]
  then
    echo "username not specified"
    exit 1
fi

name=$1

# variables are specified with a $ symbol.
echo "Username is $name"

useradd -s /bin/bash -m -d /home/$name -c "$name" $name

# send single command to vagrant 
# vagrant ssh -c 'createAccount.sh newuser'

# echo 'username:password'|chpasswd
