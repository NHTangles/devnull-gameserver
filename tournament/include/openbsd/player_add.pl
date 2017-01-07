#!/usr/bin/perl

# This library deletes the argument as a NetHack player to an OpenBSD system
# it depends on the array environment set up in synch_users.pl

#adduser	[-batch username [group[,group] ...] [fullname] [password]]
#				[-check_only] [-config_create] [-dotdir directory] [-e method |
#				-encrypt_method method] [-group login_group] [-h | -help | -?]
#				[-home partition] [-message file] [-noconfig] [-shell shell] [-s
#				| -silent | -q | -quiet] [-uid uid] [-uid_start uid] [-uid_end
#				uid] [-v | -verbose] [-unencrypted]

sub player_add
{
	$player = $_[0];
	$cmd_add = "/usr/sbin/adduser -batch $player nhplayer \"DevNull NetHack Player\" $PLAYER_ADD{$player} -group nhplayer -home $tournament_home/players -shell nethack.login -quiet -uid_start $player_uid_min -uid_end $player_uid_max -unencrypted";
	
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
	
	if(0 == system "/usr/sbin/chgrp nhadmin $tournament_home/players/$player")
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
	
	if(0 == system "/bin/chmod g+w $tournament_home/players/$player")
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
