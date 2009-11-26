#!/usr/bin/perl

use strict;
use warnings;

use Net::Twitter;
use XML::RSS::Feed;
use XML::RSS::Headline::PerlJobs;
use LWP::Simple qw(get);
use WWW::Shorten 'Miudin';

our $VERSION = '0.1';

my ($username, $password) = @ARGV;

my $twitter_lenmax  = 140;
my $twitter_cutend  = '...';
my $feed_name       = 'perljobs';
my $feed_url        = 'http://jobs.perl.org/rss/standard.rss';
my $feed_hlobj      = 'XML::RSS::Headline::PerlJobs';

my $loop_status = 0;

my $feed = XML::RSS::Feed->new(
	name    => $feed_name,
	url     => $feed_url,
	hlobj   => $feed_hlobj
);

while (1) {
	$feed->parse(get($feed->url));
	if ($loop_status) {
		&do_twitter($_) for $feed->late_breaking_news;
	}
	sleep($feed->delay);
	$loop_status = 1;
}


sub do_twitter {
	my $feed = shift;

    my $headline = $feed->headline;
    my $slink = makeashorterlink($feed->url);
    
    my $lenmax = $twitter_lenmax - 
        (length($slink) + length($twitter_cutend));
    
    $headline = substr($headline, 0, $lenmax) . $twitter_cutend
        if length($headline) >= $lenmax;

    my $status = join(' ', $headline, $slink);
    my $twit = Net::Twitter->new({
        username => $username,
        password => $password
    });
	
	return $twit->update({status => $status });
}


