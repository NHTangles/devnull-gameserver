#!/usr/local/bin/bash

# NOTES:
#	only to be run as "root"
#	only works with OpenBSD version 5.1 ?
#	expects Puppet-build nethack_gameserver module

cd /usr/ports/games/nethack

make uninstall
rm -rf /usr/local/lib/nethackdir-3.4.3
rm -rf /usr/ports/pobj/nethack-3.4.3*
rm /usr/ports/packages/*/all/nethack-3.4.3*.tgz

make patch

cd /usr/ports/pobj/nethack-3.4.3*
patch < /usr/local/tournament/nethack.diff
perl -pi -e 's/\#define\ WIZARD\ \"games\"\n//g;' nethack-3.4.3/include/config.h

cd /usr/ports/games/nethack
make install

cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/xlogfile /usr/local/lib/nethackdir-3.4.3/
cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/gruelair.lev /usr/local/lib/nethackdir-3.4.3/
cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/pmaze.lev /usr/local/lib/nethackdir-3.4.3/
cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/dmaze.lev /usr/local/lib/nethackdir-3.4.3/
cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/pool1.lev /usr/local/lib/nethackdir-3.4.3/
cp -p /usr/ports/pobj/nethack-3.4.3*/fake-*/usr/local/lib/nethackdir-3.4.3/joust.lev /usr/local/lib/nethackdir-3.4.3/

chown -R nhadmin:nhadmin /usr/local/tournament

ln -s /usr/local/tournament /usr/local/lib/nethackdir-3.4.3/tournament

SHELLS=`grep -c 'nethack.login' /etc/shells`
if [ "0" == "$SHELLS" ] ; then
  echo /usr/local/tournament/bin/nethack.login >> /etc/shells
fi

cd /root
rm -rf zapm-0.8.3
tar -zxvf /var/local/packages/zapm-083-src.tgz
patch < /usr/local/tournament/zapm.diff
perl -pi -e 's/ZAPMOWNER\=\ appowner/ZAPMOWNER\=\ nethack/g;' zapm-0.8.3/Makefile
perl -pi -e 's/GAMEDIR\=\ \"\/usr\/games\"/GAMEDIR\=\ \"\/usr\/local\/lib\/nethackdir\-3\.4\.3\"/g;' zapm-0.8.3/Makefile
perl -pi -e 's/DATADIR\=\ \"\/usr\/games\/lib\/zapmdir\"/DATADIR\=\ \"\/usr\/local\/lib\/nethackdir\-3\.4\.3\/zapmdir\"/g;' zapm-0.8.3/Makefile
cd zapm-0.8.3
gmake install

cd /usr/local/lib/nethackdir-3.4.3
chown -R nethack:nethack .
chmod ug+s nethack
chmod u+w save
chmod ug+w logfile record xlogfile

chown -R nhadmin:nhadmin tournament

chmod +x tournament/bin/*.pl
chmod +x tournament/bin/nethack.*
chgrp nhplayer save
chmod g+s save
chmod u+s zapm
chgrp nhplayer zapmdir
chmod g+ws zapmdir

cd tournament
chgrp nhplayer gamefiles
chmod g+ws gamefiles
chmod g+ws temp
chgrp nhplayer challenge
chmod g+ws challenge
chmod g+ws temp

cd /root
rm -rf shellinabox-svn239-a

tar -zxvf /var/local/packages/tilehack-shellinabox-svn239a.tgz
cd ~/shellinabox-svn239-a
./configure ; gmake ; gmake install

MTERM=`grep -c 'tilehack' /usr/share/misc/termcap`
if [ "0" == "$MTERM" ] ; then
  perl -pi -e 's/######## TERMINAL TYPE DESCRIPTIONS SOURCE FILE/tilehack|tilehack terminal emulator:\\\n\t:tc=xterm-r6:\n\n######## TERMINAL TYPE DESCRIPTIONS SOURCE FILE/' /usr/share/misc/termcap
  sleep 5
  touch /usr/share/misc/termcap
fi

ETERM=`grep -c 'tilehack' /etc/termcap`
if [ "0" == "$ETERM" ] ; then
  tic -o /usr/share/terminfo /etc/termcap
fi

mkdir -p /usr/share/terminfo/x
mkdir -p /usr/local/share/terminfo/x
cp misc/xterm.terminfo /usr/share/terminfo/x/xterm
cp misc/xterm.terminfo /usr/local/share/terminfo/x/xterm
TERMINFO=/usr/share/terminfo tic -x misc/xterm.terminfo
TERMINFO=/usr/local/share/terminfo tic -x misc/xterm.terminfo

mkdir -p /usr/share/terminfo/t
mkdir -p /usr/local/share/terminfo/t
cp misc/tilehack.terminfo /usr/share/terminfo/t/tilehack
cp misc/tilehack.terminfo /usr/local/share/terminfo/t/tilehack
TERMINFO=/usr/share/terminfo tic -x misc/tilehack.terminfo
TERMINFO=/usr/local/share/terminfo tic -x misc/tilehack.terminfo

touch /tmp/death.txt
chown nhadmin:nhplayer /tmp/death.txt
chmod g+w /tmp/death.txt
