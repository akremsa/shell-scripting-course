#!/bin/bash

#Make sure that script is being executed with superuser priviliges
if [[ "${UID}" -ne 0 ]]
then
 echo "Please run with sudo or as a root." >&2
 exit 1
fi

# Get the number of parameters
PARAMS_NUMBER="${#}"

# Get params
PARAMS="${@}"

# There should be at least 1 parameter
if [[ "${PARAMS_NUMBER}" -lt 1 ]]
then
 echo "You must provide at least 1 parmeter. You can specify a list of usernames." >&2
 exit 1
fi

for p in ${PARAMS}
do
 ID="$(id -u $p 2>/dev/null)"
 echo "User name: $p"
 echo "User ID: ${ID}"
 echo "id command status: ${?}"
 if [[ "${?}" -ne 0 ]] || [[ -z ${ID} ]]
 then
  echo "can not get ID for a user: ${p}" 
  exit 1
 fi


 if [[ ${ID} -lt 1000 ]]
 then
  echo "Can not delete or disable an account with UID less than 1000." >&2
  exit 1
 fi

# Disable account
chage -E 0 ${p}

if [[ "${?}" -ne 0 ]]
then
 echo "Can not disable an account: ${p}, ID: ${ID}" 
fi


done



