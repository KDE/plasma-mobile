<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

# APN Autodetection list

`apns-full-conf.xml` is taken straight from the Android source code [here](https://android.googlesource.com/device/sample/+/master/etc/apns-full-conf.xml), which is where carriers add their APN information for Android to autodetect it.

# Steps to sync with upstream

Download the file:
```
curl "https://android.googlesource.com/device/sample/+/master/etc/apns-full-conf.xml?format=TEXT" | base64 --decode > apns-full-conf.xml
```

Then ensure the SPDX license headers are added appropriately.
