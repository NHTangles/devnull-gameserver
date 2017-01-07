#!/usr/local/bin/bash

# NOTES:
#	only to be run _after_ ruinning makeserver

if [ "" != "$1" ] ; then
  MODE=$1
else
  MODE="safe"
fi

cd /usr/ports/games/nethack

rm -rf /usr/ports/pobj/nethack-3.4.3*
rm /usr/ports/packages/*/all/nethack-3.4.3*.tgz

make patch

cd /usr/ports/pobj/nethack-3.4.3*
patch < /usr/local/tournament/nethack.diff
perl -pi -e 's/\#define\ WIZARD\ \"games\"\n//g;' nethack-3.4.3/include/config.h

cd /usr/ports/games/nethack

make package

echo "deploying 'safe' files ..."

mv -f /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/nethack /usr/local/lib/nethackdir-3.4.3/nethack

chown nethack:nethack /nethack/nethack
chmod 755 /nethack/nethack
chmod ug+s /nethack/nethack

mv -f /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/recover /usr/local/lib/nethackdir-3.4.3/recover

chown nethack:nethack /nethack/recover
chmod 755 /nethack/recover

mv -f /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/x11tiles /usr/local/lib/nethackdir-3.4.3/x11tiles

chown nethack:nethack /nethack/x11tiles
chmod 664 /nethack/x11tiles

if [ "unsafe" == "$MODE" ] ; then
  echo "deploying 'unsafe' files ..."

  cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/*.lev /usr/local/lib/nethackdir-3.4.3/
  cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/opt* /usr/local/lib/nethackdir-3.4.3/
  cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/dungeon /usr/local/lib/nethackdir-3.4.3/
  cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/data /usr/local/lib/nethackdir-3.4.3/
  cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/quest.dat /usr/local/lib/nethackdir-3.4.3/

  chown nethack:nethack /nethack/*.lev
  chown nethack:nethack /nethack/opt*
  chown nethack:nethack /nethack/dungeon
  chown nethack:nethack /nethack/data
  chown nethack:nethack /nethack/quest.dat
fi

touch nethack:nethack /nethack/xlogfile
chown nethack:nethack /nethack/xlogfile
