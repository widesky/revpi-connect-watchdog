#!/bin/bash

# Simple watchdog for checking connectivity to the Internet.
# This can be modified to meet specific requirements.
#
# © 2024 WideSky.Cloud Pty Ltd
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.P

# Poll interval: this must be less than 60 seconds, but not too frequent that
# we hammer the CPU with tests.  Adjust to taste.
WATCHDOG_INTERVAL=20

# Watchdog PID file
WATCHDOG_PID=/tmp/watchdog.pid

# Tests to run, put your checks here and either return 0 for all clear, or
# return 1 for a failure.
check() {
    # Example: Ping GoogleDNS (secondary) 3 times, waiting up to 10 sec
    if ping -q -c 3 -W 10 8.8.4.4 ; then
        return 0
    else
        return 1
    fi
}

# What to do if the above check fails?
onFail() {
    # Sync filesystems in preparation for sudden shutdown
    sync
}

# End of configuration settings

# PITEST_VAR: the "variable" in the piTest utility that stores the watchdog
# bit.  Kunbus decided to shoehorn the watchdog into this register to save
# memory.
PITEST_VAR=RevPiLED

# Watchdog bit to toggle: most significant bit is used for the watchdog.
WATCHDOG_BIT=7

# Watchdog bit mask
WATCHDOG_MASK=$(( 1 << ${WATCHDOG_BIT} ))

# Read the watchdog value
readWD() {
    piTest -q -1 -r ${PITEST_VAR}
}

# Write a value to the watchdog
writeWD() {
    piTest -q -w "${PITEST_VAR},${1}"
}

# Write out the PID so we can kill it later.
echo $$ > ${WATCHDOG_PID}

# Main loop
while sleep ${WATCHDOG_INTERVAL}; do
    if check; then
        # Success, read watchdog value
        watchdog=$( readWD )
        # Toggle bit
        watchdog=$(( ${watchdog} ^ ${WATCHDOG_MASK} ))
        # Write back
        writeWD ${watchdog}
    else
        # Failure, prepare for reset
        onFail
    fi
done
