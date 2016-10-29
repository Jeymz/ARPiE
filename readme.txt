CONTENTS OF THIS FILE
---------------------
   
 * Introduction
 * Requirements
 * Recommended modules
 * Installation
 * Configuration
 * Troubleshooting
 * FAQ
 * Maintainers

INTRODUCTION
------------

ARPiE is an alpha project that allows users the ability to configure their
Raspberry Pi 3 as a 3G Router with little to no effort. Currently the
feature list is a bit lacking, but we plan on continuing updates
and bringing more to the platform. Enjoy!

 * For a full description of the project visit:
   https://arpie.jeymz.xyz

 * To submit bug reports and feature suggestions e-mail:
   Bugs@jeymz.xyz
   
 * To submit code improvements or help with development e-mail
   Developers@jeymz.xyz

   
REQUIREMENTS
------------

ARPiE Requires The Below Software/Hardware:
SOFTWARE:
 * Raspbian Wheezy Build
 * hostapd
 * dnsmasq
 * wvdial
 * ppp

HARDWARE:
 * Raspberry Pi 3
 * Huawei E303, E353, E173 (Other varients may work, but have not been tested)
 

RECOMMENDED MODULES
-------------------

HARDWARE:
 * MoPi Raspberry Pi Hat (Used for multi power source configuration)

SOFTWARE:
 * simbamond

 
INSTALLATION
------------
 
 * Copy the entire ARPiE folder to /home/pi/

 * Navigate to the folder and execute the config script with sudo permissions
   ie: sudo ./config

   
CONFIGURATION
-------------
 
 * The First switch is the Device Name
   This name can be anything, but cannot contain spaces.

 * The Second switch is the Active Cores Number 1-4
   Must be a number between 1 and 4

 * The Third switch is for Carrier / APN Selection
   Current Carriers include Aeris and Hologram.
   -Hologram is: IO
   -Aeris AT&T is: AATT
   -Aeris is: A
   -Wyless ATT is: ATT

   
TROUBLESHOOTING
---------------

 * No Wireless AP

   - Verify hostapd and dnsmasq are installed

   - Uplug the 3G connection until a reboot completes, then wait for 10 minutes
   
 * No 3G Connection
   
   - Verify WVDial and ppp are installed
   
   - Verify APN/Carrier Settings are properly configured
   
   - Verify you have a supported 3G USB Modem

   
FAQ
---

Q: My Carrier/APN setting wont connect

A: Because this project stemmed from a specific focus we do not have a large
   selection of APN/Carriers to choose from. Please send an e-mail with your
   APN and Carrier to bugs@jeymz.xyz and we will provide you with a config
   within 24 business hours
   
Q: Features not working the way I want

A: Again, because this project stemmed from a specific focus it may not behave
   the way you would like. If you encounter any issues or missing configurability
   options please send an e-mail to bugs@jeymz.xyz with your request and we will
   try our best to accomidate your issue
   
Q: This seems really clunk
A: That's because it is. I built this entire thing from scratch for a specific
   need and have little coding experience in regards to linux. I promise I am
   working on making a more robust version, but until then please let me know
   your specific issue by either e-mailing me at bugs@jeymz.xyz or commenting
   on our wordpress at arpie.jeymz.xyz. Please keep comments in the correct
   version area so we can isolate your requests with the corresponding releases

   
MAINTAINERS
-----------

Current maintainer:
 * Jeymz - http://arpie.jeymz.xyz

I am currently the only person working on this code.
If I have sparked your interest, or you wish to contribute please e-mail me
with your code suggestions at developers@jeymz.xyz

