import serial
from math import*
import time
import struct
import matplotlib.pyplot as plt
import scipy.io as sio

cmd_SR_create = 0x10
cmd_SR_read = 0x11
cmd_SR_tr_off = 0x12
cmd_SR_tr_on = 0x13
cmd_IQ = 0x20
cmd_POS = 0x22
cmd_SYN = 0x61
cmd_IMP_prms = 0x40
cmd_CUR_prms = 0x41
cmd_PS_offset = 0x50
cmd_MODE = 0x60

K_ID = 10
B_ID = 20
P_ID = 30

motor_id = [40, 50]

#make sure these match what's in the firmware
K_Max = 1.0
B_Max = 0.1
P_Max = 18.0


def calcChecksum(packet):
    checksum = 0
    for byte in packet:
        checksum = checksum ^ byte
    return checksum


def formPacket(data):
    packet = bytearray(data)

    # Packet length - +3 for the header, length and footer (checksum)
    packet_length = len(packet) + 3

    # add the length
    packet.insert(0, packet_length)
    # add the header
    packet.insert(0, 255)

    # calculate the checksum
    checksum = calcChecksum(packet)

    # add footer
    packet.append(checksum)

    return bytes(packet)

# Read Signal Recorder buffer
def src(ser, ch_id = 0, sig_id = 0, buff_size = 1000, freq = 20000, immediate_trig = True):
    # Flush the buffer of the serial port
    _ = ser.read(10000)
    
    # Send the requirement for reading the buffer
    cmd_id = cmd_SR_create
    packet = formPacket([cmd_id, ch_id, sig_id] + list(struct.pack('IIB', buff_size, freq, immediate_trig)))
    ser.write(packet)

    # Read the one byte indicating the result
    result = bool(ser.read(1)[0])

    if not result:
        print('The channel was not initialized!')

# Disbale the signal trigger
def sro(ser):
    cmd_id = cmd_SR_tr_off
    packet = formPacket([cmd_id])
    ser.write(packet)


# Enable the signal trigger
def sri(ser):
    cmd_id = cmd_SR_tr_on
    packet = formPacket([cmd_id])
    ser.write(packet)

# Read Signal Recorder buffer
def srr(ser, ch_id = 0, savemat = False):
    # Flush the buffer of the serial port
    _ = ser.read(10000)
    
    # Send the requirement for reading the buffer
    cmd_id = cmd_SR_read

    fig = plt.figure()

    captured_data = []

    for i in range(len(ch_id)):
        packet = formPacket([cmd_id, ch_id[i]])
        ser.write(packet)

        # Read the first four bytes indicating the size of the buffer
        buff_size = int.from_bytes(ser.read(4), byteorder='big')

        if buff_size == 0:
            print('Buffer of zero size was returned. Either the channel is is out of range or the channel is not currently active.')
            return

        # Read the first four bytes indicating the size of the buffer
        Ts = struct.unpack('f', ser.read(4))[0]

        # Read the buffer
        buff = ser.read(4 * buff_size)

        # Convert the buffer of bytes to floats
        data = struct.unpack(str(buff_size) + 'f', buff)

        captured_data

        if len(ch_id) > 1:
            ax = fig.add_subplot(len(ch_id), 1, i+1)
            ax.plot([1000*Ts*i for i in range(buff_size)], data)
            ax.set_xlabel('Time [ms]')
            ax.set_title('Channel: ' + str(ch_id[i]))
            ax.grid()            
        else:
            plt.plot([1000*Ts*i for i in range(buff_size)], data)
            plt.xlabel('Time [ms]')
            plt.title('Channel: ' + str(ch_id[i]))
            plt.grid()
    plt.show()

    # return data, Ts


# Send reference on q current
def iq(ser, ref):
    # Send the requirement for reading the buffer
    cmd_id = cmd_IQ
    ref_in_bytes = struct.pack('f', ref)
    packet = formPacket(bytes([cmd_id]) + ref_in_bytes)
    ser.write(packet)


# Send reference on pos
def pos(ser, ref):
    # Send the requirement for reading the buffer
    cmd_id = cmd_POS
    ref_in_bytes = struct.pack('f', ref)
    packet = formPacket(bytes([cmd_id]) + ref_in_bytes)
    ser.write(packet)


# Synch control
def syn(ser, freq):
    # Send the requirement for reading the buffer
    cmd_id = cmd_SYN
    ref_in_bytes = struct.pack('f', freq)
    packet = formPacket(bytes([cmd_id]) + ref_in_bytes)
    ser.write(packet)



# Set params of impedance controller
def imp(ser, K, B):
    # Send the requirement for reading the buffer
    cmd_id = cmd_IMP_prms
    K_in_bytes = struct.pack('f', K)
    B_in_bytes = struct.pack('f', B)
    packet = formPacket(bytes([cmd_id]) + K_in_bytes + B_in_bytes)
    ser.write(packet)

# Set params of current controller
def curr(ser, Kq, KIq, Kd=None, KId=None):
    # Send the requirement for reading the buffer
    cmd_id = cmd_CUR_prms
    Kq_in_bytes = struct.pack('f', Kq)
    KIq_in_bytes = struct.pack('f', KIq)

    if Kd==None:
        Kd_in_bytes = Kq_in_bytes
        KId_in_bytes = KIq_in_bytes
    else:
        Kd_in_bytes = struct.pack('f', Kd)
        KId_in_bytes = struct.pack('f', KId)
    
    packet = formPacket(bytes([cmd_id]) + Kq_in_bytes + Kd_in_bytes + KIq_in_bytes + KId_in_bytes)
    ser.write(packet)


# Set params of impedance controller
def off(ser, off):
    # Send the requirement for reading the buffer
    cmd_id = cmd_PS_offset
    off_in_bytes = struct.pack('f', off)
    packet = formPacket(bytes([cmd_id]) + off_in_bytes)
    ser.write(packet)    

# Set mode
def mode(ser, mode_i=4):
    # Send the requirement for reading the buffer
    cmd_id = cmd_MODE
    MODEI_in_bytes = struct.pack('I', mode_i)
    packet = formPacket(bytes([cmd_id]) + MODEI_in_bytes)
    ser.write(packet)


def testp(ser, refpos = 10):
    # imp(ser, -0.05, -0.00125)
    # imp(ser, -1, -0.1)
    
    pos(ser, 0)
    time.sleep(.5)

    sro(ser)
    src(ser, 0, 1, freq=800, immediate_trig = False)
    src(ser, 1, 3, freq=800, immediate_trig = False)

    time.sleep(.5)

    pos(ser, refpos)
    time.sleep(.58)
    pos(ser, 0)
    time.sleep(1)

    srr(ser, [0, 1])

def testv(ser, refpos = 10):
    # imp(ser, -1, -0.1)
    
    pos(ser, 0)
    time.sleep(5)

    sro(ser)
    src(ser, 0, 1, freq=100, immediate_trig = False)
    src(ser, 1, 3, freq=100, immediate_trig = False)

    time.sleep(.5)

    pos(ser, refpos)
    time.sleep(5)
    pos(ser, 0)
    time.sleep(5)

    srr(ser, [0, 1])

def testi(ser, iref = .5):    
    iq(ser, 0)
    time.sleep(.5)

    sro(ser)
    src(ser, 0, 0, freq=500, immediate_trig = False)
    src(ser, 1, 6, freq=500, immediate_trig = False)
    src(ser, 2, 7, freq=500, immediate_trig = False)
    src(ser, 3, 2, freq=500, immediate_trig = False)

    time.sleep(.5)

    iq(ser, iref)
    time.sleep(1)
    iq(ser, 0)

    srr(ser, [0, 1, 2, 3])

def test_current_meas(ser):
    iq(ser, 0)
    time.sleep(.5)
    mode(ser, 4)

    sro(ser)
    src(ser, 0, 6, freq=20000, immediate_trig = False)
    src(ser, 1, 7, freq=20000, immediate_trig = False)
    src(ser, 2, 10, freq=20000, immediate_trig = False)
    src(ser, 3, 11, freq=20000, immediate_trig = False)
    sri(ser)

    time.sleep(1)
    srr(ser, [0, 1, 2, 3])


def sinRef(ser, amp = 1, freq = .5):
    t = 0
    while True:
        pos(ser, amp*sin(2*3.14*freq*t))
        t = t + .05
        time.sleep(0.05)

def whatever(ser):
	for i in range(10):
		offset = 2*3.14/10*i
		print(offset)
		off(ser, offset)
		testv(ser, 100)
    
# # Set joint damping
# def setB(ser, m_id, val):
#     val = max(min(val, B_Max), 0)
#     b_u16 = floor(val*65278/B_Max)
#     b1 = b_u16>>8
#     b2 = b_u16-(b1<<8)
#     checksum = calcChecksum([motor_id[m_id], B_ID, b1, b2])
#     ser.write(bytes([255, 255, motor_id[m_id], B_ID, b1, b2, checksum]))


# #Set joint position
# def setP(ser, m_id, val):
#     val = max(min(val, P_Max), 0)
#     p_u16 = floor(val*65278/P_Max)
#     b1 = p_u16>>8
#     b2 = p_u16-(b1<<8)
#     checksum = calcChecksum([motor_id[m_id], P_ID, b1, b2])
#     ser.write(bytes([255, 255, motor_id[m_id], P_ID, b1, b2, checksum]))
