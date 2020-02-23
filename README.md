# SD Card automatic media copier

Automatically copy pictures after inserting SD Card.

## How this works?

1. Udev detects inserted SD Card with rule from [udev/99-sd-copier.rules] file and notifies systemd service
2. Systemd runs `copier.sh` script with device as parameter. For example if SD card is located at `/dev/sda` then systemd
service state can be checked with `systemctl status sd-copier@-dev-sda1.service`
3. `copier.sh` mounts SD card device and tries to detect following parameters from EXIF data of first located picture:
  - camera make (manufacturer)
  - month and year when picture was taken (if not present it assumes current date)
  - picture location (if not present it defaults to `Unknown_Location`)
4. Script uses `rsync` to copy pictures to local directory specified as: `PREFIX/YEAR/MONTH/LOCATION/MANUFACTURER`. 
High quality RAW pictures are copied to subfolder called `RAW`. `PREFIX` is set by default to `/srv/media` and can be
changed by modifying systemd service file.

## Installation

1. Copy udev rule to `/etc/udev/rules.d` and systemd service to `/etc/systemd/system`
2. Reload udev and system by running following as root: `udevadm control --reload-rules && systemctl daemon-reload`
3. Copy `copier.sh` to `/usr/local/bin` and make sure it is executable.

TL;DR:
```
# as root:
cp udev/99-sd-copier.rules /etc/udev/rules.d/
cp systemd/sd-copier@.service /etc/systemd/system/
udevadm control --reload-rules
systemctl daemon-reload
cp copier.sh /usr/local/bin/
chmod +x /usr/local/bin/copier.sh
```

## TODO

- rewrite to go-lang?
- containerize?
