#!/usr/bin/perl

# This script makes sure all the pref files in prefs/ are installed correctly
# in the various players' home directories

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

require "$tournament_home/include/generic/include.pl";
&include("find.pl");

&find("$tournament_home/prefs");

sub wanted
{
	my $file = $_;

	my $isvalid = 0;
	my $player = '';
	my $prefname = '';
	
	if(-f $file)
	{
		if($file =~ m/(.*)\.tournamentrc/)
		{
			$isvalid = 1;
			
			$prefname = '.tournamentrc';
			$player = $1;
		}
		elsif($file =~ m/(.*)\.nethackrc/)
		{
			$isvalid = 1;
			
			$prefname = '.nethackrc';
			$player = $1;
		}
		
		if($isvalid)
		{
			if(-e "$tournament_home/players/$player")
			{
				system("/bin/cp $tournament_home/prefs/$file $tournament_home/players/$player/$prefname");
				system("/bin/chown $player:nhplayer $tournament_home/players/$player/$prefname");
				system("/bin/chmod u=rw $tournament_home/players/$player/$prefname");
				system("/bin/chmod g=r $tournament_home/players/$player/$prefname");
				system("/bin/chmod o=r $tournament_home/players/$player/$prefname");
			}
		}
	}
}
