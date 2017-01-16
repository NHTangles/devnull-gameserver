#!/usr/bin/perl

# This script logs a victory in the ZAPM Challenge

print "Registering your victory in the Challenge, ";

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

undef($ENV{'PATH'});

$player_name = $ARGV[0];

#have to work around variable tainting
$tournament_home =~ m/(.*)/;
$tournament_home = $1;
$player_name =~ m/(.*)/;
$player_name = $1;

print "$player_name.\r\n";
print "It may take up to 10 minutes to propagate the news of your success.\r\n";

if(0 != system('/usr/bin/touch ' . $tournament_home . '/challenge/ZAPM-' . $player_name . '-success'))
{
	print "ERROR: could not log Challenge success: $!\r\n";
}

sleep(5);
print "\e[2J\e[H";
