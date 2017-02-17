#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use Digest::MD5 qw(md5_hex);

#Require config 
require 'config.pl';

#Uses files to keep a viewercount. This is totally not scalable. 
#A switch to redis would do wonders but who really cares right now tbh
my $cgi = new CGI;
my $viewerid = "";
my $viewercount = 0;

#Check if the request contains a viewerid, under the VIEWERID query parameter.
if ($cgi->param('VIEWERID') && $cgi->param('VIEWERID') != "")
    { $viewerid = $cgi->param('VIEWERID'); }
else
    { $viewerid = md5_hex(time); }

#Create file for this viewer session in data folder
my $filepath = &get_datadir()."/".$viewerid.".camsession";

# Use the open() function to create the file.
unless(open FILE, '>'.$filepath) {
    # Die with error message 
    # if we can't open it.
    die "\nUnable to create sessionfile $filepath\n";
}

print FILE "Session file for Material Webcam viewer. Hello! 👌👺\n";

# close the file.
close FILE;

### Now, we get the total current viewer count.
#Parse all session files to build viewercount : files older than 60 seconds are deleted
my $sessionpath = &get_datadir()."/*.camsession";
my @files = glob $sessionpath; #Array of camsession files

for (0..$#files){
    my $sessionlife = time - (stat($files[$_]))[9]; #current time - last modified time of the session file

    if ( $sessionlife < 30 ) #TTL of viewer sessions is set to 30 seconds.
        { $viewercount++; }
    else
        { unlink($files[$_]); } #Remove old sessions
}

#Return all the data in a neat json package.
print header('application/json');

print qq({
		   "viewers": "$viewercount",
		   "vid": "$viewerid"
		}); 
