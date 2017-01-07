# Simple subroutine that copies a save file from the nethackdir to
# the player's home directory and timestamps the filename,

return 1;

sub backup_save_file {
    my $username=$_[0];

    $save_dir="$nethackdir/save/";
    opendir SAVEDIR, "$save_dir";
    while($line=readdir(SAVEDIR))
    {
	next if $line!~/^$uid\D/;
	chomp $line;
	$save_file_name=$line;
    }
    closedir SAVEDIR;
    if(-e "$nethackdir/save/$save_file_name" && $save_file_name)
    {
	$cmd="cp $nethackdir/save/$save_file_name $player_home/$username/$save_file_name-nethack-$stamp";
	if(system $cmd)
        {
	    print "There was an error backing up your save file. \n";
	    print "This event has been logged, but you should notify\n";
	    print "the server administrator ($admin_email) anyway\n\n";
	    open(LOG,">>$tournament_home/logs/backup_failures.log");
	    print LOG "$stamp: NetHack backup failed for user $username\n";
	    close LOG;
	    return 0;
	}
    }

    $save_dir="$nethackdir/zapmdir/";
    opendir SAVEDIR, "$save_dir";
    while($line=readdir(SAVEDIR))
    {
	next if $line!~/^$uid\D/;
	chomp $line;
	$save_file_name=$line;
    }
    closedir SAVEDIR;
    if(-e "$nethackdir/zapmdir/$save_file_name" && $save_file_name)
    {
	$cmd="cp $nethackdir/zapmdir/$save_file_name $player_home/$username/$save_file_name-zapm-$stamp";
	if (system $cmd) {
	    print "There was an error backing up your save file. \n";
	    print "This event has been logged, but you should notify\n";
	    print "the server administrator ($admin_email) anyway\n\n";
	    open(LOG,">>$tournament_home/logs/backup_failures.log");
	    print LOG "$stamp: ZAPM backup failed for user $username\n";
	    close LOG;
	    return 0;
	}
    }
    return 1;
}
	






