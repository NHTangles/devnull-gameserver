#!/usr/local/bin/bash

if [ -f tmp/shellinaboxd.lock ] ; then
  export LOCKPROC=`cat tmp/shellinaboxd.lock`
  export ISCURRENT=`ps -ax | awk '{if ($1 == ENVIRON["LOCKPROC"]) print $1;}' | wc -l`

  if [ "$ISCURRENT" -eq "0" ] ; then
    echo "stale lock (proc: $LOCKPROC); removing"

    rm tmp/shellinaboxd.lock

    echo "starting Shell-in-a-Box"

    echo "$$" > tmp/shellinaboxd.lock

    cd ~nhplayer ; sudo -u nhplayer  /usr/local/bin/shellinaboxd -t

    rm tmp/shellinaboxd.lock
#  else
#    echo "current lock; leaving well enough alone"
  fi
else
  echo "starting Shell-in-a-Box"

  echo "$$" > tmp/shellinaboxd.lock

  cd ~nhplayer ; sudo -u nhplayer  /usr/local/bin/shellinaboxd -t

  rm tmp/shellinaboxd.lock
fi
