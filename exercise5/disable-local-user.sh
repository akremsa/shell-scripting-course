#!/bin/bash

#Make sure that script is being executed with superuser priviliges
if [[ "${UID}" -ne 0 ]]
then
 echo "Please run with sudo or as a root." >&2
 exit 1
fi

HOMEDIRPATH="/home"
ARCHIVEDIRPATH="/archive"

usage() {
 echo "Usage: ${0} [-dra]" >&2]
 echo "Deactivates one or several users."
 echo " -d	Deleltes an account instead of disabling it."
 echo " -r	Removes the home dirctory assoctiated with the account."
 echo " -a	Creates an archive of the home directory associated with the account and stores the archive in the /archives directory."
 exit 1
}

checkArchiveDir() {
 if [[ ! -d "${ARCHIVEDIRPATH}" ]]
 then
  echo "Archive folder does not exist. Creating ${ARCHIVEDIRPATH} ..."
  mkdir "${ARCHIVEDIRPATH}" >&2
  if [[ "${?}" -ne 0 ]]
  then
   echo "Unable to create ${ARCHIVEDIR}" >&2
   exit 1
  fi
 fi
}

# Get the number of parameters
PARAMS_NUMBER="${#}"

# There should be at least 1 parameter
if [[ "${PARAMS_NUMBER}" -lt 1 ]]
then
 echo "You must provide at least 1 parmeter. You can specify a list of usernames." >&2
 exit 1
fi

while getopts "dra" OPTION
do
 case ${OPTION} in
  d)
   DELETE_ACC=true
   ;;
  r)
   REMOVE_HOMEDIR=true
   ;;
  a)
   ARCHIVE_HOMEDIR=true
   ;;
  ?)
   usage
   ;;
 esac
done

shift "$((OPTIND-1))"

# Get params
PARAMS="${@}"

# Loop through the list of users
for p in ${PARAMS}
do
 ID="$(id -u $p 2>/dev/null)"
 echo "User name: $p"
 echo "User ID: ${ID}"
 
 if [[ "${?}" -ne 0 ]] || [[ -z ${ID} ]]
 then
  echo "can not get ID for a user: ${p}" >&2 
  exit 1
 fi


 if [[ ${ID} -lt 1000 ]]
 then
  echo "Can not delete or disable an account with UID less than 1000." >&2
  exit 1
 fi

# Disable or delete an account
if [[ "${DELETE_ACC}" = true ]]
then
 echo "Deleting an account..."
 userdel ${p}
 if [[ "${?}" -ne 0 ]]
  then
   echo "Can not delete an account: ${p}, ID: ${ID}" >&2 
 fi
else
 echo "Disabling an account..."
 chage -E 0 ${p}
 if [[ "${?}" -ne 0 ]]
 then
  echo "Can not disable an account: ${p}, ID: ${ID}" >&2 
 fi
fi

# Archive homedir. Should be performed before delete step.
if [[ "${ARCHIVE_HOMEDIR}" = true ]]
then
 checkArchiveDir
 echo "Arhiving home directory..."
 tar -cvf "${ARCHIVEDIRPATH}/${p}_homedir.tar" "/home/${p}"
 if [[ "${?}" -ne 0 ]]
 then
  echo "Unable co create an archive at ${ARCHIVEDIRPATH}"
  exit 1
 fi
fi

# Remove homedir
if [[ "${REMOVE_HOMEDIR}" = true ]]
then
 echo "Removing home directory..."
 TOREMOVE="${HOMEDIRPATH}/${p}"
 rm -rf ${TOREMOVE}
 if [[ "${?}" -ne 0 ]]
 then
  echo "Can not remove home directory: ${TOREMOVE}" >&2
 fi
fi

done



