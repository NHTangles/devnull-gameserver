#!/usr/bin/perl

@day_text =
(
	"discard",
	"Sun",
	"Mon",
	"Tue",
	"Wed",
	"Thu",
	"Fri",
	"Sat"
);

@day_text_long =
(
	"discard",
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturdat"
);

@month_text =
(
	"discard",
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec"
);

@month_text_long =
(
	"discard",
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
);

#(49, 52, 22, 27, 1, 100, 0, 57, 0)
($second, $minute, $hour, $mday, $month, $year, $wday, $yday, $isdst) = localtime(time);
$year = ($year + 1900);
$month = ($month + 1);
$wday = ($wday + 1);
$tomorrow = ($mday + 1);

if(10 > $month)
{
        $month = sprintf("0%d", $month);
}
if(10 > $mday)
{
        $mday = sprintf("0%d", $mday);
}
if(10 > $hour)
{
        $hour = sprintf("0%d", $hour);
}
if(10 > $minute)
{
        $minute = sprintf("0%d", $minute);
}
if(10 > $second)
{
        $second = sprintf("0%d", $second);
}

$date = "$year-$month-$mday";
$time = "$hour-$minute-$second";
$stamp = "$date-$time";

$timestamp = "$year$month$mday$hour$minute$second";

return(1);
