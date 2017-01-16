#!/bin/sh

for lockfile in `ls /nethack/*lock.0`
do
#  echo $lockfile

  export USERNUM=`strings $lockfile | head -n 1 | sed 's/save\///' | awk 'BEGIN{FS=""}{printf "%s%s%s%s\n", $1, $2, $3, $4}'`
  export USERNAME=`grep ":$USERNUM:" /etc/passwd | awk -F ':' '{print $1}'`
  export ISPLAYING=`who | grep "$USERNAME " | wc -l`

#  echo "USERNUM: $USERNUM"
#  echo "USERNAME: $USERNAME"
#  echo "ISPLAYING: $ISPLAYING"

  if [ "0" -eq "$ISPLAYING" ]; then
    echo "NOT PLAYING; RECOVER ($USERNAME)"
    echo $lockfile
  else
    echo "PLAYING; DO NOT RECOVER ($USERNAME)"
  fi
done
