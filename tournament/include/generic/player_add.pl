#!/usr/bin/perl

# This library adds the argument as a NetHack player to a Unix system
# it depends on the array environment set up in synch_users.pl

sub player_add
{
	$player = $_[0];
	
	open(CREATE,">>$create_queue") || die "ERROR: Could not open $create_queue.\n";
	print CREATE "$stamp: CREATE issued for \"$player\" (\"$PLAYER_ADD{$player}\")\n";
	close(CREATE);
}

# because this is what Perl libraries do
return 1;
