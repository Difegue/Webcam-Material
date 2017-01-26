##Material-Webcam  

Web frontend to a V4L-compatible webcam, running on Perl and using Materialize CSS for display.  

Supports screenshots and messages using LDAP for account checking.  
Messages can be audio-transcripted using espeak.  

![]()  

Dependencies and setup:  
```
sudo apt-get install perl apache2 cpanminus espeak  
sudo cpanm CGI HTML::Scrubber URI::Escape LWP::Simple Net::LDAP CGI::Session Template  
sudo usermod -a -G video www-data  
sudo a2enmod cgi  
```

Don't forget to configure your apache sites-enabled in order to execute .pl scripts.
