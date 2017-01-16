#!/usr/bin/perl

# This script runs the other scripts that need to be run on a schedule on
# a Tournament game server

# First read in /etc/passwd to ID tournament_home
open(PASS,"</etc/passwd") || die "ERROR: Could not open /etc/passwd.\n";
while($line=<PASS>)
{
	@fields=split /:/, $line;
		
	if("nhadmin" eq $fields[0])
	{
		$tournament_home = $fields[5];
	}
}
close(PASS);

#die if we couldn't find NETHACKHOME
if("" eq $tournament_home)
{
	die "ERROR: Could not identify NETHACKHOME.\n";
}

# Require the conf file
if (!require "$tournament_home/conf/nethack_tournament.conf")
{
	print "ERROR: require of $tournament_home/conf/nethack_tournament.conf failed.\n";
	exit;
}

$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;

# Synchronize users
system("$tournament_home/bin/synch_users.pl");

# Synchronize preferences
system("$tournament_home/bin/synch_prefs.pl");

# remove ZAPM debug files
$are_debugs = 0;
opendir(ZAPMDIR, "$nethackdir/zapmdir");
while($line=readdir(ZAPMDIR))
{
	if($line =~ /^dbg\./)
	{
		$are_debugs ++;
	}
}
closedir(ZAPMDIR);

if($are_debugs)
{
	system("/bin/rm $nethackdir/zapmdir/dbg.*");
}

#re-start the IRC relay, if it's not running
#$nhlog = "$nethackdir/xlogfile";
#
#if('' eq $irc_relay)
#{
#	$irc_relay = 'devnull.unfoog.de';
#}

system("/bin/rm $nethackdir/record_lock");

system("/bin/rm $nethackdir/logfile_lock");

if(-f "/usr/local/bin/shellinaboxd")
{
	system("cd $tournament_home ; $tournament_home/bin/shellinaboxd.sh &");
}

system("/bin/chown nhadmin:nhadmin $tournament_home/bin/*");
system("/bin/chmod 775 $tournament_home/bin/*");
