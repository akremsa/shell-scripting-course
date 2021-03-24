#!/bin/bash

# Make sure that script is being executed with superuser priviliges
if [[ "${UID}" -ne 0 ]]
then
 echo "Please run with sudo or as a root."
 exit 1
fi

# Get the number of parameters
PARAMS_NUMBER="${#}"

# There should be at least 1 parameter
if [[ "${PARAMS_NUMBER}" -lt 1 ]]
then
 echo "You must provide at least 1 parmeter. First one is a user name, others are treated as comments."
 exit 1
fi

USER_LOGIN=""
COMMENTS=""

for (( i=1; i<=PARAMS_NUMBER; i++ ))
do
 if [[ i -eq 1 ]]
 then
  USER_LOGIN=${!i}
 else
  COMMENTS+=" ${!i}"
 fi
done

# Create the user
useradd -c "${COMMENT}" -m ${USER_LOGIN}

if [[ "${?}" -ne 0 ]]
then
 echo 'usradd command did not execute succesfully.'
 exit 1
fi

# Generate a random password
PASSWORD=$(date +%s%N{RANDOM}${RANDOM} | sha256sum | head -c48)

# Set the password
echo ${PASSWORD} | passwd --stdin ${USER_LOGIN}

if [[ "${?}" -ne 0 ]]
then
 echo 'passwd command did not execute succesfully.'
 exit 1
fi
echo "User information:"
echo "login: ${USER_LOGIN}"
echo "password: ${PASSWORD}"
echo "host name: $(hostname)"  

# Force passwrod change on first login
passwd -e ${USER_LOGIN}
 
