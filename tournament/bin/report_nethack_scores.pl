#!/usr/bin/perl

# This one reads the nethack score file and prints it to stdout.
# No biggie, but necessary to build master score list.

# All the prelim stuff goes here...

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

if (!require "$tournament_home/conf/nethack_tournament.conf") {
        print "ERROR: require of $tournament_home/conf/nethack_tournament.conf failed.\n";
        exit;
}
$nethack = $nethacklaunch;
$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;

# Require the include.pl subroutine library

require "$tournament_home/include/generic/include.pl";

# Define the scores files...

$logfile="$nethackdir/logfile";

# And print it out...

if (open(LOG,"cat $logfile |")) {
	while ($line=<LOG>) {
		print $line;
	}
} else {
	print "ERROR: could not open $logfile\n";
}	
