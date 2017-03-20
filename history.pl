#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use HTML::Scrubber;
use open ':encoding(utf8)';
use File::ReadBackwards;

#Require config 
require 'config.pl';

my $qhistory = new CGI;

if ($qhistory->param('messages')) 
{
	binmode(STDOUT, ":utf8");

	#print header('text/plain');
	print header (-charset => 'UTF-8',
			-type => 'text/plain');

	my $out;

	unless ($qhistory->param('html'))
	{ $out .= "[";}

	my $datadir = &get_datadir();

	my $bw = File::ReadBackwards->new("$datadir/logcam.txt");

	my $num = ($qhistory->param('messages'));

	my $scrubber = HTML::Scrubber->new;
	$scrubber->default(0); ## default to no HTML

	my @lines;
	my $log_line;

	for (my $i = 0; $i < $num; $i++) 
	{
		if (defined ($log_line = $bw->readline))
		{
			push (@lines, $scrubber->scrub($log_line));
		}
		else
		{
			last; #this means break in not-perl
		}
	}

	#my $log = `tail $datadir/logcam.txt`;	
	#my $clean_html = $scrubber->scrub($log);
	#my @lines = split /\n/, $clean_html;

	#line syntax : [name] - [message] : names don't have dashes due to being ldap usernames, so this is fine(tm)
	foreach my $line (@lines) 
	{
		my @words = split /-/, $line, 2;
		chomp(@words[1]); #removes newline

		if ($qhistory->param('html'))
		{ $out .= qq(<span class="red-text text-darken-2">@words[0] </span>: @words[1]<br/>);}
		else
		{ 
			$out.= qq({
					   "author": "@words[0]",
					   "message": "@words[1]"
					},); 
		}
	}



	unless ($qhistory->param('html'))
	{ 
		#strip last comma and close array
		chop($out);
		$out.= "]";
	}

	print $out;
}



