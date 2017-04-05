#!/usr/bin/perl

use strict;

#Configuration values for the webcam application.
my $camname = "Webcam PFE";

#Height/Width parameters of the webcam. The application uses the default first V4L device (/dev/video0)
my @webcamdim = (1280, 720);

#Refresh rate of the camera picture, in seconds. ( values < 1 are rounded to 0. )
my $webcamrefresh = 1;

#Enable audio playback of messages sent to the camera. Requires espeak or a web connection+mpg123.
my $audioenabled = 1;

#Use an external MJPEG stream located at camdata instead of the default implementation.
my $useext = 0;

#Use espeak for audio messages. Default language is set to french.
#If disabled, a remote TTS API (responsivevoice.org) will be used instead, alongside mpg123 for playback. 
my $espeakenabled = 0;

#LDAP IDs in the list below can't send messages to the camera.
my @banlist = ["banned", "LDAP IDs", "go here"];

#LDAP Server Address for message logins
my $LDAPserver = "ldap.eisti.fr";

#LDAP Password 
my $LDAPpass = "";

#Directory where message history and viewer sessions are stored. Make sure permissions are 755.
my $datadir = "/var/www/camdata";

#Color of the main page. Available colors are the materialize ones shown at http://materializecss.com/color.html . 
#The page uses the accent-1 and accent-2 variants. 
my $color = "blue";


sub get_camname { return $camname };
sub get_webcamdim { return @webcamdim };
sub get_webcamrefresh { return $webcamrefresh };
sub is_audioenabled { return $audioenabled };
sub is_espeakenabled { return $espeakenabled };
sub get_datadir { return $datadir };
sub get_banlist { return @banlist };
sub get_ldapserv { return $LDAPserver };
sub get_ldappass { return $LDAPpass };
sub get_color { return $color };
sub get_external { return $useext };
