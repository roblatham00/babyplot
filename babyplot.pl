#!/usr/bin/env perl 

use warnings;

use SVG;
use Date::Parse;
use DateTime;

# configuration, such as it is
my $daystart="17:00";

# couple ideas here:
# see translation in svg: http://www.w3.org/TR/SVG/coords.html
# - can put x and y coordinates and labels on outter coordinate system
# - can put events on an inner translated system

my %days;

# we are processing logs after the fact, so entries should all be before this one
my $firstday = DateTime->now( time_zone => 'local' )->set_time_zone('floating');
my $lastday = DateTime->from_epoch(epoch=> 0);

while (<>) {
	($start,$end,$duration,$activity,$quantity,$unit,$desc,$notes,$annoter) = split(/,/);
	#print "$activity\n";
	# so, notinally pretty simple: just draw a box for each event.  Sleep
	# for one hour? draw an hour-long box.  
	# - but, discard records we don't care about
	# - how tall should the box be? depends on how many days we are logging
	# - oh yeah, how many days are we logging?  might assume sorted input
	#   for starters.  not much here so a "first" and "last" would be fine
	#
	# - since i don't care about the order the boxes are printed, use a
	# hash whose keys are days and whose values are arrays of entries
	#print "$start\n";
	#($ss,$mm,$hh,$day,$month,$year,$zone) = strptime($start) or next;
	# the year is getting messed up.  i guess strptime needs a little help.
	# not hard to go back to doing it by hand
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

	if ($activity eq '"Sleep"') {
		# easier to read if days start at 5pm.
	}
}

print "$firstday\n";
print "$lastday\n";

