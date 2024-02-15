# RevolutionPi Connect SE Watchdog script

This is a very crude watchdog script used to tickle the external watchdog
circuitry of the RevolutionPi Connect SE hardware.

## Installation

1. Perform a shallow clone of this repository:
   `git clone --depth=1 https://github.com/widesky/revpi-connect-watchdog.git`
2. As `root`, install and enable the watchdog:
   `sudo make install enable`
3. Edit `/usr/local/sbin/revpi-watchdog.sh` to meet your needs
4. Safely power off the RevolutionPI
5. Remove the watchdog-disable jumper from the power connector (X4) of your
   RevolutionPi.
