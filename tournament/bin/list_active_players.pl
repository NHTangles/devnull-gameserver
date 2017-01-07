#!/usr/bin/perl

# This script prints out a list if all the currently logged in players
# to STDOUT

# First read in /etc/passwd so we can look up UID numbers...
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

# First off, we find nethackdir from the nethack executable script.
# Note that this script has to be in the tournament user's path.

#die if we couldn't find NETHACKHOME
if("" eq $tournament_home)
{
        die "ERROR: Could not identify NETHACKHOME.\n";
}

# Require the conf file
if (!require "$tournament_home/conf/nethack_tournament.conf")
{
        print "ERROR: require of $tournament_home/conf/nethack_tournament.conf";
        exit;
}

$nethackdir = `grep '^HACKDIR' $nethacklaunch`;
$nethackdir =~ s/^.+=//;
chomp $nethackdir;

# Require the include.pl subroutine library

require "$tournament_home/include/generic/include.pl";

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


# If the require succeeds, that means we have valid paths to the above, 
# and that we can get on with it....

$cmd='/usr/bin/who';

open (WHO,"$cmd|") || die "ERROR: Could not open \"$cmd\".\n";
while ($line=<WHO>) {
	next if $line =~ /^\#/;
	@line = split /\s+/, $line;
	push @users, $line[0];
}

foreach $user (@users) {
	if (defined $PLAYER{$user}) {
                next if defined $PRINTED{$user};
                print "$user\n";  
                $PRINTED{$user}=1;
        }
}

close WHO;

exit;
