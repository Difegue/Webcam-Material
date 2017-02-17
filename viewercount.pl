#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use Digest::MD5;

#Require config 
require 'config.pl';

#Uses CGI::Session to keep a viewercount.
my $cgi = new CGI;

#Using the cgi object during session creation will automatically use the CGISESSID query parameter if it exists.
# ==> no new session created if CGISESSID matches.
my $session = new CGI::Session("driver:File", $cgi, {Directory=>&get_datadir()});

#Expiration time for viewer session is one minute.
$session->expire(60);

#We get the session ID to return to the client.
my $sid = $session->id();

#We count active sessions to get the number of active viewers.
my $viewercount = 0;
CGI::Session->find( sub {

	my ($session) = @_;
    if ($session->is_expired)    # <-- already expired 
    	{ 
    		$session->delete();
        	$session->flush();
      	}
    else
    	{ $viewercount++; } #Increment viewer count

	} );

#Return all the data in a neat json package.
print header('application/json');

print qq({
		   "viewers": "$viewercount",
		   "vid": "$sid"
		}); 
