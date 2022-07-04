# PLEASE NOTE, THIS SOFTWARE HAS BEEN REPLACED! 
For more information, see ![cmyflix](https://github.com/farfalleflickan/cmyflix)


# Myflix
*A Netflix clone!*

Myflix tries to be a somewhat simple and lightweight "DIY Netflix", similar to Plex, streama or Emby, for your DIY NAS, especially aimed at the Raspberry Pi/Odroid/etc ecosystem. It's not **meant** or **designed** to be fancy (if you have the hardware and want a ton of functionality, go for other solutions :) ), but the bare minimum to be somewhat pretty, fast and usable. The scripts create json databases that store the files location and metadata, these databases are then used to create static web pages that can be served from any web server!    
 I still have some commenting to do, I swear I will do it when I have time...

If you want to password protect your myflix files, you might want to look at ![this](https://github.com/pastapojken/JSONlogin)!  
You like my work? Feel free to donate :)  
[<img src="https://raw.githubusercontent.com/andreostrovsky/donate-with-paypal/master/dark.svg" alt="donation" width="150"/>](https://www.paypal.com/donate?hosted_button_id=YEAQ4WGKJKYQQ)

# Sreenshots:  
TV shows page  
![TV shows](https://github.com/pastapojken/Myflix/blob/master/screenshots/ec53e53f252f908bc8bac7f8c4486790.jpg)   

TV show season/episode modal
![TV show episodes](https://github.com/pastapojken/Myflix/blob/master/screenshots/fb31129a22d81b732ce88f02cae27fea.jpg)  


TV show episode player
![TV show episode player](https://github.com/pastapojken/Myflix/blob/master/screenshots/102b3df4924efeae7476d6ceee79bec9.png)

Movies page
![Movies](https://github.com/pastapojken/Myflix/blob/master/screenshots/d4271907a9af78d8dd84f3941ca1e56a.jpg)  

Movies player
![Movies player](https://github.com/pastapojken/Myflix/blob/master/screenshots/2eb41c935d1c11e19adb66466bcdf97e.png)


~~**Shitty temporary tutorial:**~~

~~You will need jq, imagemagick, ffmpeg and a ton of coffee to understand whatthef#ck I did.
Download all the files, look around in buildDBs.cgi and config.cfg, set the path of your media files folders and run buildDBs... 
Pray to a deity of your choice!~~

Requirements:

jq, sponge, imagemagick, ffmpeg, xmllint and a TMDB api key. See the wiki for a tutorial and more detailed information on the scripts.

Features :
* uses BASH for everything... at least so far!
* Movie and TV show databases are saved in an user friendly database
* Lightweight and highly customisable, just open a script and edit it! 
* Once you have built the database and the webpage, it's done. No streaming server or anything of the like...
* Since there is no real service, you could build the database and webpages on another machine, moving the webpage to the actual web server afterwards. ( keep in mind that the webserver must have access to the files etc...)
* Automatically converts srt's into vtt and makes them available in the video player
* Press f to fullscreen player, left to rewind 15 secs, right to skip forward 15 secs, space to play/pause

Issues :
* "Slow" file scanning, scanning 1200+ TV shows files while getting all kinds of metadata (so show id, posters for the show and the name of every episode...) took almost 20 minutes on an old odroid-c1... Skipping some metadata speeds up the process a lot ( episode name is the biggest culprit, as it adds a 2-3 seconds to every episode in the database). If I skip it, the time comes down to around 2-3 minutes. Note that this doesn't happen with movies as there is a lot less metadata to be fetched and my nas can perform this task in 30 seconds or so with 40+ movies.
* "Slow" html generation, the 1200+ tv show files end up creating a html page with 25700 lines of code... ~~Which generates in around 10 minutes...~~ It now is x2 faster thanks to threading! ;) Database creation is the same though, since it's sequential.
* html5 video player keeps buffering in the background if you play/pause a video. At the moment I have yet to implement a way to stop buffering
* not really an issue imho, but it's html5 reliant, so all video files HAVE to be h264 mp4's, no transcoding is going to happen. If you want transcoding, use something fancier like Emby ~~( transcoding might happen. We will see)~~
It won't happen, it would require rtmp streaming, rtmp server etc... Getting too complicated, KISS! (keep It Simple, Stupid!) ;)

TO-DO:
* ~~A "fix database" script, that fixes the metadata of a specific file (say, for example, that the script obtained the wrong id or wrong cover for your movie/tv show, this file should just just receive the file path of the file to fix and the correct id for it, and then it will simple overwrite the correct metadata to the database, thus sparing you from searching in the database and manually having to edit/download stuff)~~ DONE 
* ~~Multi language, multi subtitle support~~ DONE
*  ~~Currently working on parallelization of the html building process, it's almost working ;D~~ DONE
~~
