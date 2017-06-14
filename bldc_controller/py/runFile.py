import serial
from commands import *
import time
import code

ser = serial.Serial('COM4', 115200, timeout = .5)
try:
    ser.open()
except:
    print("derp")

# code.interact()


# def jump():
    
#     mirrorB(ser, .001)
#     time.sleep(.01)
#     mirrorK(ser, .1)
#     time.sleep(.01)
#     mirrorP(ser, 1)
    
#     time.sleep(.5)
#     mirrorK(ser, .09)
#     time.sleep(.1)
#     mirrorP(ser, 11)
    
#     time.sleep(.3);
#     mirrorK(ser, .1)
#     time.sleep(.01)
#     mirrorP(ser, 5)
#     time.sleep(.01)
#     mirrorB(ser, .003)
#     time.sleep(.01)

