#!/usr/bin/env perl 

use warnings;
#use strict;

use SVG;
use Date::Parse;
use DateTime;

# configuration, such as it is
my $daystart="17:00";

# couple ideas here:
# see translation in svg: http://www.w3.org/TR/SVG/coords.html
# - can put x and y coordinates and labels on outter coordinate system
# - can put events on an inner translated system

my @events = {};
# events will have N parts (day, start, stop, color)

# we are processing logs after the fact, so entries should all be before this one
my $firstday = DateTime->now( time_zone => 'local' )->set_time_zone('floating');
my $lastday = DateTime->from_epoch(epoch=> 0);

while (<>) {
	($start,$end,$duration,$activity,$quantity,$unit,$desc,$notes,$annoter) = split(/,/);
	# so, notinally pretty simple: just draw a box for each event.  Sleep
	# for one hour? draw an hour-long box.  
	# - but, discard records we don't care about
	# - how tall should the box be? depends on how many days we are logging
	# - oh yeah, how many days are we logging?  might assume sorted input
	#   for starters.  not much here so a "first" and "last" would be fine
	#
	# - since i don't care about the order the boxes are printed, use a
	# hash whose keys are days and whose values are arrays of entries

	# strptime did not like way date was formatted
	@time = split(/[:\/ ]/, $start);
	next if (@time != 5);
	($month,$day,$year,$hh,$mm) = @time;

	$date = DateTime->new(
		year      => $year,
		month     => $month,
		day       => $day,
		hour      => $hh,
		minute    => $mm,
		time_zone => 'floating');
	if ((DateTime->compare($date,$firstday)) == -1) {
		$firstday = $date;
	}
	if ((DateTime->compare($date, $lastday)) == 1) {
		$lastday = $date;
	}

	# since i eventually want to start the plot for a day at 5pm, i may
	# want to look not just at days but at hours and minutes too: 
	# my $ndays = $date->subtract_datetime_absolute($firstday)->delta_seconds / (24*60*60);
	my $ndays = $date->delta_days($firstday)->delta_days;;
	print "$ndays\n";

	if ($activity eq '"Sleep"') {
		# easier to read if days start at 5pm.
	}
}

print "$firstday\n";
print "$lastday\n";

