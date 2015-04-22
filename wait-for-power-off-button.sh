#!/bin/bash
# Raspberry Pi shutdown button
# Luc Small
# lucsmall.com
# 20150422
#
# Waits for a button press and then shuts down Raspberry Pi
#
# Momentary switch is connected between physical pins 25 and 26 on
# the GPIO header
#
# This script is added to crontab (with crontab -e) as follows:
#
# @reboot /home/pi/off-button/wait-for-power-off-button.sh
#
# All output goes to stdout and log file

# From http://stackoverflow.com/questions/3173131
# Redirect stdout to a named pipe running tee with append
exec > >(tee -a /home/pi/off-button/log.txt)
# Redirect stderr to stdout
exec 2>&1

echo Reboot at `date` - waiting... 

# Execute inline python code
sudo python - <<END
import time
import RPi.GPIO as gpio
# Set pin numbering to board numbering
gpio.setmode(gpio.BCM)
# Set up pin 7 as an input
# enable pullups
# physical pin 26 - short with physical pin 25 (gnd) to shutdown)
gpio.setup(7, gpio.IN, pull_up_down=gpio.PUD_UP)
print "Python: Waiting for 2 second button press..."
# Code adapted from
# http://raspberrypi.stackexchange.com/questions/13866/
buttonReleased = True
while buttonReleased:
    gpio.wait_for_edge(7, gpio.FALLING)
    # button has been pressed
    buttonReleased = False
    for i in range(20):
        time.sleep(0.1)
        if gpio.input(7):
            buttonReleased = True
            break
gpio.cleanup()
print "Python: Button pressed"
END

echo Done waiting at `date`. Halting system...
sudo halt
