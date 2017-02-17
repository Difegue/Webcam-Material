#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use Template;
use utf8;

#Require config 
require 'config.pl';

#Actual HTML output
my $cgi = new CGI;
my $tt  = Template->new({
    INCLUDE_PATH => "template",
    ENCODING => 'UTF-8' 
});

#We print the html we generated.
print $cgi->header(-type    => 'text/html',
               -charset => 'utf-8');

my $out;

$tt->process(
    "index.tmpl",
    {
        title => &get_camname(),
        datadir => &get_datadir(),
        audioenabled => &is_audioenabled(),
        color => &get_color()
    },
    \$out,
) or die $tt->error;

print $out;