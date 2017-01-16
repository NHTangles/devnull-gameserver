#!/usr/bin/perl

# This script prints out a list if all the currently logged in players
# to STDOUT

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

$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;

# Require the include.pl subroutine library

require "$tournament_home/include/generic/include.pl";

# If the require succeeds, that means we have valid paths to the above, 
# and that we can get on with it....

# First read in /etc/passwd so we can look up UID numbers...
open (PASS,"</etc/passwd") || die "ERROR: Could not open /etc/passwd.\n";
while ($line=<PASS>) {
        @fields=split /:/, $line;
        next if ($fields[2] < $player_uid_min || $fields[2] > $player_uid_max);
        $PLAYER{$fields[0]}=$fields[2];
	print $fields[0],"\n";
}
close PASS;

exit;

