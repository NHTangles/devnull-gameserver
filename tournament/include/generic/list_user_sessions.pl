# This file defines a subroutine called list_user_sessions. When 
# passed a username, it returns an array containing the pids of 
# all processes owned by that user which contain the string 'nethack'.

# Arguments:
#	1 - username
#	2 - string to match in command line field of ps results

return 1;

sub list_nethack_sessions {
	my $username=$_[0];
	my $string='nethack|zapm';
	my @processes;
	my %NETHACK_PIDS;
	my $cmd;
	my $terminal;
	my $ppid;
	my $match;
	my $nethack_pid;
	my $user_pid;
	$cmd="ps -caj";
	open (PS,"$cmd|") || return 0;
	while ($line=<PS>) {
		next if $line !~ /\s+$string\s*$/;
		chomp $line;
		$line =~ m/^\s*(\S+\s+){8}(\S+)\s+/;
		$terminal=$1;
		$line =~ m/^\s*(\S+\s+){3}(\S+)\s+/;
		$ppid=$1;
		$line =~ m/^\s*(\S+\s+){2}(\S+)\s+/;
		$line=$1;
		$terminal =~ s/\s//g;
		$ppid =~ s/\s//g;
		$NETHACK_PIDS{$line}{'terminal'}=$terminal;
		$NETHACK_PIDS{$line}{'ppid'}=$ppid;
	}
	close PS;
	$cmd="ps -U $username";
        open (PS,"$cmd|") || return 0;
        while ($line=<PS>) {
		$line =~ m/^\s*(\S+)/;
		$user_pid=$1;
		$line =~ m/^\s*\S+\s+(\S+)/;
		$terminal=$1;
		INNER: foreach $nethack_pid (keys %NETHACK_PIDS) {
			next INNER if ($user_pid ne $NETHACK_PIDS{$nethack_pid}{'ppid'});
			next INNER if ($terminal ne $NETHACK_PIDS{$nethack_pid}{'terminal'});
			$match=1;
			push @processes, $nethack_pid;
		}
	}
	close PS;
	return @processes; 
}

sub list_logout_sessions {
        my $username=$_[0];
	my $string='nethack.logout';
        my @processes;   
        my $cmd;
        $cmd="ps -U $username";
        open (PS,"$cmd|") || return 0;
        while ($line=<PS>) {
                next if $line !~ /$string\s*$/;
		chomp $line;
                $line =~ s/(^\s*\S+).+/$1/;
                push @processes, $line;
        }
        close PS;
        return @processes;
}
