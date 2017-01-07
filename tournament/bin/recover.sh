#!/bin/sh

export NHHOME="/nethack/tournament"

export RECOVERBIN="/usr/local/bin/recover-3.4.3"

if [ ! -f "$RECOVERBIN" ]; then
    echo "ERROR: no recover binary"
    exit
fi

export LOCKNAME=$1
echo "LOCKNAME: $LOCKNAME"
export USERNUM=`strings /nethack/$LOCKNAME.0 | head -n 1 | sed 's/save\///' | awk 'BEGIN{FS=""}{printf "%s%s%s%s\n", $1, $2, $3, $4}'`
echo "USERNUM: $USERNUM"
export USERNAME=`grep ":$USERNUM:" /etc/passwd | awk -F ':' '{print $1}'`
echo "USERNAME: $USERNAME"
export USERHOME=`grep ":$USERNUM:" /etc/passwd | awk -F ':' '{printf ":%s:%s:", $1, $6}' | grep ":$USERNAME:" | awk -F ':' '{print $3}'`
echo "USERHOME: $USERHOME"

export i=1
export RECOVERI="001"
export v=1

while [ -d "$USERHOME/$RECOVERI" ]
do
  export i=$((i+v))

  if [ 10 -gt $i ]; then
    export RECOVERI="00$i"
  else
    if [ 100 -gt $i ]; then
      export RECOVERI="0$i"
    else
      export RECOVERI="$i"
    fi
  fi
done

export RECOVERNUM="$RECOVERI"

echo "RECOVERNUM: $RECOVERNUM"

mkdir $USERHOME/$RECOVERNUM

for lockfile in `ls /nethack/$LOCKNAME.*`
do
  cp -p $lockfile $USERHOME/$RECOVERNUM/
done

export RECOVERFILE=`$RECOVERBIN -d /nethack $LOCKNAME 2>&1 | awk '{print $4}' | sed 's/save\///'`

if [ -f /nethack/save/$RECOVERFILE.gz ]; then
  mv /nethack/save/$RECOVERFILE $USERHOME/$RECOVERNUM/
else
  cp /nethack/save/$RECOVERFILE $USERHOME/$RECOVERNUM/
  chown nethack /nethack/save/$RECOVERFILE
  chmod g+w /nethack/save/$RECOVERFILE
  gzip /nethack/save/$RECOVERFILE
fi
