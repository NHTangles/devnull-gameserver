#!/usr/bin/perl

# This library deletes the argument as a NetHack player from a Unix system
# it depends on the array environment set up in synch_users.pl

sub player_delete
{
	$player = $_[0];
	
	open(DELETE,">>$delete_queue") || die "ERROR: Could not open $delete_queue.\n";
	print DELETE "$stamp: DELETE issued for \"$player\"\n";
	close(DELETE);
}

# because this is what Perl libraries do
return 1;
