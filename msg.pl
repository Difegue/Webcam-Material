#!/usr/bin/perl

use strict;
use CGI qw(:standard);
use URI::Escape;
use Net::LDAP;

my $qedit = new CGI;
my $result = "No parameter specified.";

#Require config 
require 'config.pl';

if ($qedit->param('login') && $qedit->param('passw') && $qedit->param('message'))
{
        my $login = $qedit->param('login');
        my $message = $qedit->param('message');

        if (loginLDAP($login,$qedit->param('passw'))== 1)
        {
        	my @banlist = &get_banlist();
        	if( lc($login) ~~ @banlist )
        		{ 
        			$result = qq({
								   "result": 0,
								   "message":"Banned LDAP Login.",
								   "sent":"$message"
								}); 
				}
        	else
        		{
					open(my $logfile, '>>', &get_datadir().'/logcam.txt');
			        say $logfile ($qedit->param('login'))." - ".$message;
	        		$message = uri_escape($message);

	        		#If audio messages are enabled, try calling sendAudioMessage. 
	        		#Otherwise, result is automatically set to Message Sent.

					if (&is_audioenabled())
					{
						$result = &sendAudioMessage($message);
					}
					else
					{ 
	        			$result = qq({
									   "result": 1,
									   "message":"Message sent! (No audio)",
									   "sent":"$message"
									}); 
					}
        		}
        }
        else
   		{ 
			$result = qq({
						   "result": 0,
						   "message":"Login Error.",
						   "sent":"$message"
						}); 
		}
}

print header('application/json');
print $result;



#loginLDAP($login, $password)
sub loginLDAP
	{
		#test for no LDAP -- remove in real conditions
		#return 1;

		my $login = $_[0];
		my $pass = $_[1];
		
		my $ldap = Net::LDAP->new( &get_ldapserv() );
		$ldap->start_tls();

		# bind to a directory with dn and password
		# These parameters are specific to the EISTI LDAP Server, change as will.
		my $mesg = $ldap->bind( 'cn=webuser, dc=eisti,dc=fr',
		                     password => &get_ldappass()
		                   );

		$mesg = $ldap->search(
		                        base   => 'ou=people,dc=eisti,dc=fr',
		                        scope  => 'subtree',
		                        filter => '(uid='.$login.')',
		                        attrs  => ['dn']
		                      );

		# Get the user's dn and try to bind:
		my $user_dn = $mesg->entry->dn;
		#print $user_dn;
		
		my $login = $ldap->bind( $user_dn, password => $pass );
		
		if($login->code == 0)
			{ return 1; }
		else
			{ return 0; }

		$ldap->unbind;
	}

#sendAudioMessage($message)
sub sendAudioMessage
	{
		my $message = $_[0];
		$message = uri_unescape($message);

		#Check if a message isn't already being sent
        if ($message ne "")
        {
        	my $lockfile = &get_datadir()."/playing.lock";

                unless (-e $lockfile)
                {

                        open my $fh,">".$lockfile;

                        if (&is_espeakenabled())
                        {
                        	#my $outputest = &get_datadir()."/espeak.wav";
                        	#`espeak -vfrench -k5 -s100 "$message" -w $outputest`;
                        	#espeak automatically plays the audio file
                        	`espeak -vfrench -k5 -s100 "$message" `;
                        }
                        else
                        {
                        	$message = uri_escape($message);
                        	my $mp3location = &get_datadir()."/msg.mp3";
                        	#delete already existing message
                        	unlink $mp3location;
                        	#download audio from responsivevoice
                        	`wget --user-agent="" -O $mp3location 'https://code.responsivevoice.org/getvoice.php?t=$message&tl=fr&pitch=0.2&rate=0.4'`;
                        	#then play it with mpg123
                        	`mpg123 $mp3location`;
                        }

                        unlink ($lockfile);
                        return qq({
								   "result": 1,
								   "message":"Message sent!",
								   "sent":"$message"
								}); 
					
                }
                else
                {
                        return qq({
								   "result": 0,
								   "message": "Audio message already playing.",
								   "sent":"$message"
								   });
                }
        }
        else
        {
        	return qq({
					   "result": 0,
					   "message": "Can't send an empty message."
					   });
        }

	}
