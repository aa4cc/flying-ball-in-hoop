#!/usr/bin/python
import RPi.GPIO as GPIO
import time
import subprocess

GPIO.setmode(GPIO.BOARD)

# we will use the pin numbering to match the pins on the Pi, instead of the
# GPIO pin outs (makes it easier to keep track of things)
# use the same pin that is used for the reset button (one button to rule them all!)
GPIO.setup(37, GPIO.IN, pull_up_down=GPIO.PUD_UP)

oldButtonState1 = True

while True:
    #grab the current button state
    buttonState1 = GPIO.input(37)

    # check to see if button has been pushed
    if buttonState1 != oldButtonState1 and buttonState1 == False:
        # shutdown
        subprocess.Popen(['poweroff'])
        oldButtonState1 = buttonState1

    time.sleep(.5)
