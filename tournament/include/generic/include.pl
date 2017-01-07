# This subroutine, called from scripts in the bin directory,
# is passed the name of an include file. Based on the $os
# variable in the nethack_tournament.conf, it decides which
# version of the include file to actually require, if any.

return 1;

sub include {
	my $file = $_[0];
	defined ($tournament_home) || return 0;
	if (-e "$tournament_home/include/$os/$file") {
		require "$tournament_home/include/$os/$file";
		return 1;
	} elsif (-e "$tournament_home/include/generic/$file") {
		require "$tournament_home/include/generic/$file";
		return 1;
	} else {
		return 0;
	}
}
