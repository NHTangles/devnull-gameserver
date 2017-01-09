#!/usr/bin/perl

# This script is used as the login shell of the tournament user 
# accounts. 

# First read in /etc/passwd so we can look up UID numbers...
open(PASS,"</etc/passwd") || die "ERROR: Could not open /etc/passwd.\n";
while($line=<PASS>)
{
	@fields=split /:/, $line;
	if(($fields[2] >= $player_uid_min) && ($fields[2] <= $player_uid_max))
	{
		$PLAYER{$fields[0]} = $fields[2];
	}
	else
	{
		$NON_PLAYER{$fields[0]} = "IGNORE";
	}
	
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

# First off, we find nethackdir from the nethack executable script.
# Note that this script has to be in the tournament user's path.

$nethack=$nethacklaunch;
$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;
$zapm = "$nethackdir/zapm";

# Require the include.pl subroutine library

require "$tournament_home/include/generic/include.pl";

# and other dependencies...

&include("set_times.pl");
&include("list_user_sessions.pl");
&include("backup_save_file.pl");

# If the require succeeds, that means we have valid paths to the above, 
# and that we can get on with it....

system "clear";

($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$home_dir,$shell)=getpwuid($<);

# make sure server is up, otherwise give downtime message.

if(($testacct ne $name) && ('wizard' ne $name) && ('nhadmin' ne $name))
{
  &down if ($status ne 'up');
}

if(-e "$tournament_home/message/pre-tournament")
{
	if(($testacct ne $name) && ('wizard' ne $name) && ('nhadmin' ne $name))
	{
		open(MESSAGE, "<$tournament_home/message/pre-tournament");
		while($line = <MESSAGE>)
		{
			print $line;
		}
		close(MESSAGE);
		exit(0);
	}
}

if(-e "$tournament_home/message/post-tournament")
{
	if(($testacct ne $name) && ('wizard' ne $name) && ('nhadmin' ne $name))
	{
		open(MESSAGE, "<$tournament_home/message/post-tournament");
		while($line = <MESSAGE>)
		{
			print $line;
		}
		close(MESSAGE);
		exit(0);
	}
}

# Read the player's Tournament Options
if(-e "$player_home/$name/.tournamentrc")
{
	$tournamentrc{'tournamentrc'} = 1;
	
	open (FILE,"<$player_home/$name/.tournamentrc");
	while ($line=<FILE>)
	{
		$line =~ s/\n$//;
		$line =~ s/OPTIONS\=//;
		@templine = split(/\,/, $line);
		foreach $thing (sort(@templine))
		{
			if("t_record" eq $thing)
			{
				$tournamentrc{'t_record'} = 1;
				
				$nethack = "$nethack | $tournament_home/bin/recordnethack.pl";
			}
			elsif("!t_record" eq $thing)
			{
				$tournamentrc{'t_record'} = 0;
			}
		}
	}
	close FILE;
}
else
{
	$tournamentrc{'tournamentrc'} = 0;
	$tournamentrc{'t_record'} = 0;
}

#check for ZAPM Challenge

print "\n\nWelcome, $name, to the NetHack Tournament $year\n\n";

$offer_zapm = 0;
# For testing:
# ZAPM-$name-practise allows ZAPM to be offered to players without
# affecting wishing in nethack.  This cannot be created by the player
# so is only by invitation of the admin.
if((-e "$tournament_home/challenge/ZAPM-$name-accept"
	|| glob("$tournament_home/challenge/ZAPM-$name-practi[cs]e"))
	&& (!-e "$tournament_home/challenge/ZAPM-$name-ignore"))
{
	$offer_zapm = 1;
}

$go_zapm = 0;

if($offer_zapm)
{
	print "You have accepted the ZAPM Challenge this year;\n";
	print "would you like to proceed into ZAPM rather than NetHack? (y/n)  ";
	$junk=<STDIN>;
	if ($junk =~ /^y/i)
	{
		print "ZAPM help can be obtained by pressing the '?' key\n";
		print "during a game session\n\n";
		print "PLEASE NOTE: you will need to adjust your terminal resolution\n";
		print "to 80x25 to accomodate ZAPM's interface.\n\n";

		$go_zapm = 1;
	}
}

if(!$go_zapm)
{
	print "NetHack help can be obtained by pressing the '?' key\n";
	print "during a game session\n\n";
}

if($tournamentrc{'t_record'})
{
	print "This session will be recorded for posterity; after the session you will be given a playback file identifier by which you can refer to it from the /dev/null/nethack site.\n\n";
}

if (-e "$tournament_home/message/login") {
	open (FILE,"<$tournament_home/message/login");
	while ($line=<FILE>) {
		print $line;
	}
	close FILE;
}

&backup_save_file($name);

$|=1;

# Check for active game and logout processes

@nh_pids=&list_nethack_sessions($name);

# Kill off game sessions

foreach $pid (@nh_pids) {
	print "\nActive game detected. Attempting to save.";
	system("kill -HUP $pid");
	for $i (1..5) {
		sleep 1;
		print "."  
	}
	@resist_pids=&list_nethack_sessions($name);
	foreach $remnant (@resist_pids) {
		$resist=1 if $remnant=$pid;
	}
	if ($resist) {
		print "Failed.\n";
		print "Could not save active game. If you log in now you will\n";
		print "not be able to restore the old game later. It will be lost\n";
		print "Would you like to log in anyway?  (y/n)";
		$answer=<STDIN>;
		if ($answer=~/^y/i) {
			print "\nOkay, it's your game...\n";
			system "kill -TERM $pid";
			if (-e "$tournament_home/logs/zombie_pids.log") {
				open(LOG,">>$tournament_home/logs/zombie_pids.log");
				print LOG "user $name TERMed process $pid: $stamp\n";
				close LOG;
			}
		} else {
			print "\nOkay. This event has been logged, and the server admins will try\n";
			print "to do something about it. To make sure, though, you should pester\n";
			print "them. Send an email to: $admin_email\n";
			print "Press <Return> to exit.\nSorry for the inconvenience\n--more--\n";
			$junk=<STDIN>;
			if (-e "$tournament_home/logs/zombie_pids.log") {
                                open(LOG,">>$tournament_home/logs/zombie_pids.log");
				print LOG "user $name TERMed process $pid: $stamp\n";
				close LOG;
			}
			$exit=1;
		}	
	} else {
		print "Game saved.\n";
		&backup_save_file($name);
	}
}

@lo_pids=&list_logout_sessions($name);
$resist=0;
foreach $pid (@lo_pids) {
	system "kill -TERM $pid";
	@resist_pids=&list_logout_sessions($name,"nethack");
        foreach $remnant (@resist_pids) {
                $resist=1 if $remnant=$pid;
        }
	if ($resist) {
		if (-e "$tournament_home/logs/zombie_pids.log") {
			open(LOG,">>$tournament_home/logs/zombie_pids.log");
			print LOG "user $name has a zombie process $pid: $stamp\n";
			close LOG;
		}
	}
}

$|=0;
print "\nPress <Return> to begin.\nHappy gaming!\n";
print "--More--";
$junk=<STDIN>;

system "clear";
if($go_zapm)
{
	exec("$zapm; $tournament_home/bin/nethack.logout");
}
else
{
	if('nhadmin' ne $name)
	{
		exec("$nethack; $tournament_home/bin/nethack.logout");
	}
	else
	{
		exec("$nethack -D; $tournament_home/bin/nethack.logout");
	}
}

sub down {
	print "This server is currently unavailable\n\n";
	system "cat $tournament_home/message/down";
	print "\n";
	$|=0;
	print "\nPress <Return> to exit.\n";
	print "--Bye--";
	$junk=<STDIN>;
	exit;
}
