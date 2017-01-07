#!/usr/bin/perl

# This library deletes the argument as a NetHack player to a Solaris system
# it depends on the array environment set up in synch_users.pl

#useradd	[-c comment] [-d home_dir]
#				[-e expire_date] [-f inactive_time]
#				[-g initial_group] [-G group[,...]]
#				[-m [-k skeleton_dir]] [-p passwd]
#				[-s shell] [-u uid [ -o]] login

sub player_add
{
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
		}
		else
		{
			$uid ++;
		}
	}
	
	#$passwd = $PLAYER_ADD{$player};
	#srand(time|$$);
	#$salt=rand(4095);
	#$passwd=crypt($passwd, $salt);
	
	if(0 != $uid)
	{
		$player = $_[0];
		$passwd = $PLAYER_ADD{$player};

		$cmd_add = "/usr/sbin/useradd -c \"DevNull NetHack Player\" -d $tournament_home/players/$player -g nhplayer -m -s $tournament_home/bin/nethack.login $player";
		
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
		$cmd_pass = "$tournament_home/include/$os/autopasswd $player $passwd";
		if(0 == system "$cmd_pass")
                {
                        open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
                        print LOG "$stamp: unlocked new player \"$player\"\n";
                        close(LOG);
                }
                else
                {
                        open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
                        print LOG "$stamp: ERROR unlocking new player \"$player\"\n";
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
	
	if(0 == system "/bin/chgrp nhadmin $tournament_home/players/$player")
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

