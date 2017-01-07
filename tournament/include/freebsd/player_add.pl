#!/usr/bin/perl

# This library deletes the argument as a NetHack player to a FreeBSD system
# it depends on the array environment set up in synch_users.pl

# pw [-n name]
#    [-g group]
#    [-u uid]
#    [-s shell]
#    [-h password_fd]
#    [-c comment]
#    [-b basehome_dir]

use Fcntl;	# For the flags passed to sysopen

sub player_add
{
	$uid = $player_uid_min;
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

	$player = $_[0];

	if(0 != $uid)
	{
	        $password = $PLAYER_ADD{$player};

		# Create file with the password for piping to pw.
		my $passdatafile = "/tmp/passdata";
		sysopen(DATA, $passdatafile, O_WRONLY|O_TRUNC|O_CREAT, 0600)
			or die $!;
		print DATA $password."\n";
		print DATA $password."\n";
		close (DATA);

		$cmd_add = "cat $passdatafile | /usr/sbin/pw useradd -c \"DevNull NetHack Player\" -g nhplayer -m -h 0 -s $tournament_home/bin/nethack.login -u $uid -n \"$player\" -b $tournament_home/players";
		
		if(0 == system "$cmd_add")
		{
			$UIDS{$uid} = "$player";
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

		# For our player's sake
		system "rm $passdatafile";
		if(0 == system "/usr/bin/chgrp nhadmin $tournament_home/players/$player")
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
	else
	{
		open(LOG,">>$log") || die "ERROR: Could not open $log.\n";
		print LOG "$stamp: ERROR creating new player \"$player\" (no open UIDs)\n";
		close(LOG);
		$errors ++;
	}
	
}

# because this is what Perl libraries do
return 1;

