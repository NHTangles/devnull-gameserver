#!/usr/bin/perl

# this script is used to record a NetHack game for later playback

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

# Require the include.pl subroutine library

require "$tournament_home/include/generic/include.pl";

($name,$passwd,$uid,$gid,$quota,$comment,$gcos,$home_dir,$shell)=getpwuid($<);

# Read in the game session

$gamefile = "$tournament_home/gamefiles/$name.$stamp";

$| = 1;
while(read(STDIN, $char, 1))
{
	$game .= $char;
	print STDOUT $char;
}

open(GAME, ">>$gamefile") || die "Could not open game playback file \"$player_home/$name/gametemp\": $1";
print GAME $game;
close(GAME);

system("chmod g+w $tournament_home/gamefiles/$name.$stamp");

print "Thank you for recording your gaming session.\nThe stored file for that session is \"$name.$stamp\", should you care to publish it for others' entertainment.\n\n";
