# epicPiOS

<<<<<<< HEAD
An always resettable Operationg System based on respios. There are two flawers, one desktop version and one server version. Idea from [MagPi](https://magpi.raspberrypi.com/articles/raspberry-pi-recovery-partition) code manly copied from PJ Evans [github repo]https://github.com/mrpjevans/raspbian_restore).

## Important Notes
Upgrading the kernel may break the reset capability. For this reason, raspberrypi-kernel package is set on hold with ```apt-mark hold raspberrypi-kernel```.

## Usage
1. Ddownload zip from https://sourceforge.net/projects/epicpios/
2. Image your sd card with the raspberry pi imager. !! Do not use any advanced options via command-shift-x otherwise you will break the funktionality!!
3. Boot your rapspi with the new sd card
4. To factory reset your pi use: ```sudo /boot/boot_to_recovery restore```

To only switch between booting to recovery mode and normal mode use ```sudo /boot/boot_to_recovery``` and ```sudo /boot/boot_to_root``` without any options.

## Build
1. checkout repo
2a. ```docker run -t -v /dev:/dev -v $(pwd):/epicPiOS --privileged ubuntu:focal /bin/bash -c 'cd epicPiOS; ./epic-server-answers | ./create_epicPiOS'```
2b. ```docker run -t -v /dev:/dev -v $(pwd):/epicPiOS --privileged ubuntu:focal /bin/bash -c 'cd epicPiOS; ./epic-desktop-answers | ./create_epicPiOS'```

resulting image is then stored in ./tmp

