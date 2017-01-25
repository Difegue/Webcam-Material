##Material-Webcam  

Web frontend to a V4L-compatible webcam, running on Perl and using Materialize CSS for display.  

Supports screenshots and messages using LDAP for account checking.  
Messages can be audio-transcripted using espeak.  

Dependencies :  

sudo apt-get install perl apache2 cpanminus espeak  
sudo cpanm CGI HTML::Scrubber URI::Escape LWP::Simple Net::LDAP CGI::Session Video::Capture::V4l Video::Capture::V4l::Imager Template 