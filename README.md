# Ripchord

A concurrent, pipelined DVD ripping and transcoding tool.

* No human intervention needed except inserting each disc to rip. Discs are ejected when they finish ripping.
* Ripping and transcoding happen in parallel, allowing you to rapidly rip multiple discs and let the conversion happen in the background while you sleep.
* Each disc is processed in its own thread, so if there is a problem with one job it shouldn't stop other jobs.
* Email notifications at each step of the process, and on failure of a job.

Ripping and then transcoding of DVDs takes a long time, especially on a low power media or home server. However most of that time is spent in the transcoding stop. Ripping a DVD is much faster than transcoding, but requires a person to insert each disk. On my micro-server ripping takes about 20 minutes but transcoding happens at about real-time.

Ripchord will rip discs continuously, queuing transcoding jobs to be done in the background without human intervention, so you can keep feeding it discs without waiting for transcoding to finish.

## Process Overview

Ripchord is designed to be launched on the insert of a disc using a mechanism such as udev (see below).

On startup Ripchord checks if it is already running:

 * if it is then it sends the signal USR1 to the running process to trigger a new rip.
 * if not then it begins the rip itself and starts trapping USR1 signals

The disc is ripped into a working directory using MakeMKV.
This ripped MKV is then transcoded to mp4 using Handbrake.
The transcoded file is then moved to the destination folder.

## Dependencies

### Gems

* Pidfile: You'll need to install is from my fork which has a bug fix - git@github.com:paulleader/pidfile.git
* action_mailer

### External Tools

* MakeMKV: Actually rips the DVD/Blueray - http://www.makemkv.com/
* Handbrake: To transcode the rip to something sensible for playback - https://handbrake.fr/

# Installation

Currently this is just a ruby script so download the source, install it all somewhere sensible (/usr/local/bin) and run it from there.

## Configuration
By default Ripchord expects to find the configuration file in /etc/ripchord.yml but you can override that with the --config command line option. This should look something like the following...

```YAML
---
log_file: /var/log/ripchord.log
working_directory: /mnt/my_big_disk/ripchord_working_area
disc: 'disc:0'
device: /dev/sr0
extension: mp4
source_drive: /dev/sr0
preset: AppleTV 2
destination_directory: /mnt/my_big_disc/media/movies
notification_address: me@example.com
notifications_from: ripchord@example.com
smtp:
  address: smtp.gmail.com
  port: 587
  domain: gmail.com
  authentication: plain
  user_name: myusername
  password: mypassword
  enable_starttls_auto: true
```

## Triggering with udev

Udev is a mechanism for triggering scripts based on hardware events such as inserting a disc.

Udev is not meant for starting long-running processes and may terminate any that don't finish quickly. To prevent this you will need a simple script in /usr/bin that runs Ripcord as a background process. Udev shells only have the basic environment set up so you will probably need to set environment variables to make sure MakeMKV and Handbrake work. I use the following:

```bash
#!/bin/bash
echo 'PATH=/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin /usr/local/bin/ripchord/ripchord' | at now
```

This uses the 'at' command to trigger ripchord immediately as a totally separate process that won't get killed by
udev.

Then create a rule file in /etc/udev/rules.d/ containing something like...

```bash
SUBSYSTEM=="block", KERNEL=="sr0", ENV{ID_CDROM_MEDIA_DVD}=="1", RUN+="/usr/bin/dvdautoinsert"
```
    
Ripchord will now run automatically when you insert a DVD in the drive.

## Limitations

* Transcoding is limited to a single thread, so even if you have a really beefy machine it will only do one job at a time
* It's currently limited to using MakeMKV (ripping) and Handbrake (conversion).
* It only handles movies (only long tracks are currently ripped and converted).
* Subtitles are not extracted.
* Naming of the result is based on the title found on the disc, this is not always that reliable, so you may have to rename some files if you want your media player to correctly identify them.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request
6. Wait a couple of days while I find the time to respond in-between feeding/changing the baby... :)

## TODO

* General tidy up.
* Tidy up logging, split out info and debug logging with optional debug mode.
* Identify TV series and rip multiple episodes into a directory with appropriate file names.
* Package somehow.
* Work out a better way of identifying discs. Is there something like CDDB for DVDs?
* Support alternative rippers and transcoders.
* Add support for audio ripping.

Things I don't have the hardware for but which would be nice to do eventually:
* Add support for multiple transcoder threads. This would be a relatively easy change, just swap the Ruby semaphore for an implementation of a counting semaphore whose limit it set by the configuration. Everything else should then just run.
* Add support for multiple concurrent rips (if you have multiple drives).

## Credits

Paul Leader - @noneeeed

## License

MIT