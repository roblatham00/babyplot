#!/usr/bin/env perl 

use warnings;
#use strict;

use SVG;
use Date::Parse;
use DateTime;

# configuration, such as it is
my $daystart_hr = 17;
my $daystart_min = 0;

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
	@starttime = split(/[:\/ ]/, $start);
	next if (@starttime != 5);
	next if ($end eq "");  # things like dr visits and other
				  # zero-duration events cannot be reasonably
				  # plotted.
				  # XXX: i did want to plot diaper changes though...

	@endtime = split(/[:\/ ]/, $end);
	($month,$day,$year,$hh,$mm) = @starttime;

	$begin = DateTime->new(
		year      => $year,
		month     => $month,
		day       => $day,
		hour      => $hh,
		minute    => $mm,
		time_zone => 'floating');
	if ((DateTime->compare($begin,$firstday)) == -1) {
		# want to shift the plot so that a row (days) events start at 5pm
		# two cases: 
		# - event started after 5pm: round down to 5pm
		# - event started before 5pm: round up to 5pm, reduce day by one
		if ( ($begin->hour() >  $daystart_hr) or
			(($begin->hour() == $daystart_hr) and 
				$begin->min() > 0)) {
			$deltamin = $begin->min();
			$firstday = $begin->clone->
				set(hour=>$daystart_hr, 
					minute=>$daystart_min);
		} else {
			# back up a day
			$firstday = $begin->clone();
			$firstday->subtract(days=>1);
			$firstday->set(hour=>$daystart_hr, minute=>$daystart_min);
		}

	}
	if ((DateTime->compare($begin, $lastday)) == 1) {
		# don't really need to adjust the end. only capturing it so we
		# know how fat to make each day-row
		$lastday = $begin;
	}
	($month,$day,$year,$hh,$mm) = @endtime;
	$ending = DateTime->new(
		year      => $year,
		month     => $month,
		day       => $day,
		hour      => $hh,
		minute    => $mm,
		time_zone => 'floating');

	# since i eventually want to start the plot for a day at 5pm, i may
	# want to look not just at days but at hours and minutes too: 
	my $ndays = int($begin->subtract_datetime_absolute($firstday)->delta_seconds / (24*60*60));
	#my $ndays = $begin->delta_days($firstday)->delta_days;;

	if ($activity eq '"Sleep"') {
		print "===$_";
		$data->{"start"} = 10;
		$data->{"end"} = $duration;
		$data->{"day"} = $ndays;
		$data->{"color"} = 'green';
		print $data;
		push @events, $data;
	}
}

my $count = @events;
print "found $count events\n";

foreach $item (@events)
{
	# $item is a *hash reference*
	print "$item  ";
	print "Sleep from $item->{'start'} to $item->{'end'} on day $item->{'day'}\n";
}
