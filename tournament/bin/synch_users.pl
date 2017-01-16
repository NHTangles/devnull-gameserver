#!/usr/bin/perl

# This script takes the (updated by other means) player list provided by the control
# server and synchronises the local game server's player accounts to it

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

# First off, we find nethackdir from the nethack executable script.

$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;

# Require the include.pl subroutine library
require "$tournament_home/include/generic/include.pl";
# If the require succeeds, that means we have valid paths to the above,
# and that we can get on with it....

# Sync specific variables
$errors = 0;
$nhhome = "";
$cmd_add = "";
$cmd_delete = "";
$file_players = "$tournament_home/conf/player_list.txt";
$cmd_rm = "/bin/rm $file_players";
$log = "$tournament_home/logs/synch_users.log";
$create_queue = "$tournament_home/logs/synch_users_createqueue";
$delete_queue = "$tournament_home/logs/synch_users_delete.queue";

#log our start
open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
print LOG "$stamp: starting synch run\n";
close(LOG);

# read in /etc/passwd so we can look up UID numbers...
open(PASS,"</etc/passwd") || die "ERROR: Could not open /etc/passwd.\n";
while($line=<PASS>)
{
	@fields=split /:/, $line;
	if(($fields[2] >= $player_uid_min) && ($fields[2] <= $player_uid_max))
	{
		$PLAYER{$fields[0]} = $fields[2];
		$UIDS{$fields[2]} = $fields[0];
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

if(-e "$file_players")
{
	# Read in the control server's player transaction list
	open (PLAYERS,"<$file_players") || die "ERROR: Could not open $file_players.\n";
	while ($line=<PLAYERS>)
	{
		$line =~ s/\n$//;
		@fields=split /\t/, $line;
		if(("" ne $fields[0]) && ("" ne $fields[1]))
		{
			$PLAYER_MASTER{$fields[1]} = $fields[2];
		}
		
		if(("A" eq $fields[0]) || ("a" eq $fields[0]))
		{
			$PLAYER_ADD{$fields[1]} = $fields[2];
		}
		elsif(("D" eq $fields[0]) || ("d" eq $fields[0]))
		{
			$PLAYER_DELETE{$fields[1]} = $fields[0];
		}
		else
		{
			die "ERROR: Unknown command \"$fields[0]\".\n";
		}
	}
	close PLAYERS;
	
	# add new players
	foreach $thing (sort(keys(%PLAYER_ADD)))
	{
		if(&include("player_add.pl"))
		{
			&player_add($thing);
		}
		else
		{
			die "ERROR: Could not load an appropriate player_add.\n";
		}
	}
	
	# remove outdated players
	foreach $thing (sort(keys(%PLAYER_DELETE)))
	{
		if(&include("player_delete.pl"))
		{
			&player_delete($thing);
		}
		else
		{
			die "ERROR: Could not load an appropriate player_delete.\n";
		}
	}
	
	if(0 == system "$cmd_rm")
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: removed transaction file\n";
		close(LOG);
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR removing transaction file\n";
		close(LOG);
		$errors ++;

		system("/bin/chgrp nhadmin $file_players");
		system("/bin/chmod g+w $file_players");
	}
}
else
{
	open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
	print LOG "$stamp: nothing to do\n";
	close(LOG);
}

#log our finish
open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
print LOG "$stamp: ending synch run ($errors errors)\n";
close(LOG);
