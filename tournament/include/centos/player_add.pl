#!/usr/bin/perl

# This library deletes the argument as a NetHack player to a Slackware system
# it depends on the array environment set up in synch_users.pl

#useradd	[-u uid [-o]] [-g group] [-G group,...] 
#		[-d home] [-s shell] [-c comment] [-m [-k template]]
#		[-f inactive] [-e expire ] [-p passwd] [-M] [-n] [-r] [-l] name

sub player_add
{
	$player = $_[0];
	$uid = $player_uid_min;
	$index = 0;
	$done = 0;
	while(!$done)
	{
		if($uid > $player_uid_max)
		{
			$uid = 0;
			$done = 1;
		}
		elsif("" eq $UIDS{$uid})
		{
			$done = 1;
			$PLAYER{$player} = $uid;
			$UIDS{$uid} = $player;

		}
		else
		{
			$uid ++;
		}
	}
	
	$passwd = $PLAYER_ADD{$player};
	srand(time|$$);
	$salt=rand(4095);
	$passwd=crypt($passwd, $salt);
	
	if(0 != $uid)
	{
		$cmd_add = "/usr/sbin/useradd -c \"DevNull NetHack Player\" -d $tournament_home/players/$player -g nhplayer -p $passwd -s $tournament_home/bin/nethack.login -u $uid $player";
		
		if(0 == system "$cmd_add")
		{
			open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
			print LOG "$stamp: created new player \"$player\"\n";
			close(LOG);
		}
		else
		{
			open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
			print LOG "$stamp: ERROR creating new player \"$player\"\n";
			close(LOG);
			$errors ++;
		}
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR creating new player \"$player\" (no open UIDs)\n";
		close(LOG);
		$errors ++;
	}
	
	if(0 == system "/bin/touch $tournament_home/players/$player/.nethackrc")
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: created .nethackrc for player \"$player\"\n";
		close(LOG);
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR creating .nethackrc for player \"$player\"\n";
		close(LOG);
		$errors ++;
	}

	if(0 == system "/bin/touch $tournament_home/players/$player/.tournamentrc")
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: created .tournamentrc for player \"$player\"\n";
		close(LOG);
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR creating .tournamentrc for player \"$player\"\n";
		close(LOG);
		$errors ++;
	}
	
	if(0 == system "/bin/chgrp -R nhadmin $tournament_home/players/$player")
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: set dir group for player \"$player\"\n";
		close(LOG);
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR setting dir group for player \"$player\"\n";
		close(LOG);
		$errors ++;
	}

	#if(0 == system "/bin/chmod g+w $tournament_home/players/$player")
	if(0 == system "/bin/chmod -R 775 $tournament_home/players/$player")
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: set dir privs for player \"$player\"\n";
		close(LOG);
	}
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR setting dir privs for player \"$player\"\n";
		close(LOG);
		$errors ++;
	}
}

# because this is what Perl libraries do
return 1;

