import can
from commands import *
import time
import code

bus = can.interface.Bus('can0', bustype='socketcan_native')
