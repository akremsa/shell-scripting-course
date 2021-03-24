#!/bin/bash

# Make sure that script is being executed with superuser priviliges
if [[ "${UID}" -ne 0 ]]
then
 echo "Please run with sudo or as a root."
 exit 1
fi

# Get the name of the user
read -p 'Enter the usrname to create ' USER_NAME

# Get the login
read -p 'Enter the login ' USER_LOGIN

# Get the password
read -p 'Enter the password ' USER_PASSWORD

# Create the user
useradd -c "${USER_NAME}" -m ${USER_LOGIN}

if [[ "${?}" -ne 0 ]]
then
 echo 'usradd command did not execute succesfully.'
 exit 1
fi

# Set the password
echo ${USER_PASSWORD} | passwd --stdin ${USER_LOGIN}

if [[ "${?}" -ne 0 ]]
then
 echo 'passwd command did not execute succesfully.'
 exit 1
fi
echo "User information:"
echo "login: ${USER_LOGIN}"
echo "password: ${USER_PASSWORD}"
echo "host name: $(hostname)"  

# Force passwrod change on first login
passwd -e ${USER_LOGIN}
 
