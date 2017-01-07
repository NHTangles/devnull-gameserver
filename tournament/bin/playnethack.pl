#!/usr/bin/perl

$gamefile = $ARGV[0];

$delay_short = .01;
$delay_mid = .1;
$delay_long = .5;

$| = 1;
open(GAME, "<$gamefile");
while(read(GAME, $char, 1))
{
	if(chr(27) eq $char)
	{
		#it's an escape sequence of some sort
		
		read(GAME, $char1, 1);
		read(GAME, $char2, 1);
		
		if(("[" == $char1) && ($char2 =~ /\d/))
		{
			#cursor positioning?

			print STDOUT $char;
			print STDOUT $char1;
			print STDOUT $char2;
			
			$done = 0;
			while(!$done)
			{
				read(GAME, $charx, 1);
				if("H" == $charx)
				{
					$done = 1;
				}
				
				print STDOUT $charx;
			}
		}
		else
		{
			#other

			print STDOUT $char;
			print STDOUT $char1;
			print STDOUT $char2;
		}
	}
	elsif("\@" eq $char)
	{
		#it's the player moving on the screen, short-delay
		
		select undef, undef, undef, $delay_mid;
		print STDOUT $char;
	}
	elsif($char =~ /\w|\d/)
	{
		#it's a letter or number
		
		select undef, undef, undef, $delay_short;
		print STDOUT $char;
	}
	elsif("\-" eq $char)
	{
		#it _could be a "--More--"
		
		read(GAME, $char1, 1);
		if("\-" eq $char1)
		{
			read(GAME, $char2, 1);
			if("M" eq $char2)
			{
				read(GAME, $char3, 1);
				if("o" eq $char3)
				{
					read(GAME, $char4, 1);
					if("r" eq $char4)
					{
						read(GAME, $char5, 1);
						if("e" eq $char5)
						{
							read(GAME, $char6, 1);
							if("\-" eq $char6)
							{
								read(GAME, $char7, 1);
								if("\-" eq $char7)
								{
									#it's a "--More--"
									
									print STDOUT $char;
									print STDOUT $char1;
									print STDOUT $char2;
									print STDOUT $char3;
									print STDOUT $char4;
									print STDOUT $char5;
									print STDOUT $char6;
									print STDOUT $char7;
									
									select undef, undef, undef, $delay_long;
								}
								else
								{
									print STDOUT $char;
									print STDOUT $char1;
									print STDOUT $char2;
									print STDOUT $char3;
									print STDOUT $char4;
									print STDOUT $char5;
									print STDOUT $char6;
									print STDOUT $char7;
								}
							}
							else
							{
								print STDOUT $char;
								print STDOUT $char1;
								print STDOUT $char2;
								print STDOUT $char3;
								print STDOUT $char4;
								print STDOUT $char5;
								print STDOUT $char6;
							}
						}
						else
						{
							print STDOUT $char;
							print STDOUT $char1;
							print STDOUT $char2;
							print STDOUT $char3;
							print STDOUT $char4;
							print STDOUT $char5;
						}
					}
					else
					{
						print STDOUT $char;
						print STDOUT $char1;
						print STDOUT $char2;
						print STDOUT $char3;
						print STDOUT $char4;
					}
				}
				else
				{
					print STDOUT $char;
					print STDOUT $char1;
					print STDOUT $char2;
					print STDOUT $char3;
				}
			}
			else
			{
				print STDOUT $char;
				print STDOUT $char1;
				print STDOUT $char2;
			}
		}
		else
		{
			print STDOUT $char;
			print STDOUT $char1;
		}
	}
	else
	{
		#ignore it and print immediately
		
		print STDOUT $char;
	}
}
close(GAME);
