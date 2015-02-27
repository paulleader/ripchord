# Ripchord

A concurrent, pipelined DVD ripping and transcoding tool.

Ripping and then transcoding of DVDs takes a long time, especially on a low power media or home server. However ripping a DVD is much fast than transcoding, but requires a person to insert each disk. On my micro-server ripping takes about 20 minutes, but transcoding happens at about real-time.

Ripchord will rip discs continuously, queuing transcoding jobs to be done in the background without human intervention, allowing you to keep feeding it discs without waiting for transcoding to finish. You can feed half a dozen disc through it in an evening and have the transcoding complete overnight.

## Process Overview

Ripchord is designed to be launched on the insert of a disc using a mechanism such as udev.

On startup Ripchord checks if it is already running:

 * if it is then it sends the signal USR1 to the running process to trigger a new rip.
 * if not then it begins the rip itself and starts trapping USR1 signals

The disc is ripped into a working directory using MakeMKV.
This ripped MKV is then transcoded to mp4 using Handbrake.
The transcoded file is then moved to the destination folder.

Ripping and transcoding are done in separate threads, ripped video is queued up for the transcoder to process in order.

## Dependencies

### Gems

* Pidfile: You'll need to install is from my fork which has a bug fix - git@github.com:paulleader/pidfile.git
* MakeMKV: Actually rips the DVD/Blueray - http://www.makemkv.com/
* Handbrake: To transcode the rip to something sensible for playback - https://handbrake.fr/

## Installation

Currently this is just a ruby script so download the source, install it somewhere sensible and run it from there.

Update lib/options.rb with your particular setup.

## Triggering with udev

Udev is a mechanism for triggering scripts based on hardware events such as inserting a disc.

Udev is not meant for starting long-running processes and may terminate any that don't finish quickly. To prevent this you will need a simple script in /usr/bin that runs Ripcord as a background process ('/my/path/ripcord &'). Udev shells only have the basic environment set up so you will probably need to set environment variables to make sure MakeMKV and Handbrake work. I use the following:

    #!/bin/bash
    PATH=/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin /usr/local/bin/ripchord/ripchord &
    exit

Then create a rulefile in /etc/udev/rules.d/ containing something like...

    SUBSYSTEM=="block", KERNEL=="sr0", ENV{ID_CDROM_MEDIA_DVD}=="1", RUN+="/usr/bin/dvdautoinsert"
    
Ripchord will now run automatically when you insert a DVD in the drive.

## Limitations

* Transcoding is limited to a single thread, so even if you have a really beefy machine it will only do one job at a time
* It's limited to using MakeMKV and Handbrake.
* It only handles movies (only long tracks are currently ripped and converted).
* Subtitles are not extracted.
* Naming of the result is based on the title found on the disc.

## TODO

* General tidy up.
* Tidy up logging, split out info and debug logging with optional debug mode.
* Improve exception handling.
* Extract configuration into a configuration file.
* Identify TV series and rip multiple episodes into a directory with appropriate file names.
* Package as a gem.
* Add notifications to email.
* Work out a better way of identifying discs.

Things I don't have the hardware for but which would be nice to do eventually:
* Add support for multiple transcoder threads.
* Add support for multiple concurrent rips (if you have multiple drives).

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credits

Paul Leader - @noneeeed

## License

MIT