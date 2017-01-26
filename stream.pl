#!/usr/bin/perl

use strict;
use CGI qw(:standard);

#Uses regular V4L cmd tools (mostly v4l2-ctl) to grab an image from the camera if the last one is too old (or doesn't exist at all)
#Returns a path to the generated image.

my $qjpg = new CGI;
my $result = "No parameter specified.";

#Require config 
require 'config.pl';


#check for picture file
#no file -> create a new one
#file -> check last modified time (mtime) and compare to the current timestamp to see if we need to 
my $getpicture = 0;
my $datadir = &get_datadir();
my $picturefile = $datadir."/camera.jpg";

my @webcamdim = &get_webcamdim();
my $w = $webcamdim[0];
my $h = $webcamdim[1];

if (-e $picturefile)
{
	my $lastupdate = (stat($picturefile))[9];
	
	if (time - $lastupdate > &get_webcamrefresh())
	{ $getpicture = 1; }
}
else
{ $getpicture = 1; }


if ($getpicture)
{

	#check if another instance of stream.pl isn't already capturing an image by looking for a lockfile
	my $lockfile = $datadir."/camera.lock";

    unless (-e $lockfile)
    {
    	#create lockfile
    	open my $fh,">".$lockfile;

    	#remove old picture
    	unlink($picturefile);

    	#take picture
    	`v4l2-ctl --set-fmt-video=width=$w,height=$h,pixelformat=3`;
		`v4l2-ctl --stream-mmap=3 --stream-count=1 --stream-to=$picturefile`;

		#copy picture to web directory, overwriting old one
		`cp $picturefile cam.jpg`;

		#delete lockfile
		unlink ($lockfile);
    }

}

#If there's a picture file, we return 1.
#Otherwise we return 0, so that the front-end knows if the camera connection is working.
print header('application/json');

if (-e $picturefile)
{
	print qq({
			   "result": 1,
			   "message":"New picture obtained from camera at $w x $h .",
			   "w": $w,
			   "h": $h
			}); 
}
else
{
	print qq({
			   "result": 0,
			   "message":"Camera unreachable, no picture created."
			}); 
}


