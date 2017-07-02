**Myflix**
> A Netflix clone!

Myflix tries to be a somewhat simple and lightweight "DIY Netflix", similar to Plex or Emby, for your DIY NAS, especially aimed at the Raspberry Pi/Odroid/etc ecosystem.

Shitty temporary tutorial:

Requires a bash cgi implementation for your web server. Not that it uses at this stage... But it will, probably.

You will also need jq, imagemagick and a ton of coffee to understand whatthef#ck I did.

Download all the files, look around in buildDBs.cgi and config.cfg, set the path of your media files folders and run buildDBs... Pray to a diety of your choice!


Features :
* uses BASH for everything... at least so far!
* Movie and TV show databases are saved in an user friendly database
* Lightweight and highly customisable, just open a script and edit it! 

Issues :
* "Slow" file scanning, scanning 200+ TV shows files while getting metadata (so, IDs and posters ) took around 2:30 minutes, no metadata = faster scanning! 
* No comments... Whoops...
* Pretty useless at the moment...
* not really an issue imho, but it's html5 reliant, so all video files HAVE to be mp4's

TO-DO:
* Subtitle support (in VTT)
* Separate metadata download and database creation... maybe... 
* A decent tutorial

More in the coming days...
