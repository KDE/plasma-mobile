<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

This folder is where device-specific information is set.

### Usage as a distro

As a distribution, you can ship the device preset with the image by installing a file.

In `/etc/xdg/plasmamobilerc`, write:

```toml
[Device]
device=oneplus-enchilada # replace with the device id
```

This should be a file name that exists in `/usr/share/plasma-mobile-device-presets` (which are the files in the `configs` folder).

### Adding a new device config

See [spec.conf](spec.conf) for more details on the specification. If a setting is omitted in the file, then the system will use the default value.

Add a new config in [configs](configs) with the device id.

In order to test your changes, install the file to `/usr/share/plasma-mobile-device-presets/your-device-id.conf`. Then run envmanager to apply the changes to the running system:

```
$ plasma-mobile-envmanager --apply-settings
$ plasmashell --replace
```
