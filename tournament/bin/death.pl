#!/usr/bin/perl

$death = $ARGV[0];
$death =~ s/\n$//g;

#print "Please hold; I'm reporting your game's conclusion ...\n";

use LWP;
use LWP::UserAgent;

$agent = LWP::UserAgent->new(agent => "/dev/null/nethack Death Reporter/0.1.8");
$agent->timeout(120);
push @{ $agent->requests_redirectable }, 'GET';

$response = $agent->get("https://nethack.devnull.net/cgi-bin/tournament/death.pl?death=$ARGV[0]&password=nA2GxxUv008687");

if($response->is_success)
{
	$session = $response->content;

	if('success' ne $session)
	{
		print "ERROR: bad page trying to report\n";
	}
}
else
{
	print "ERROR: no page trying to report\n";
}

#print "Thank you; come again.\n";

open(OUT, ">>/tmp/death.txt") || die("open() failed: $!");
{
	print OUT "$death\n";
}
close(OUT);

exit(0);
