#!/bin/sh

for lockfile in `ls /nethack/*lock.0`
do
#  strings $lockfile | head -n 1

  export USERNUM=`strings $lockfile | head -n 1 | sed 's/save\///' | awk 'BEGIN{FS=""}{printf "%s%s%s%s\n", $1, $2, $3, $4}'`
#  echo "USERNUM: $USERNUM"
  export USERNAME=`grep ":$USERNUM:" /etc/passwd | awk -F ':' '{print $1}'`
#  echo "USERNAME: $USERNAME"

  export ISPLAYING=`who | grep "$USERNAME " | wc -l`
#  echo "ISPLAYING: $ISPLAYING"

  if [ "0" -eq "$ISPLAYING" ]; then
    echo "NOT PLAYING; RECOVER ($USERNAME)"
    echo $lockfile

    export LOCKBASE=`echo $lockfile | awk -F '/' '{print $NF}' | sed 's/.0//'`
    /nethack/tournament/bin/recover.sh $LOCKBASE
  else
    echo "PLAYING; DO NOT RECOVER ($USERNAME)"
  fi
done
